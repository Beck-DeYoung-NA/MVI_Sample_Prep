if (!require("pacman")) install.packages("pacman")
# Loads in necessary packages, and installs them if you don't have them installed
pacman::p_load("tidyverse",
               "glue",
               "rvest",
               "kableExtra")

# ------------------------------------------------------------------------------
# Lets you embed variables into strings like python f-strings

f_str <- function(str) glue(str) %>% as.character()

# ------------------------------------------------------------------------------
MONTH <- "03"
YEAR <- 2023
MVIQ <- "MVIQ123"

# If any new CVs are added, this needs to be updated
CV_VARS <- c("PML_FYF", "PML_WAIVER", "RCP_GOLD", "RCP_GREEN", "CENTURION", "PLATINUM", "COBRAND", "AIRLINE")

# ------------------------------------------------------------------------------
HELPER_FILE_PATH <- "../MVI_Sample_Prep_Helper_{MVIQ}.xlsx" %>% f_str()
MARKET_FILES_PATH <- "../All_Sample_Files/Market_Files"

RAW_DATA_PATH <- "\\\\pm1/33-626/Quantitative/Sampling-Weighting/Files from CMS/Q1"

PCT_INDIA_PATH <- "../Supporting_Files/Final MVI Q1.23 PCT List INDIA.csv"
PCT_EX_INDIA_PATH <- "../Supporting_Files/Final MVI Q1.23 PCT List Ex INDIA_cleaned1.csv"

# ------------------------------------------------------------------------------

load_raw_data <- function(country){
  "
  Function to extract the information for each country dataset and load it in
  "
  paste0("Loading: ", country) %>% print()
  
  # Get the list of files in the country sub-folder
  country_files <- file.path(RAW_DATA_PATH, country) %>% list.files()
  
  # Get the country info from the sample prep file
  na_country_info <- country_codes[country_codes$`Country_Language` == country,]
  
  # identify which file contains the layout
  layout_file <- country_files[str_detect(country_files, "deliveryfilelayout.html")]
  
  # Read in the html layout file and extract all tables
  html_file_tables <- file.path(RAW_DATA_PATH, country, layout_file) %>%
    read_html() %>% html_nodes("table") 
  
  # Contains filename and number of expected records
  data_file <- html_file_tables[[3]] %>% html_table() 
  
  data_filename <- data_file$`Final File Name` %>% paste0(".txt")
  
  # Layout table has the variable names, and their start and stop positions in the text file
  layout_table <- html_file_tables[[4]] %>% html_table() %>%
    # Get the desired field names from the "Variable info" sheet of the Sample Prep Helper Excel
    left_join(var_mapping, by =c("Field Name" = "OG_Field"))
  
  # Check if any new variables are present
  if(sum(is.na(layout_table$New_Fieldname)) > 0){
    stop(paste(' There are new variables in the raw data not listed in the Sample Prep Helper Excel sheet "Variable Info". Please add them before rerunning this code:', 
               paste(layout_table$`Field Name`[is.na(layout_table$New_Fieldname)], collapse = " | ")))
    }
  
  # Load in the data
  tbl <- "{RAW_DATA_PATH}/{country}/{data_filename}" %>% glue() %>% 
    read_fwf(col_positions = fwf_widths(layout_table$Length),
             col_types = cols(.default = 'c')) %>% # Default every import to character to not mess up formats 
    set_names(layout_table$New_Fieldname)
  
  if (nrow(tbl) != data_file$`Number of Records`) warning("Number of records not consistent")
  
  # Add Country specific info
  tbl %>% 
    mutate(Country = na_country_info$Country,
           NA_Country_Code = na_country_info$NA_Country_Code,
           NA_Language_Index = na_country_info$NA_Language_Index,
           Language_Code = na_country_info$Language_Code,
           FileExt = na_country_info$FileExt,
           NA_Language_Code = na_country_info$NA_Language_Code,
           CV_ICS_Region = na_country_info$CV_ICS_Region,
           Filename = na_country_info$Filename %>% f_str()) %>% 
    return()
}

# ------------------------------------------------------------------------------
add_cv_var <- function(df, var, cv_vars_df){
  "
  Adds a created variable to the dataset based on the CV_Prods_Table provided in the instructions excel file
  "
  print(f_str("Adding: {var}"))
  # Get the column names for the variable and its info
  product_var <- paste0("Product_", var)
  var_name <- paste0("CV_", var)
  cv_vars_df <- cv_vars_df %>% select(contains(var))
  
  if (var != "CENTURION"){ # We skip centurion because there is no "Comment" column in the sheet we are provided
    comment_var <- paste0("Comment_", var)
    cv_vars_df <- cv_vars_df %>% filter(is.na(!!ensym(comment_var)) | 
                                          !str_detect(tolower(!!ensym(comment_var)), "removed"))
  } 
  
  cv_vars_df <- cv_vars_df %>% 
    select("NA_Product_Code" = all_of(product_var), all_of(var_name)) %>% 
    filter(!is.na(!!ensym(var_name))) %>% # Remove where the VAR_NAME is not blank because this removes blank lines and unneeded comments
    # We turn this dataframe into a case_when statement to apply the desired value to VAR_NAME
    mutate(left_cond = if_else(tolower(NA_Product_Code) == "else", "TRUE", 
                               paste0("as.numeric(NA_Product_Code) == ", as.numeric(NA_Product_Code))), # numeric PC because NA_Product_Code has no leading zeros in the CMS data
           full_cond = paste0(left_cond, " ~ '", !!ensym(var_name), "'"))
  
  # As an example the full_cond variable basically looks like "as.numeric(NA_Product_Code) == 199 ~ 'Y'" or
                                                            # "TRUE ~ N" for the else case
  
  df %>% mutate("{var_name}" := case_when(!!!rlang::parse_exprs(cv_vars_df$full_cond))) %>% return()
}

# ------------------------------------------------------------------------------

# Make a nice looking table for the html output
make_nice_table <- function(tab, caption){
  if (knitr::is_html_output()){ # Only print the table nicely if we are knitting
  knitr::kable(tab, format = "html",
               caption = paste("<center><strong>", caption, "</strong></center>"),
               escape = FALSE,
               booktabs = TRUE) %>% 
    kable_styling(bootstrap_options = "striped",
                  full_width = F, position = "center") %>% print()
  } else {
    print(tab)
  }
  tab %>% return() # Return the original table to avoid printing NULL in output
}

# ------------------------------------------------------------------------------
# Function to generate a frequency table
freq_table <- function(df, var, caption=NULL){
  tab <- df %>% group_by(across(all_of(var))) %>% 
    summarise(Freq = n()) %>% 
    ungroup() %>% 
    mutate(pct = (Freq / sum(Freq) * 100),
           cum_freq = cumsum(Freq),
           cum_pct = cumsum(pct)) %>% 
    mutate_if(is.numeric, round, digits = 2)
  
  if (!is.null(caption)) make_nice_table(tab, caption) # print table
  
  tab %>% return() # Return the table
}