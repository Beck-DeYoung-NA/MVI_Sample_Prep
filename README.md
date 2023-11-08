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
