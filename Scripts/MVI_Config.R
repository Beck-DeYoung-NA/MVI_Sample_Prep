# ==============================================================================
# Configuration File for MVI Sample Prep Script
# ==============================================================================
# This file contains file paths and other hard coded variables for the sample prep
# Any variables starting with "." are not actively used in the .Rmd and are hidden from the environment
# ==============================================================================

# Loads in necessary packages, and installs them if you don't have them installed
if (!require("glue")) install.packages("glue")

# Lets you embed variables into strings like python f-strings

f_str <- function(str, ...) {
  do.call(glue::glue, c(list(str), list(...))) %>% as.character()
}

# ------------------------------------------------------------------------------
# VARIABLES TO UPDATE
# ------------------------------------------------------------------------------

Q <- "Q1" # UPDATE
YEAR <- 2025 # UPDATE
MONTH <- "03" # UPDATE (This is the interview date)

MVIQ <- 'MVI{Q}{substr(YEAR, 3, 4)}' %>% f_str() # Updated dynamically

# If any new CVs are added, this needs to be updated
CV_VARS <- c("PML_FYF", "PML_WAIVER", "RCP_GOLD", "RCP_GREEN", "CENTURION", "PLATINUM", "COBRAND", "AIRLINE")

# ------------------------------------------------------------------------------
# FILE PATHS TO UPDATE
# ------------------------------------------------------------------------------
.HELPER_FILE_PATH <- "../MVI_Sample_Prep_Helper_{MVIQ}.xlsx" %>% f_str()
MARKET_FILES_PATH <- "../All_Sample_Files/Market_Files"

# Path to PCT Codes
PCT_LIST_PATH <- "../Supporting_Files/Q1_2025_MVI_PCT_Code_List_022125.csv" # UPDATE

.RAW_DATA_PATH <- "\\\\pm1/35-794/Quantitative/Sampling-Weighting/Files from CMS/{Q}" %>% f_str()

# ------------------------------------------------------------------------------