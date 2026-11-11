# Some Went to Work While Others Stayed Home: replication files

Data and code to reproduce the figures and the union membership results in

Lamare, J. Ryan. "Some Went to Work While Others Stayed Home: Covid-Era Google Mobility Data and the Double-Edged Implications of Tracking Workers." Chapter prepared for the 2027 LERA Research Volume, *Emerging Data and Methods in Work and Employment Relations*.

The chapter builds on

Lamare, J. Ryan, Richard A. Benton and Patricia Michel Tabarani. 2024. "An Empirical Analysis of Race and Political Partisanship Effects on Workplace Mobility Patterns during Lockdown, Reopening, and Endemic COVID-19." *ILR Review* 77(4): 475-505. https://doi.org/10.1177/00197939241246510

and the county data and the Figure 1 estimates here are taken from that article. This repository does not reproduce the article's own tables.

The code takes Google's COVID-19 Community Mobility Reports and a county-level file and produces the national weekly series in Figure 2, the coverage counts quoted in the text, the union membership regressions, and the predictions in Figure 3. The numbers plotted in Figure 1 are included as a data file. All results are written to the output folder.

Google's files are not included here. They are free to download but Google asks users to agree to its Terms of Service first, so you will need to download them yourself as described below. The county file for the union models is included.

## Data

**Google COVID-19 Community Mobility Reports.** Download `Region_Mobility_Report_CSVs.zip` from https://www.google.com/covid19/mobility/ and take the three United States files from it:

    2020_US_Region_Mobility_Report.csv
    2021_US_Region_Mobility_Report.csv
    2022_US_Region_Mobility_Report.csv

Google stopped updating the reports on October 15, 2022. If no folder is given, the Figure 2 script downloads the zip file into `data/google/` and extracts the three files itself.

**County file.** `data/county_union_extract.csv` has one row per county and year (2020, 2021 and 2022) for the 280 counties that the Current Population Survey identifies, 278 of which enter the models. It holds only the variables the models use:

    workplacemob, residentmob      county averages of Google's daily workplace and residential figures over the same
                                   window in each year (February 28 or 29 to April 23), as proportions
    um_cps, uc_cps                 union membership and union coverage as a share of employment
    blackalone_prop                share of Black residents
    per_gop                        Republican share of the 2016 presidential vote
    the remaining variables        the county controls used in Lamare, Benton and Tabarani (2024), and state

The mobility averages and the county controls are those built for Lamare, Benton and Tabarani (2024), where their construction is described. The demographic, economic and rural-urban measures come from the U.S. Census Bureau and the U.S. Department of Agriculture, and the vote shares from the MIT Election Data and Science Lab. The union measures are members and covered workers divided by employment in the county file of the `labordata/detailed-union-density` repository (https://github.com/labordata/detailed-union-density), which pools the Current Population Survey outgoing rotation groups for 2016 to 2020.

**Figure 1.** `data/figure1_monthly_estimates.csv` holds the two lines in Figure 1 and their 90 percent confidence bounds, which the figure does not draw. These are not new estimates. They are the monthly full-model coefficients for workplace mobility in the online appendix to Lamare, Benton and Tabarani (2024), Supplemental Tables 2-4, each multiplied by the gap between counties at the 90th and 10th percentiles of the measure (31.4 versus 0.6 percent Black residents, and 78.8 versus 40.2 percent for the 2016 Trump vote).

## Running the code

1. Run the Figure 2 script from the package folder. With no argument it downloads Google's files (about 100 MB); otherwise give it the folder that holds the three United States files.

       python3 code/01_figure2_national_weekly.py
       python3 code/01_figure2_national_weekly.py /path/to/folder

2. Run `master.do` from the package folder (in batch mode, `stata-se -b do master.do` from within the folder). It runs the two do-files in `code/`.

The full run takes a few seconds once Google's files are downloaded.

    code/01_figure2_national_weekly.py         Figure 2 weekly series, numbers quoted with it, coverage counts
    code/02_union_models.do                    union membership models, 2020 to 2022
    code/03_figure3_predictions.do             Figure 3 predictions and the effect sizes quoted with it

The Figure 2 series is written to `data/figure2_national_weekly.csv`. Everything else goes to the output folder:

    figure2_summary.txt                        the numbers quoted in the text alongside Figure 2
    category_coverage.csv                      share of county-days with a figure, by category
    union_models_main.csv, .rtf                main-effects models, travel to work and time at home
    union_models_interactions.csv, .rtf        union membership interacted with Black share and with Trump vote
    figure3_predictions.csv                    the lines and confidence intervals in Figure 3
    figure3_margins.log                        predictions at the 10th and 90th percentiles of both measures, and the
                                               difference in the Black-share effect between low and high union membership

The files from my own run are in `output/` for comparison.

## Software

Python 3 with `pandas`. Stata 18 (SE). The code uses `estout` (`eststo`, `esttab`) from SSC:

    ssc install estout

## Notes

The weekly series in Figure 2 averages Google's daily national figures over full Monday to Sunday weeks, so the first and last partial weeks of the reports are dropped and the series runs from the week ending February 23, 2020 to the week ending October 9, 2022.

In the coverage counts, a day on which Google's files have no row for a county is counted as a day with no figure for that county in any category.
