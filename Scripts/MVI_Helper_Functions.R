# ==============================================================================
# Helper Functions for USCS Sample Prep Script
# ==============================================================================
# This file contains helper functions for USCS Sample prep.
# ==============================================================================

# ------------------------------------------------------------------------------
# Package Management
# ------------------------------------------------------------------------------
if (!require("pacman")) install.packages("pacman")

# Loads in necessary packages, and installs them if you don't have them installed
pacman::p_load("tidyverse",
               "readxl",
               "glue",
               "rvest",
               "kableExtra",
               "conflicted",
               "cli")

conflicts_prefer(dplyr::select,
                 dplyr::filter,
                 .quiet = TRUE)

# Source configuration
source("MVI_Config.R")

# ------------------------------------------------------------------------------

load_variable_name_mapping <- function(){
  read_excel(.HELPER_FILE_PATH, sheet = "Variable_Info")
}

load_countries_info <- function(){
  read_excel(.HELPER_FILE_PATH, sheet = "Country_Info")
}


load_country_data <- function(country, path, country_info, var_mapping){
  "
  Function to extract the information for each country dataset and load it in
  "
  cli_alert_info("Processing: {.strong {country}}")
  # Verify the path exists
  if (!dir.exists(file.path(path, country))) {
    cli_alert_danger(paste("Error: Country path does not exist -", country))
    stop("Country path does not exist")
  }
  
  # Get the list of files in the country sub-folder
  country_files <- file.path(path, country) %>% list.files() 
  
  # Let us know if the country file hasnt been received without breaking the code
  if (length(country_files) == 0){cli_alert_warning("Not Recieved Yet"); return(data.frame(Country = NA))}
  
  # Get the country info from the sample prep file
  na_country_info <- country_info[country_info$`Country_Name_CMS` == country,]
  
  if (nrow(na_country_info) == 0) {
    cli_alert_danger(paste("Error: Country not found in Sample Prep Helper -", country))
    stop("Country not found in the Sample Prep Helper Excel sheet")
  }
  
  # identify which file contains the layout
  layout_file <- country_files[str_detect(country_files, "deliveryfilelayout.html")]
  
  # Read in the html layout file and extract all tables
  html_file_tables <- file.path(path, country, layout_file) %>%
    read_html() %>% html_nodes("table") 
  
  # Contains filename and number of expected records
  data_file <- html_file_tables[[3]] %>% html_table() 
  
  data_filename <- data_file$`Final File Name` %>% paste0(".txt")
  
  # Layout table has the variable names, and their start and stop positions in the text file
  layout_table <- html_file_tables[[4]] %>% html_table() %>%
    # Get the desired field names from the "Variable info" sheet of the Sample Prep Helper Excel
    left_join(var_mapping, by = c("Field Name" = "OG_Field"))
  
  # Check if any new variables are present
  if(sum(is.na(layout_table$New_Fieldname)) > 0){
    new_vars <- layout_table$`Field Name`[is.na(layout_table$New_Fieldname)]
    cli_alert_danger("New variables detected that are not in the Sample Prep Helper:")
    cli_ul(new_vars)
    stop("Please add new variables to the Sample Prep Helper Excel sheet")
  }
  
  cli_progress_step("Reading data file")
  
  # Load in the data
  tbl <- file.path(path, country, data_filename) %>% 
    read_fwf(col_positions = fwf_widths(layout_table$Length),
             col_types = cols(.default = 'c')) %>% # Default every import to character to not mess up formats 
    set_names(layout_table$New_Fieldname)
  
  if (nrow(tbl) != data_file$`Number of Records`) {
    cli_alert_warning(
      paste("Record count mismatch for", country, 
            "Expected:", data_file$`Number of Records`, 
            "Actual:", nrow(tbl))
    )
  }
  
  # Add Country specific info
  tbl %>% 
    mutate(Country = na_country_info$Country,
           NA_Country_Code = na_country_info$NA_Country_Code,
           NA_Language_Index = na_country_info$NA_Language_Index,
           Language_Code = na_country_info$Language_Code,
           File_Ext = na_country_info$File_Ext,
           NA_Language_Code = na_country_info$NA_Language_Code,
           CV_ICS_Region = na_country_info$CV_ICS_Region,
           Filename = na_country_info$Filename %>% f_str()) %>% 
    return()
}



