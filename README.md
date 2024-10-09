# MVI Sample Prep Documentation

## Table of Contents

-   [Files and Information needed before sample prep](#files-and-information-needed-before-sample-prep-)
-   [Folder Strcture](#folder-strcture)
-   [Prepartory Steps to do each Quarter](#prepartory-steps-to-do-each-quarter)
    -   [Creating Sample_Prep_Helper_QUARTER.xlsx](#creating-sample_prep_helper_quarterxlsx)

### Files and Information needed before sample prep <a name="files_needed"></a>

- Check with Hanna Hoofar that we have the most updated versions in the PM Job drive (2024 was 34-716 -- but it will likely change in other years). 
    -   *MVI Qualtrics Instruction.xlsm*: `\\pm1\34-716\Quantitative\Sample-Weighting\Sample File Append`
    -   *CV_Reporting_Name Labels.xlsx* : `\\pm1\34-716\Quantitative\Sample-Weighting\Sample File Append`
    -   *Product Master List*: `\\pm1\34-716\Quantitative\Sample-Weighting\PMLs`
    -   *File Names for COE*: `\\pm1\34-716\Quantitative\Sample-Weighting\File Names for COE\QUARTER`
    -   *Files From CMS*: `\\pm1\34-716\Quantitative\Sampling-Weighting\Files from CMS\QUARTER`
-   Made by Rocco V. (in L Drive). Note that we usually use the weights and PCT list for the previous quarter because we get the AIF file after sample prep. So in Q3, you are normally using the Q2 weights and AIF file. Confirm with Rocco or Jim beforehand. 
    -   *Weighting Framework* : `L:\Amex.219\Weights`
    -   *PCT List*: `L:\Amex.219\AIF Files\PCT Code Lists` . Make sure it's the csv version Rocco creates.
    
# Folder Strcture  <a name="folder-structure"></a>
-   Here **QUARTER** is referencing the current quarter and year. For example, for Q1 in 2023, **QUARTER** = *MVIQ123*
-   Ignore all the `init.txt` files. We do not store any data (.csv or .xlsx) files in Github, and Github does not store empty directories, so we include the `init.txt` in certain directories so that the folder structure is maintained in Github.
    -   `MVI_Sample_Prep_Helper_Template.xlsx` - Contains important information on country identification, CV product codes, variable naming, weighting information, and the PML. This information is used for checking if the data lines up with what is requested.
        -   Renamed by you to *Sample_Prep_Helper_QUARTER.xlsx*
    -   `MVI_Sample_Prep.Rproj` : The Rstudio project that should be used to run the scripts
    -   **Scripts** : Scripts for preparing samples
        -   `MVI_Config_and_Helpers.R` - Contains helper functions and file paths for the main scripts
        -   *MVI_Sample_Prep.html* - Output of the `MVI_Sample_Prep.Rmd` script including information such as warnings on whether or not tests were passed and descriptive tables.
        -   `MVI_Sample_Prep.Rmd` Loads in the raw data, performs all preparations to the data, and makes checks that information is as expected
    -   **Files_to_Send** : Contains datasets that should be sent to operations.
        -   *MVI_Diagnostics_QUARTER.xlsx:* Has the following sheets
          
            -   *Cell_Level Summary:* Contains Requested and Recieved
                counts at the cell level, as well as missing, zero, and
                negative spend counts prior to deduplication.

            -   *Spend_Summary (Pre-Removals)*: Descriptive statistics
                of Spend USD and Spend LOC prior to deduplication

            -   *Removed_Tenure_Individuals* & *Removed_Tenure_Summary*:
                Individuals removed for low tenure, which is \<12 in
                Australia and New Zealand and \<6 elsewhere, and summary
                by market.

            -   *PCT_not_in_AIF_Individuals* & *PCT_not_in_AIF_Summary*:
                PCT Codes from the PML that do not line up with the AIF
                (based on country code, cell number, and NA product
                code)
                -   Ops needs to tell us whether this was an error and
                    to delete or to keep them.

            -   *AMEXID_Dupes_Ind* & *AMEXID_Dupes_Summary*: Individuals
                and summary of all duplicate amex id observations

            -   *Rem_AMEXID_Dupes_Ind* & *Rem_AMEXID_Dupes_Summary*:
                Individuals removed for having a duplicate Amex Customer
                ID. We kept the one observation with the highest
                priority.

            -   Removed\_*Member_Since_DOB* : Customers removed for
                falling under the following categories:

                -   1850 \< *`YOB`* \> YEAR-17
                -   1920 \< *`Member_Since`* \> YEAR (YEAR - 1 if
                    Quarter 1)

            -   *Market_Level_Summary*- Summary of everything that
                happened during sample prep at the market level
                including counts of everything that was removed. This is
                the `Comparison` table from the old sample prep.

        -   *Postal_Codes_QUARTER.csv* - Postal Codes for Bob Crown
    -   **Diagnostic_Files** : Contains datasets with information about
        what we did to the raw data such as spend flags. These are not
        proactively sent to OPs but are available if need be.
        -   *Missing_Spend_QUARTER.csv* - Customers with missing USD
            spend
        -   *Negative_Spend_QUARTER.csv* - Customers with negative USD
            spend
        -   *Zero_Spend_QUARTER.csv* - Customers with zero USD spend
-   **All_Sample_Files**
    -   *Final_Sample_QUARTER.csv* - Final version of the MVI sample file
    -   *Final_Checking_QUARTER-DATE.csv* - Final version of the MVI
        sample file with extra variables to aid in verifying the output
        it correct
        -   *`FileExt`*
        -   *`Date_of_Birth`*
        -   *`CV_COBRAND`*
        -   *`CV_AIRLINE`*
        -   *`COB`*
    -   *Final_Checking_QUARTER-DATE.xlsx* - This file needs to be
        manually created after the csv is outputted. This is for the PM
        to make their checks. Instructions for doing this are in the
        `MVI_Sample_Prep.Rmd` script when you create the csv.
    -   **Market_Files** - Market Level Output Files
-   **From_OPs** - Any files from OPs.
    -   *MVI Qualtrics Instruction.xlsm* - This workbork is provided by
        OPs. It provides variable naming information, and values for
        created values. When recieved, it should be saved into this
        folder.
    -   *Product Master List.xlsx* - The most up to date PML. The
        information is copied into a helper file later.
-   **Supporting_Files** - Weighting and PCT Lists from Analytics
    -   *Weighting Framework* - Contains tenure and spend splits for
        weighting segments
    -   *PCT List Final* - Created by Rocco from AIF file
-   **Temporary_Data** : Where intermediary storage files are outputted.
    There is just a single file in this folder
    -   *Sample_Combined_QUARTER.Rdata* - This is a file that
        contains all of the countries' data combined into a single
        dataframe. This is the first step in the `MVI_Sample_Prep.Rmd`
        script. We generate this file so that if you go back to the code
        after restarting R, you do not have to reload in all the raw
        data and join it together, you can just load in this file and
        it's all done for you quickly.
    -   *Final_Checking_QUARTER.Rdata* - Contains final checking dataset.
        This is so while waiting for the PM to review the final dataset
        and give the okay to create the individual CSVs, you can close
        Rstudio and just load this file in without having to run the
        entire script over again.
    -   MVI_Postals.Rdata- Postal codes for Bob Crown. This is so while
        waiting for the PM to review the final dataset and give the okay
        to create the individual CSVs, you can close Rstudio and just
        load this file in without having to run the entire script over
        again.

# Prepartory Steps to do each Quarter {#prepartory-steps-to-do-each-quarter}

## Creating Sample_Prep_Helper_QUARTER.xlsx

After pulling from Github, there is a file called
`Sample_Prep_Helper_Template.xlsx` in your repository. Rename this
to `Sample_Prep_Helper_QUARTER.xlsx`.

If you need a refresher on how to pull from github, consult the
doucmentation for [USCS Sample Prep](https://github.com/Beck-DeYoung-NA/USCS-Sample-Prep/). The link
for cloning is `https://github.com/Beck-DeYoung-NA/MVI_Sample_Prep.git`. As with USCS, it's best to create an alias so each new quarter you can just run `git mvi` and it does the cloning. 

The `Sample_Prep_Helper_QUARTER.xlsx` contains 7 sheets : 
- *MVI_Sample* : PML for the given quarter - *PML_Info* : Pulls important information in a nice format from the PML using formulas to be used in the R scripts
- *Country_Info* : Information at the market level such as Country_Code, FileExt, Language_Index, and desired Filename
- *Variable_Info* : Variable renaming rules from Instruction file
- *CV_Reporting_Names* : Proper reporting names for products
- *CV_Product_Codes* : Values for created variables based on product code
- *Weighting_Segments* : Criteria for Tenure and Spend splits for each weighting segment
- *PCT_Code_Changes* : Used if we need to update any PCT codes in the sample file (You will know later on in the code if you need to do this, it is not prepatory)

1.  *MVI_Sample*

Simply copy and paste the PML for this quarter into this sheet. You can override the column headers, but just make sure the format lines up with *PML_Info*. **DO NOT OVERRIDE COLUMN A, PASTE THE PML STARTING IN COLUMN B**
 - *Important Changes to be made*: Many quarters, the PML naming of the countries is inconsistent and we need to fix it. Specificially, for most countries that have a Language associated with them, only some of them have the country name with the language. For example, *THAILAND-Enlgish (34%)* would be listed for the first Thailand English product, but then every other Thailand English product would just be labaled as THAILAND. You need to make it consistent and drag *THAILAND-Enlgish (34%)* to all products for Thailand English. The same goes for any other country that is inconsistent. The *PML_Info* sheet will show you something is wrong when you see red cells in the Country column.

2.  *PML_Info* This sheet is automatically created once the PML is put into MVI_Sample using formulas. Read the comments in the sheet to verify info. 

3.  *Country_Info*

This sheet shouldn't need to be updated often. Only if a new market is added or if the desired Filenames form has changed. The Filenames come from the file `QUARTER YEAR MVI File Names for COE.xlsx` from OPs. The pattern for names has not changed since I began working on MVI, but just quickly verify these are correct. All of the different data sources refer to the countries differently, so this is how we remedy that.  

| NA_Country_Code |  Country  | Country_Name_PML | Country_Name_CMS | NA_Language_Index | File_Ext | Language_Code | NA_Language_Code | CV_ICS_Region |                   Filename                    |
|:------:|:------:|:------:|:------:|:------:|:------:|:------:|:------:|:------:| :------:|
|        1        | Australia |    AUSTRALIA     |    Australia     |         1         |          |     EN-AU     |       3081       |      ANZ      | AmexGABMMVISurvey_AUS_ENAU\_{MONTH}{YEAR}.csv |
|        2        |  Canada   |  CANADA-English  |  Canada English  |         1         |          |     EN-CA     |       4105       |    Canada     | AmexGABMMVISurvey_CAN_ENCA\_{MONTH}{YEAR}.csv |
|        2        |  Canada   |  CANADA-French   |  Canada French   |         2         |          |     FR-CA     |       3084       |    Canada     | AmexGABMMVISurvey_CAN_FRCA\_{MONTH}{YEAR}.csv |
|        4        |   Italy   |      ITALY       |      Italy       |         1         |          |      IT       |        16        |     EMEA      |  AmexGABMMVISurvey_ITA_IT\_{MONTH}{YEAR}.csv  |

5.  *Variable_Info*

This sheet is provided by OPs. 
- Copy the first two columns (`Original Field Name` & `Name`) from sheet *Instructions_DATE* in `MVI Qualtrics Instruction.xlsm` located in the ***From_OPs*** folder into this sheet.
- Try not to override the column headers. R sets them back up, but try to keep them as they were in the template. This is almost never updated. You will be told if there are new variables, so you can usually just leave it as is. 

6.  *CV_Reporting_Names*

Just copy and paste the information in from the `From Ops` folder. This file usually changes at the start of each year. 

7.  *CV_Product_Codes*

This sheet is provided by OPs.

-   Copy the inforation from sheet *CV_Product_Code Table* in
    `MVI Qualtrics Instruction.xlsm` located in the **From_OPs** folder
    into this sheet.
-   <r>DO NOT OVERWRITE THE COLUMN HEADERS IN THE TEMPLATE</r>.
-   There's no need to copy over *CV_COBRAND_AIRLINES*, but it will just
    be ignored if you do.
    -   We prefer to calculate *CV_COBRAND_AIRLINES* ourselves based on
        *CV_COBRAND* and *CV_AIRLINES*
-   If new created variables are added, make the new headers in the same
    format as the others.
    -   Product_VARIABLE, VARIABLE, Comment_VARIABLE
    -   **YOU ALSO NEED TO UPDATE THE CODE**
        -   Specifically the variable *CV_VARS* near the start of
            `MVI_config_and_helpers.R`

8.  *Weighting_Segments*

This is copied directly from the *Weighting Segment for Sample* sheet of
the `Weighting Framework` excel sheet. 
- Copy columns F-J (Wgt' Bucket-Spend) and paste as values.
- Try not to override the column headers. R sets them back up, but try to keep them as they were in the template.
- You can copy the SBS weights too if you do not want to find the end of the MVI weights. R will automatically filter for the MVI weights.


## Run The Script

- Open `MVI_Sample_Prep.Rproj`
- Open `MVI_Sample_Prep.Rmd`
- Follow the instructions inside the script
