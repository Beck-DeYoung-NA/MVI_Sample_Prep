---
editor_options: 
  markdown: 
    wrap: 72
---

```{=html}
<style>
r { color: Red }
o { color: Orange }
g { color: Green }
</style>
```
# MVI Sample Prep Documentation {#mvi-sample-prep-documentation}

## Table of Contents {#table-of-contents}

-   [MVI Sample Prep Documentation](#mvi-sample-prep-documentation)
    -   [Table of Contents](#table-of-contents)
        -   [Files and Information needed before sample
            prep](#files-and-information-needed-before-sample-prep-)
-   [Folder Strcture](#folder-strcture-)
-   [Prepartory Steps to do each
    Quarter](#prepartory-steps-to-do-each-quarter)
    -   [Creating
        MVI_Sample_Prep_Helper_QUARTER.xlsx](#creating-mvi_sample_prep_helper_quarterxlsx)

### Files and Information needed before sample prep <a name="files_needed"></a>

-   Theo Wood: Make sure it's the most updated versions
    -   *MVI Qualtrics Instruction.xlsm*
    -   *CV_Reporting_Name Labels.xlsx*
-   Allie Graff
    -   *Product Master List*
    -   *File Names for COE*
    -   *Files From CMS* - all the raw data
-   Made by Rocco V.
    -   *Weighting Framework*
    -   *PCT List Ex India*
    -   *PCT List India* \# Folder Strcture
        <a name="folder-structure"></a>
-   Here **QUARTER** is referencing the current quarter and year. For
    example, for Q1 in 2023, **QUARTER** = *MVIQ123*
-   Ignore all the `init.txt` files. We do not store any data (.csv or
    .xlsx) files in Github, and Github does not store empty directories,
    so we include the `init.txt` in certain directories so that the
    folder structure is maintained in Github.
    -   `MVI_Sample_Prep_Helper_Template.xlsx` - Contains important
        information on country identification, CV product codes,
        variable naming, weighting information, and the PML. This
        information is used for checking if the data lines up with what
        is requested.
        -   Renamed by you to *MVI_Sample_Prep_Helper_QUARTER.xlsx*
    -   `MVI_Sample_Prep.Rproj` : The Rstudio project that should be
        used to run the scripts
    -   **Scripts** : Scripts for preparing samples
        -   `MVI_Config_and_Helpers.R` - Contains helper functions and
            file paths for the main scripts
        -   *MVI_Sample_Prep.html* - Output of the `MVI_Sample_Prep.Rmd`
            script including information such as warnings on whether or
            not tests were passed and descriptive tables.
        -   `MVI_Sample_Prep.Rmd` Loads in the raw data, performs all
            preparations to the data, and makes checks that information
            is as expected
    -   **Files_to_Send** : Contains datasets that should be sent to
        operations.
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

            ```{=html}
            <!-- -->
            ```
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
    -   *MVI_Final_QUARTER.csv* - Final version of the MVI sample file
    -   *MVI_Final_Checking_QUARTER-DATE.csv* - Final version of the MVI
        sample file with extra variables to aid in verifying the output
        it correct
        -   *`FileExt`*
        -   *`Date_of_Birth`*
        -   *`CV_COBRAND`*
        -   *`CV_AIRLINE`*
        -   *`COB`*
    -   *MVI_Final_Checking_QUARTER-DATE.xlsx* - This file needs to be
        manually created after the csv is outputted. This is for the PM
        to make their checks. Instructions for doing this are in the
        `MVI_Sample_Prep.Rmd` script when you create the csv.
    -   **Market_Files** - Market Level Output Files
-   **From_OPs** - Any return files OPs sends. E.g., an edited version
    of *Misaligned_Product_Codes.csv* containing which codes we can
    delete.
    -   *MVI Qualtrics Instruction.xlsm* - This workbork is provided by
        OPs. It provides variable naming information, and values for
        created values. When recieved, it should be saved into this
        folder.
    -   *Product Master List.xlsx* - The most up to date PML. The
        information is copied into a helper file later.
-   **Supporting_Files** - Raw Data from OPs. Save the following files
    here when they are recieved
    -   *Weighting Framework* - Contains tenure and spend splits for
        weighting segments
    -   *PCT List Ex India* - AIF without India
    -   *PCT List India* - AIF of India: India does not have PCT codes
-   **Temporary_Data** : Where intermediary storage files are outputted.
    There is just a single file in this folder
    -   *MVI_Sample_Combined_QUARTER.Rdata* - This is a file that
        contains all of the countries' data combined into a single
        dataframe. This is the first step in the `MVI_Sample_Prep.Rmd`
        script. We generate this file so that if you go back to the code
        after restarting R, you do not have to reload in all the raw
        data and join it together, you can just load in this file and
        it's all done for you quickly.
    -   *MVI_Final_Checking.Rdata* - Contains final checking dataset.
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

## Creating MVI_Sample_Prep_Helper_QUARTER.xlsx

After pulling from Github, there is a file called
`MVI_Sample_Prep_Helper_Template.xlsx` in your repository. Rename this
to `MVI_Sample_Prep_Helper_QUARTER.xlsx`.

If you need a refresher on how to pull from github, consult the
doucmentation for [USCS Sample
Prep](https://github.com/Beck-DeYoung-NA/USCS-Sample-Prep/). The link
for cloning is `https://github.com/Beck-DeYoung-NA/MVI_Sample_Prep.git`.

The `MVI_Sample_Prep_Helper_QUARTER.xlsx` contains 6 sheets : -
*MVI_Sample* : PML for the given quarter - *PML_Info* : Pulls important
information in a nice format from the PML using formulas to be used in
the R scripts - *Country_Info* : Information at the market level such as
Country_Code, FileExt, Language_Index, and desired Filename -
*Variable_Info* : Variable renaming rules from Instruction file -
*CV_Reporting_Names* : Proper reporting names for products -
*CV_Product_Codes* : Values for created variables based on product
code - *Weighting_Segments* : Criteria for Tenure and Spend splits for
each weighting segment

1.  *MVI_Sample*

Simply copy and paste the PML for this quarter into this sheet. You can
override the column headers, but just make sure the format lines up with
*PML_Info*.

2.  *PML_Info* This sheet is automatically created once the PML is put
    into MVI_Sample using formulas. There only needs to be a change to
    this sheet if new products are added.

-   **Note**: If there are product changes in the PML, there are two
    columns that are manually added that need to be modified. These are
    the *NA_Language_Index* and the *FileExt* columns.
-   I made two versions. The code uses the first one, the second is
    redundant at the moment.
    -   One is the original one Rocco made, which requires us to just
        input the filled in lines from the PML and there's no blanks.
    -   The other has the first 500 lines in the PML file, which is then
        filtered in R. In this case, there are blanks in the helper
        file, but you do not need to add any new lines when new products
        are added. Although, adjusting *NA_Language_Index* and *FileExt*
        may be a little awkward at times.

3.  *Country_Info*

This sheet shouldn't need to be updated often. Only if a new market is
added or if the desired Filenames form has changed. The Filenames come
from the file `QUARTER YEAR MVI File Names for COE.xlsx` from OPs. The
pattern for names has not changed since I began working on MVI, but just
quickly verify these are correct.

| NA_Country_Code |  Country  | Country_Language | NA_Language_Index | FileExt | Language_Code | NA_Language_Code | CV_ICS_Region |                   Filename                    |
|:------:|:------:|:------:|:------:|:------:|:------:|:------:|:------:|:------:|
|        1        | Australia |    Australia     |         1         |         |     EN-AU     |       3081       |      ANZ      | AmexGABMMVISurvey_AUS_ENAU\_{MONTH}{YEAR}.csv |
|        2        |  Canada   |  Canada English  |         1         |         |     EN-CA     |       4105       |    Canada     | AmexGABMMVISurvey_CAN_ENCA\_{MONTH}{YEAR}.csv |
|        2        |  Canada   |  Canada French   |         2         |         |     FR-CA     |       3084       |    Canada     | AmexGABMMVISurvey_CAN_FRCA\_{MONTH}{YEAR}.csv |
|        4        |   Italy   |      Italy       |         1         |         |      IT       |        16        |     EMEA      |  AmexGABMMVISurvey_ITA_IT\_{MONTH}{YEAR}.csv  |

5.  *Variable_Info*

This sheet is provided by OPs. - Copy the first two columns
(`Original Field Name` & `Name`) from sheet *Instructions_DATE* in
`MVI Qualtrics Instruction.xlsm` located in the ***From_OPs*** folder
into this sheet. - Try not to override the column headers. R sets them
back up, but try to keep them as they were in the template.

1.  *CV_Reporting_Names*

This has previously been located in a file in the subdirectory:
`Sample-Weighting/Sample File Append` of the main project directory
(where the raw data comes from). Just copy and paste it in.

1.  *CV_Product_Codes*

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

1.  *Weighting_Segments*

This is copied directly from the *Weighting Segment for Sample* sheet of
the `Weighting Framework` excel sheet. Copy columns F-J (Wgt'
Bucket-Spend) and paste as values. - Try not to override the column
headers. R sets them back up, but try to keep them as they were in the
template. - You can copy the SBS weights too if you do not want to find
the end of the MVI weights. R will automatically filter for the MVI
weights.