load_MVI_raw_data <- function(path = .RAW_DATA_PATH, bypass_missing_folders = FALSE){
  countries <- dir_ls(path, type = "directory") %>% path_file() # Get list of countries in the Sampling Weighting Folder
  
  var_mapping <- load_variable_name_mapping()
  
  country_info <- load_countries_info()
  
  # Check if all countries have folders (country_info$Country_Name_CMS vs countries)
  missing_country_folders <- setdiff(country_info$Country_Name_CMS, countries)
  missing_country_info <- setdiff(countries, country_info$Country_Name_CMS)
  
  if (length(missing_country_folders) > 0) {
    cli_alert_danger("Missing country raw data folders:")
    cli_ul(missing_country_folders)
    if (!bypass_missing_folders) {
      cli_alert_info("Set bypass_missing_folders = TRUE to continue without these folders")
      stop()
    }
  }
  
  if (length(missing_country_info) > 0) {
    cli_alert_danger("Missing country info in Sample Prep Helper. This needs to be fixed before loading data. Check Country_Name_CMS column against folder names. Cannot be bypassed.")
    cli_ul(missing_country_info)
    stop()
  }
  
  # Nice progress bar
  pb <- cli_progress_bar(format = "{pb_spin} Joining markets: [{pb_bar}] {pb_percent} | {pb_current}/{pb_total}", 
                         total = length(countries) - 1)
  
  # Load in the data for each country
  map(countries, ~load_country_data(.x, path, country_info, var_mapping)) %>% 
    reduce(function(x, y) {
      cli_progress_update(id = pb)
      suppressMessages(full_join(x, y))
    }) %>%
    mutate(across(c("Tenure", "Total_OD_Spend_USD"), as.numeric),
           NA_Cell_Number = as.numeric(Cell_Number))
  
} 

load_pml <- function(){
  read_excel(.HELPER_FILE_PATH,
             sheet = "PML_Info",
             skip = 1) %>% 
    # Convert certain columns to numeric
    mutate(across(c(NA_Country_Code, NA_Language_Index, File_Ext, Sample_Requested), ~ suppressWarnings(as.numeric(.))),
           NA_Cell_Number = as.numeric(Cell_Number),
           # Fix subject_line_insertion variable
           Subject_Line_Insertion =  if_else(Subject_Line_Insertion == "[No subject line insertion]", 
                                             NA_character_,
                                             # Remove non-breaking spaces at end of line
                                             gsub("[\u00A0\\h\\v]+$", "", Subject_Line_Insertion) %>%
                                               # Not sure if we care about these two
                                               # Change other non breaking spaces to regular spaces
                                               gsub("\u00A0", " ", .) %>% 
                                               # Remove zero-width spaces
                                               gsub("\u200B", "", .) %>% trimws())) %>%  
    filter(Sample_Requested > 0) %>% # Remove two Thailand products that are not used anymore will also remove any 0 sample requested products
    select(-Country) # The Country variable in the PML is not what we want
}

load_reporting_names <- function(){
  read_excel(.HELPER_FILE_PATH, sheet = "CV_Reporting_Names") %>% 
    set_names(c("NA_Product_Code", "CV_Reporting_Names", "Comment")) %>% 
    # Remove products who have been removed
    filter(is.na(Comment) | !str_detect(tolower(Comment), "removed")) %>% 
    select(-Comment) %>% 
    mutate(NA_Product_Code = as.character(NA_Product_Code))
}

load_pct_changes <- function(){
  read_excel(.HELPER_FILE_PATH, sheet = "PCT_Code_Changes") %>% 
    mutate(Updated_NA_Cell_Number = as.numeric(Updated_NA_Cell_Number),
           Updated_Cell_Number = str_pad(Updated_NA_Cell_Number, 2, 'left', '0')) %>% 
    select(-Card_ProductAIF, -Count)
}

