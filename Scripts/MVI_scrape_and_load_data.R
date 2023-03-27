
library(tidyverse)
library(glue)
library(rvest)
library(readxl)

source("MVI_config_and_helpers.R")

load_raw_data <- function(country){
  "
  Function to extract the information for each country dataset and load it in
  "
  glue("Loading {country}") %>% print()
  
  # Get the list of files in the country sub-folder
  country_files <- glue("{RAW_DATA_PATH}/{country}") %>% list.files()
  
  # Get the country info from the sample prep file
  na_country_info <- country_codes[country_codes$`Country_Language` == country,]
  
  # identify which file contains the layout
  layout_file <- country_files[str_detect(country_files, "deliveryfilelayout.html")]
  
  # Read in the html layout file and extract all tables
  html_file_tables <- "{RAW_DATA_PATH}/{country}/{layout_file}" %>% glue() %>%
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
             col_types = cols(.default = 'c')) %>% # Default every import to character for now to not mess up formats 
    set_names(layout_table$New_Fieldname)
  
  if (nrow(tbl) != data_file$`Number of Records`) warning("Number of records not consistent")
  
  # Add Country specific info
  tbl %>% 
    mutate(Country = na_country_info$Country,
           NA_Country_Code = na_country_info$`NA Country Code`,
           NA_Language_Index = na_country_info$Language,
           FileExt = na_country_info$FileExt) %>% 
    return()
}


countries <- list.files(RAW_DATA_PATH) # Get list of countries in the Sampling Weighting Folder

var_mapping <- read_excel(HELPER_FILE_PATH, sheet = "Variable_Info") # Variable naming info

country_codes <- read_excel(HELPER_FILE_PATH, sheet = "Country_Info") # Country and language codes

all_data <- map(countries, load_raw_data) %>% 
  suppressMessages(reduce(full_join)) %>% 
  mutate(across(c("Tenure", "Total_OD_Spend_USD"), as.numeric))







# 
# # Checks
# 
# 
# count <- all_data %>%
#   group_by(NA_Country_Code,NA_Language_Index,Cell_Number,FileExt) %>% 
#   summarize(count = n())
# missing_spend <- all_data %>% filter(is.na(a)) %>% 
#   group_by(NA_Country_Code,NA_Language_Index,Cell_Number,FileExt) %>% 
#   summarize(noSpend = n())
# zero_spend <- all_data %>% filter(a == 0) %>% 
#   group_by(NA_Country_Code,NA_Language_Index,Cell_Number,FileExt) %>% 
#   summarize(zeroSpend = n())
# neg_spend <- all_data %>% filter(a < 0) %>% 
#   group_by(NA_Country_Code,NA_Language_Index,Cell_Number,FileExt) %>% 
#   summarize(NegativeSpend = n())
# 
# no_obs <- count %>% 
#   left_join(missing_spend) %>% 
#   left_join(zero_spend) %>% 
#   left_join(neg_spend) %>% 
#   arrange(NA_Country_Code, NA_Language_Index, FileExt)
# 
# no_obs %>% write_csv("../../../../2023/February/Qualtrics/Beck_Data/Info_for_Sample_Prep.csv")
# 
# 
# 
# 
# 
# 
# 
# 
# # To remove
# 
# to_remove<- c("Postal Code",
#               "MR Flag",
#               "MR Tier",
#               "MR Link Type Code",
#               "Criteria Spend/ROCs",
#               #"Date of Birth",
#               "Income",
#               "Unique Record Identifier (7 Digit)",
#               "Record Identifier",
#               "Gen Number",
#               "MRB Segments"
# )


# # Add new mappings for new variables
# var_mapping <- c("Cell Number" = "Cell_Number",
#                  "Postal Code" = "Postal_Code",
#                  "Country Code" = "Country_Code",
#                  "Product Code" = "Product_Code",
#                  "MR Flag" =  "MR_Flag",
#                  "MR Tier"   =   "MR_Tier",
#                  "Member Since" = "Member_Since",
#                  "Establishment Date"=  "Establishment_Date",
#                  "Tenure"  = "Tenure",
#                  "Gender Code" ="Gender_Code",
#                  "Language" = "Language",
#                  "MR Link Type Code" ="MR_Link_Type_Code",
#                  "MR Member Id"  = "MR_Member_Id",
#                  "Card Product" = "Card_Product",
#                  "Account Number (Last 5 digits only)"  = "Account_Number",
#                  "Amex Customer Id" = "Amex_Customer_Id",
#                  "Avg Overseas&Domestic ROCs" =   "Avg_OD_ROCs",
#                  "Date of Birth"= "Date_of_Birth",
#                  "Income" = "Income",
#                  "MR Points" = "MR_Points",
#                  "Total Overseas&Domestic Spend(Local Currency)" = "Total_OD_Spend_Local_Currency",
#                  "Total Overseas&Domestic Spend(USD)" = "Total_OD_Spend_USD",
#                  "Unique Record Identifier (15 Digit)" = "Unique_Record_Identifier15",
#                  "Record Identifier" = "Record_Identifier",
#                  "Gen Number" =  "Gen_Number")