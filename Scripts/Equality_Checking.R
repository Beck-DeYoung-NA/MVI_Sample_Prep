x <- sapply(MVI_final, typeof) %>% unname() %>% as.vector()
x1 <- x
c_types <- str_extract(x1[-42], "^[a-z]") %>% paste(collapse = "")

market_files <- '\\\\sys_op/methods/Amex.219/SamplePrep/2023/February/Qualtrics/Output_Sample_Files/MarketFiles'
m_files <- list.files(market_files, pattern = "\\.csv")

# Get the country info from the sample prep file
country_codes <- country_codes %>% mutate(Filename2 = gsub("{MONTH}{YEAR}", "032023", Filename, fixed = T))



for (i in 1:29){
c <- 14 ; country <- countries[c] ; m_file <- m_files[c]
na_country_info <- country_codes[country_codes$Filename2 == m_file,]

sas <- read_csv(file.path(market_files, m_file),
                col_types = c_types) %>% 
  mutate(across(c("MYCA_Indicator",
                  "Paperless_Indicator",
                  "CV_COBRAND_AIRLINES",
                  "GENERATION",
                  "Establishment_Date"), ~if_else(is.na(.), "", .)),
         #MR_Member_ID = as.numeric(MR_Member_ID) %>% as.character(),
         MR_Member_ID = str_pad(MR_Member_ID, 12, "left", "0")) %>% 
  arrange(UID)


r <- MVI_final %>%  select(-Filename) %>% 
  filter(LANGUAGE_CODE == na_country_info$Language_Code & COUNTRY_CODE == na_country_info$NA_Country_Code)  %>% 
  mutate(MR_Member_ID = str_pad(MR_Member_ID, 12, "left", "0"),
         SUBJECT_LINE_INSERTION = gsub("\u00A0", "", SUBJECT_LINE_INSERTION, fixed = TRUE) %>% trimws()) %>% 
  arrange(UID) %>% set_names(names(sas)) 

r2 <- r %>% filter(UID %in% sas$UID) %>% select(-MR_Member_ID)
sas2 <- sas %>% filter(UID %in% r$UID)  %>% select(-MR_Member_ID)

all.equal(r2, sas2, check.attributes = F)
}


# 
# test <- MVI_Sample_new_vars %>% filter(NA_Country_Code == 41) %>% filter(NA_Language_Index == 2)
# 
# test3 <- r %>% filter(!UID %in% sas$UID)
# 
# 
x = r2 %>% group_by(NAXION_PRODUCT_CODE, CV_PML_FYF) %>%
  summarize(n = n())

y = sas2 %>% group_by(NAXION_PRODUCT_CODE, CV_PML_FYF) %>%
  summarize(n = n())


x = r2 %>% group_by(Cell_Number, SUBJECT_LINE_INSERTION) %>%
  summarize(n = n())

y = sas2 %>% group_by(Cell_Number, SUBJECT_LINE_INSERTION) %>%
  summarize(n = n())

x2 <- x %>% filter(!SUBJECT_LINE_INSERTION %in% y$SUBJECT_LINE_INSERTION)
y2 <- y %>% filter(!SUBJECT_LINE_INSERTION %in% x$SUBJECT_LINE_INSERTION)


test <- aif_pct %>% left_join(PML) %>% 
  distinct(NA_Country_Code, Cell_Number, Card_ProductAIF, Product_Color) %>% 
  arrange(NA_Country_Code, Cell_Number)
