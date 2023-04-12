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
   -  **From_OPs** - Any return files OPs sends. E.g., an edited version of *Misaligned_Product_Codes.csv* containing which codes we can delete.
      -  *MVI Qualtrics Instruction.xlsm* - This workbork is provided by OPs. It provides variable naming information, and values for created values. When recieved, it should be saved into this folder. 
   -  **RawData** - Raw Data from OPs
      -  *Weighting Framework* - Contains tenure and spend splits for weighting segments
      -  *PCT List Ex India* - AIF without India
      -  *PCT List India* - AIF of India: India does not have PCT codes


# Prepartory Steps to do each Quarter
## Creating MVI_Sample_Prep_Helper_QUARTER.xlsx

After pulling from Github, there is a file called `MVI_Sample_Prep_Helper_Templaye.xlsx` in your repository. Rename this to `MVI_Sample_Prep_Helper_QUARTER.xlsx`.

The `MVI_Sample_Prep_Helper_QUARTER.xlsx` contains 6 sheets :
- *MVI_Sample* : PML for the given quarter
- *PML_Info* : Pulls important information in a nice format from the PML using formulas to be used in the R scripts
- *Country_Info* : Information at the market level such as Country_Code, FileExt, Language_Index, and desired Filename
- *Variable_Info* : Variable renaming rules from Instruction file
- *CV_Product_Codes* : Values for created variables based on product code
- *Weighting_Segments* : Criteria for Tenure and Spend splits for each weighting segment

1. *MVI_Sample*

Simply copy and paste the PML for this quarter into this sheet.

2. *PML_Info*
This sheet is automatically created once the PML is put into MVI_Sample using formulas. There only needs to be a change to this sheet if new products are added. 
- **Note**: If there are product changes in the PML, there are two columns that are manually added that need to be modified. These are the *NA_Language_Index* and the *FileExt* columns. 
-  I made two versions
   -  One is the original one Rocco made, which requires us to just input the filled in lines from the PML and there's no blanks.
   -  The other has the first 500 lines in the PML file, which is then filtered in R. In this case, there are blanks in the helper file, but you do not need to add any new lines when new products are added. Although, adjusting *NA_Language_Index* and *FileExt* may be a little awkward at times.

1. *Country_Info*

This sheet shouldn't need to be updated often. Only if a new market is added or if the desired Filenames form has changed. The Filenames come from the file `QUARTER YEAR MVI File Names for COE.xlsx` from OPs. Just quickly verify these are correct. 

| NA_Country_Code | Country          | Country_Language | NA_Language_Index | FileExt | Language_Code | NA_Language_Code | CV_ICS_Region | Filename                                         |
|:---------------:|:-----------------:|:-----------------:|:-----------------:|:-------:|:-------------:|:----------------:|:-------------:|:------------------------------------------------:|
|       1         |     Australia     |     Australia     |        1          |         |     EN-AU     |      3081        |      ANZ       |    AmexGABMMVISurvey_AUS_ENAU_{MONTH}{YEAR}.csv    |
|       2         |       Canada       |  Canada English   |        1          |         |     EN-CA     |      4105        |     Canada     |    AmexGABMMVISurvey_CAN_ENCA_{MONTH}{YEAR}.csv    |
|       2         |       Canada       |   Canada French   |        2          |         |     FR-CA     |      3084        |     Canada     |    AmexGABMMVISurvey_CAN_FRCA_{MONTH}{YEAR}.csv    |
|       4         |        Italy       |        Italy       |        1          |         |       IT       |       16          |      EMEA       |    AmexGABMMVISurvey_ITA_IT_{MONTH}{YEAR}.csv     |


4. *Variable_Info*

This sheet is provided by OPs. 
 - Copy the first two columns (`Original Field Name` & `Name`) from sheet *Instructions_DATE* in `MVI Qualtrics Instruction.xlsm` located in the ***From_OPs*** folder into this sheet. 
 - Try not to override the column headers. R sets them back up, but try to keep them as they were in the template.
 - Removed the rows that say "Created Variables"
 - I currently have a column that has remove vs created because I was thinking about automating the final variable selection, but it's a little complicated, so we can ignore that column for now.

5. *CV_Product_Codes*

This sheet is provided by OPs. 

- Copy the inforation from sheet *CV_Product_Code Table* in `MVI Qualtrics Instruction.xlsm` located in the **From_OPs** folder into this sheet. 
- <span style="color:red">DO NOT OVERWRITE THE COLUMN HEADERS IN THE TEMPLATE</span>.
- If new created variables are added, make the new headers in the same format as the others.
  - Product_VARIABLE, VARIABLE, Comment_VARIABLE
  - **YOU ALSO NEED TO UPDATE THE CODE**

1. *Weighting_Segments*

This is copied directly from the *MVI QUARTER'YEAR Table* sheet of the `Weighting Framework` excel sheet. 
-  Try not to override the column headers. R sets them back up, but try to keep them as they were in the template.