load_weighting_segments <- function(){
  # Weighting Segments
  # The weighting segment sheet doesn't include XS or XT, 
  # So to make it easier, I'm just having one line for each segment with it's respective tenure and spend splits
  # Then we create the 6 conditions for the various options given these splits
  read_excel(.HELPER_FILE_PATH, sheet = "Weighting_Segments") %>%
    filter(str_detect(WGT_Bucket, "MVI")) %>% # Removes SBS weights if they weren't removed in the helper file
    filter(str_detect(Tenure_Split, "\\+") & str_detect(Spend_Split, "\\+")) %>% # HTHS
    # Turn rows with multiple NA_Product_Codes into their own row to allow for joining with MVI data
    separate_rows(NA_Product_Code, sep = ", ") %>% 
    mutate(NA_Product_Code = trimws(NA_Product_Code), # just in case there were extra spaces
           pc_cond = paste0("NA_Product_Code == ", NA_Product_Code),
           # Turn {QUARTER}-9{SEGMENT} into {QUARTER}{SEGMENT}
           WV_Weighting_Segment = str_remove(WGT_Bucket, "-[0-9]"), 
           # Extract numeric values from tenure and spend conditions
           Tenure_Split = parse_number(Tenure_Split),
           Spend_Split = parse_number(Spend_Split) * 1000,
    )
}


load_cv_product_codes <- function(){
  read_excel(.HELPER_FILE_PATH, sheet = "CV_Product_Codes", .name_repair = "minimal")
}
# ------------------------------------------------------------------------------
apply_weighting_segments <- function(df, weighting_segments){
  df %>% left_join_suppress(weighting_segments) %>% 
    mutate(Tenure_Bucket = case_when(Tenure >= 6 & Tenure < Tenure_Split ~ "LT",
                                     Tenure >= Tenure_Split ~ "HT",
                                     TRUE ~ "XT"), # This can't occur as Tenure <6 is removed above
           Spend_Bucket  = case_when(Total_OD_Spend_USD > 0 & Total_OD_Spend_USD < Spend_Split ~ "LS",
                                     Total_OD_Spend_USD >= Spend_Split ~ "HS",
                                     TRUE ~ "XS"),
           
           # Create the weighting segment
           Weighting_Segment = if_else(Spend_Bucket == "XS",
                                       "MVINOSPEND",
                                       # Simple as combine the segment name, tenure bucket, and spend bucket (ie, MVIQ3230101 + HT + HS = MVIQ3230101HTHS)
                                       paste0(WV_Weighting_Segment, Tenure_Bucket, Spend_Bucket))) %>% 
    select(-ends_with("Bucket"), everything())
}

# ------------------------------------------------------------------------------
add_cv_var <- function(df, var, cv_vars_df){
  "
  Adds a created variable to the dataset based on the CV_Prods_Table provided in the instructions excel file
  "
  cli_alert_info("Adding: {var}", .envir = environment())
  
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
                               paste0("as.numeric(NA_Product_Code) == ", suppressWarnings(as.numeric(NA_Product_Code)))), # numeric PC because NA_Product_Code has no leading zeros in the CMS data
           full_cond = paste0(left_cond, " ~ '", !!ensym(var_name), "'"))
  
  # As an example the full_cond variable basically looks like "as.numeric(NA_Product_Code) == 199 ~ 'Y'" or
                                                            # "TRUE ~ N" for the else case
  
  # Apply the condition to the MVI sample dataframe to add the correct values for each variable
  df %>% mutate("{var_name}" := case_when(!!!rlang::parse_exprs(cv_vars_df$full_cond))) %>% return()
}


