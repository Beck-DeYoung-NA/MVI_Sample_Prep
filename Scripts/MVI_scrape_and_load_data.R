
library(tidyverse)
library(glue)
library(rvest)
library(readxl)

RAW_DATA_PATH <- "\\\\pm1/33-626/Quantitative/Sampling-Weighting/Files from CMS/Q1"

# Get list of countries in the Sampling Weighting Folder
countries <- list.files(RAW_DATA_PATH)

# var_mapping <- "\\\\sys_op/methods/Amex.219/SamplePrep/2023/February/Qualtrics/INSTRUCTIONS/MVI Qualtrics Instructions 2-10-23 4PM.xlsm" %>% 
#   read_excel(sheet = "Instructions_09_20_21") %>% 
#   select(og_field = `Original Field Name`, `Field`) %>% 
#   slice(1:which.max(og_field == "Created Variables")-1)


# # Add new mappings for new variables
var_mapping <- c("Cell Number" = "Cell_Number",
                 "Postal Code" = "Postal_Code",
                 "Country Code" = "Country_Code",
                 "Product Code" = "Product_Code",
                 "MR Flag" =  "MR_Flag",
                 "MR Tier"   =   "MR_Tier",
                 "Member Since" = "Member_Since",
                 "Establishment Date"=  "Establishment_Date",
                 "Tenure"  = "Tenure",
                 "Gender Code" ="Gender_Code",
                 "Language" = "Language",
                 "MR Link Type Code" ="MR_Link_Type_Code",
                 "MR Member Id"  = "MR_Member_Id",
                 "Card Product" = "Card_Product",
                 "Account Number (Last 5 digits only)"  = "Account_Number",
                 "Amex Customer Id" = "Amex_Customer_Id",
                 "Avg Overseas&Domestic ROCs" =   "Avg_OD_ROCs",
                 "Date of Birth"= "Date_of_Birth",
                 "Income" = "Income",
                 "MR Points" = "MR_Points",
                 "Total Overseas&Domestic Spend(Local Currency)" = "Total_OD_Spend_Local_Currency",
                 "Total Overseas&Domestic Spend(USD)" = "Total_OD_Spend_USD",
                 "Unique Record Identifier (15 Digit)" = "Unique_Record_Identifier15",
                 "Record Identifier" = "Record_Identifier",
                 "Gen Number" =  "Gen_Number")

# Load in the country and language codes

country_codes <- read_excel("\\\\sys_op/methods/Amex.219/SamplePrep/Training/Qualtrics/Diagnostic files/Q4'22 Product Master List (Sample Process Summary version) COPY .xlsx",
                            sheet = "LLFN (2022Q4)",
                            skip=1) %>% 
  # These are odd and haven't thought about how to include them so I removed them for now
  filter(!str_detect(`Project Name`, "Request 2")) %>% 
  select(`NA Country Code`, Country, `Country Language`, Language, FileExt) %>% 
  drop_na(`Country Language`)

load_raw_data <- function(country){
  
  #Function to extract the information for each country dataset and load it in
  
  print("Loading {country}" %>% glue())
  
  country_files <- "{RAW_DATA_PATH}/{country}" %>% glue() %>% list.files()
  
  na_country_info <- country_codes[country_codes$`Country Language` == str_remove(country, " - Supplemental"),]
  
  layout_file <- country_files[str_detect(country_files, "deliveryfilelayout.html")]
  
  html_file_tables <- "{RAW_DATA_PATH}/{country}/{layout_file}" %>% glue() %>%
    read_html() %>% html_nodes("table") 
  
  data_file <- html_file_tables[[3]] %>% html_table(fill = T, header = T)
  
  data_filename <- data_file$`Final File Name` %>% paste0(".txt")
  
  layout_table <- html_file_tables[[4]] %>% html_table(fill = T, header = T) %>%
    #filter(!`Field Name` %in% to_remove) %>% 
    #left_join(var_mapping, by =c("Field Name" = "og_field"))
    #mutate(`Field Name` = var_mapping$Field[`Field Name` == var_mapping$og_field])
    mutate(`Field Name` = ifelse(`Field Name` %in% names(var_mapping), var_mapping[`Field Name`], paste("rem_",`Field Name`)))
  
  # Load in the data
  tbl <- "{RAW_DATA_PATH}/{country}/{data_filename}" %>% glue() %>% 
    read_fwf(col_positions = fwf_widths(layout_table$Length),
             col_types = cols(.default = 'c')) %>% 
    set_names(layout_table$`Field Name`)
  
  if (nrow(tbl) != data_file$`Number of Records`) warning("Number of records not consistent")
  
  # Add Country specific info
  tbl %>% 
    mutate(Country = na_country_info$Country,
           NA_Country_Code = na_country_info$`NA Country Code`,
           NA_Language_Index = na_country_info$Language,
           FileExt = na_country_info$FileExt) %>% 
    return()
}


all_data <- map(countries, load_raw_data) %>% 
  reduce(full_join) %>% 
  mutate(Tenure = as.numeric(Tenure),
         a = as.numeric(Total_OD_Spend_USD))


















# Checks


count <- all_data %>%
  group_by(NA_Country_Code,NA_Language_Index,Cell_Number,FileExt) %>% 
  summarize(count = n())
missing_spend <- all_data %>% filter(is.na(a)) %>% 
  group_by(NA_Country_Code,NA_Language_Index,Cell_Number,FileExt) %>% 
  summarize(noSpend = n())
zero_spend <- all_data %>% filter(a == 0) %>% 
  group_by(NA_Country_Code,NA_Language_Index,Cell_Number,FileExt) %>% 
  summarize(zeroSpend = n())
neg_spend <- all_data %>% filter(a < 0) %>% 
  group_by(NA_Country_Code,NA_Language_Index,Cell_Number,FileExt) %>% 
  summarize(NegativeSpend = n())

no_obs <- count %>% 
  left_join(missing_spend) %>% 
  left_join(zero_spend) %>% 
  left_join(neg_spend) %>% 
  arrange(NA_Country_Code, NA_Language_Index, FileExt)

no_obs %>% write_csv("../../../../2023/February/Qualtrics/Beck_Data/Info_for_Sample_Prep.csv")








# To remove

to_remove<- c("Postal Code",
              "MR Flag",
              "MR Tier",
              "MR Link Type Code",
              "Criteria Spend/ROCs",
              #"Date of Birth",
              "Income",
              "Unique Record Identifier (7 Digit)",
              "Record Identifier",
              "Gen Number",
              "MRB Segments"
)