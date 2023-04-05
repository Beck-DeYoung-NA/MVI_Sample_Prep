# MVI Sample Prep Documentation
# Folder Strcture
-   Here **QUARTER** is referencing the current quarter and year. For example, for Q1 in 2023, **QUARTER** = *MVIQ123*
-   Ignore all the `init.txt` files. We do not store any data (.csv or .xlsx) files in Github, and Github does not store empty directories, so we include the `init.txt` in certain directories so that the folder structure is maintained in Github.
-   **MVI_Sample_Prep**
    -   `MVI_Sample_Prep_Helper_MONTH_YEAR.xlsx` - Contains important information on country identification, CV product codes, variable naming, weighting information, and the PML. This information is used for checking if the data lines up with what is requested.
    -   `MVI_Sample_Prep.Rproj` : The Rstudio project that should be used to run the scripts
    -   **Scripts** : Scripts for preparing samples
        -   `MVI_config_and_helpers.R` - Contains helper functions and file paths for the main scripts
        -   `MVI_Sample_Prep.html` - Output of the `MVI_Sample_Prep.Rmd` script including information such as warnings on whether or not tests were passed and descriptive tables.
        -   `MVI_Sample_Prep.Rmd` Loads in the raw data, performs all preparations to the data, and makes checks that information is as expected
    -   **Data** : Where intermediary storage files are outputted. There is just a single file in this folder
        -   *MVI_Sample_Combined_QUARTER.Rdata* - This is a file that contains all of the countries' data combined into a single dataframe. This is the first step in the `MVI_Sample_Prep.Rmd` script. We generate this file so that if you go back to the code after restarting R, you do not have to reload in all the raw data and join it together, you can just load in this file and it's all done for you quickly.
    -   **Files_to_send** : Contains datasets that should be sent to operations.
        -   *Cell_Level_Summary_MVIQ123.csv* - Contains Requested and Recieved counts at the cell level, as well as missing, zero, and negative spend counts prior to deduplication. 
        -   *Market_Level_Summary_MVIQ123.csv* - Summary of everything that happened during sample prep at the market level including counts of everything that was removed. This is the `Comparison` table from the old sample prep. 
        -   *PCT_not_in_AIF_MVIQ123.csv* - PCT codes not found in the AIF. Ops needs to tell us whether this was an error and to delete or to keep them.
        -   *Postal_codes_MVIQ123.csv* - Postal Codes for Bob Crown
        -   *Spend_Summary_MVIQ123.csv* - Descriptive statistics of Spend USD and Spend LOC prior to deduplication
    -   **Diagnostic_Files** : Contains datasets with information about what we did to the raw data such as spend flags and duplicate removals. These are not proactively sent to OPs but are available if need be.
        -  *Amex_ID_Dups_QUARTER.csv* - All *Amex_Customer_ID* duplicates at the customer level
        -  *Amex_ID_Dups_Summary_QUARTER.csv* : Frequencies of *Amex_Customer_ID* duplicates by Market
        -  *Member_Since_DOB_flags_QUARTER.csv* : Customers removed for falling under the following categories:
            -  1850 < *`YOB`* > YEAR-17
            -  1920 < *`Member_Since`* > YEAR - 1  
        -  *Missing_Spend_QUARTER.csv* - Customers with missing USD spend
        -  *Negative_Spend_QUARTER.csv* - Customers with negative USD spend
        -  *Removed_Tenure_QUARTER.csv* - Customers with too early tenure that are removed
        -  *Zero_Spend_QUARTER.csv*  - Customers with zero USD spend
   -  **All_Sample_Files**
      -  *MVI_Final_MVIQ123.csv* - Final version of the MVI sample file
      -  *MVI_Final_Checking_MVIQ123.csv* - Final version of the MVI sample file with extra variables to aid in verifying the output it correct
         - *`FileExt`*
         - *`Date_of_Birth`*
         - *`CV_COBRAND`*
         - *`CV_AIRLINE`*
         - *`COB`*
      -  **Market_Files** - Market Level Output Files
   -  **From_OPs** - Any return files OPs sends. E.g., an edited version of *Misaligned_Product_Codes.csv* containing which codes we can delete
   -  **RawData** - Raw Data from OPs
      -  *Weighting Framework*
      -  *PCT List Ex India*
      -  *PCT List India*