add_cv_product_codes <- function(df, cv_product_codes){
  "
  # Basically what's going on in the next few lines is we create a dataframe with all of the unique product codes in the sample dataset and then assign values for each of the created variables based on the conditions in the CV_Product_Codes sheet.
# We then join this to original dataframe by product code. 
  "
  # Create a table of product codes
  cv_vars_tab <- df %>% distinct(NA_Product_Code)
  
  log_section_start("Adding CV Product Codes", addition = '')
  
  # Append the new variables to the product code table based on the PM's instructions
  for (var in CV_VARS) cv_vars_tab <- cv_vars_tab %>% add_cv_var(var, cv_product_codes)
  
  # Apply the new variables to sample
  df %>% left_join_suppress(cv_vars_tab)
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

# ------------------------------------------------------------------------------
# Functions to update product codes and count what was changed
update_and_count_product_codes <- function(data, conditions){
  # Initialize the count column in the conditions data frame
  conditions$Count <- 0
  
  # Make a copy of the original data to apply changes to
  updated_data <- data
  
  # Loop over each condition and apply the changes
  for (i in seq_len(nrow(conditions))) {
    condition_str <- conditions$condition[i]
    new_value <- conditions$new_product_code[i]
    
    # Evaluate the condition
    condition_eval <- with(updated_data, eval(parse(text = condition_str)))
    
    # Apply the changes based on the condition
    updated_data$Product_Code[condition_eval] <- new_value
    
    # Count the number of changes made
    conditions$Count[i] <- sum(condition_eval, na.rm = TRUE)
  }
  
  # Print the condition counts
  output <- conditions %>% make_nice_table('Globally Changed PCT Code Counts')
  
  # Return the updated data only
  return(updated_data)
}

# ------------------------------------------------------------------------------
# Utility Functions
# ------------------------------------------------------------------------------
left_join_suppress <- function(x,y, ...){
  suppressMessages(left_join(x,y,...))
}

anti_join_suppress <- function(x,y, ...){
  suppressMessages(anti_join(x,y,...))
}

add_and_write_sheet <- function(wb, sheet_name, data){
  if (sheet_name %in% sheets(Diagnostic_WB)){
    cli_alert_info("Sheet {sheet_name} already present, overwriting data")
    removeWorksheet(wb, sheet_name)
  }
  addWorksheet(wb, sheet_name)
  writeData(wb, sheet_name, data)
}

# ------------------------------------------------------------------------------
# Logging and Validation Functions
# ------------------------------------------------------------------------------

# Message template constants
.MESSAGE_TEMPLATES <- list(
  "dupes" = list(
    "success" = "No {type} duplicates found",
    "error" = "Found {count} {type} duplicates"
  ),
  "validity" = list(
    "success" = "All {type} are valid",
    "error" = "Found {count} invalid {type}"
  ),
  "missing" = list(
    "success" = "No missing {type} values",
    "error" = "Found {count} missing {type} values"
  ),
  "counts" = list(
    "success" = "All {type} meet requested counts",
    "error" = "Found {count} mismatches in {type}"
  ),
  "removal" = list(
    "success" = "No {type} to remove",
    "error" = "Found {count} records to remove due to {type}"
  )
)


# Helper function for consistent section logging
log_section_start <- function(title, addition = "Validation") cli_h2("{title} {addition}", .envir = environment())

# Helper function for consistent check results
log_check_result <- function(condition, type, check_type = "validation", data = NULL, row_message = NULL, count = NULL, error_message = NULL, success_message=NULL) {
  if (condition) {
    # Success message
    cli_alert_success(coalesce(success_message, .MESSAGE_TEMPLATES[[check_type]][["success"]]))
  } else {
    # Error message
    error_template <- coalesce(error_message, .MESSAGE_TEMPLATES[[check_type]][["error"]])
    
    if (!is.null(count)) {
      cli_alert_danger(error_template)
      # Invisible return
      return(invisible())
    }
    
    count <- if (is.data.frame(data)) nrow(data) else length(data)
    cli_alert_danger(error_template)
    
    if (!is.null(data)) {
      if (is.data.frame(data)) {
        row_template <- ifelse(is.null(row_message), 
                               paste(names(row), row, sep = ": ", collapse = ", "),
                               row_message)
        walk(seq_len(nrow(data)), function(i) {
          row <- data[i,]
          cli_li(row_template)
        })
      } else {
        cli_li(if (is.null(row_message)) data else row_message)
      }
    }
  }
}

