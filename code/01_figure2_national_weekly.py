"""Figure 2 and the category coverage counts, from Google's COVID-19 Community Mobility Reports.

Usage, from the package folder:

    python3 code/01_figure2_national_weekly.py [folder]

where the folder holds Google's three US region files (2020_US_Region_Mobility_Report.csv and the
2021 and 2022 files). With no folder given, the script downloads Region_Mobility_Report_CSVs.zip
from Google (about 100 MB) into data/google/ and takes the three files from there.

Writes:
    data/figure2_national_weekly.csv     the three lines in Figure 2
    output/figure2_summary.txt           the numbers quoted in the text alongside Figure 2
    output/category_coverage.csv         how complete each category is in the US county files
"""
import os
import sys
import urllib.request
import zipfile

import pandas as pd

URL = "https://www.gstatic.com/covid19/mobility/Region_Mobility_Report_CSVs.zip"
FILES = [f"{yr}_US_Region_Mobility_Report.csv" for yr in (2020, 2021, 2022)]
CATEGORIES = ["retail_and_recreation", "grocery_and_pharmacy", "parks", "transit_stations", "workplaces", "residential"]

if len(sys.argv) > 1:
    folder = sys.argv[1]
else:
    folder = os.path.join("data", "google")
    os.makedirs(folder, exist_ok=True)
    if not all(os.path.exists(os.path.join(folder, f)) for f in FILES):
        zip_path = os.path.join(folder, "Region_Mobility_Report_CSVs.zip")
        if not os.path.exists(zip_path):
            urllib.request.urlretrieve(URL, zip_path)
        with zipfile.ZipFile(zip_path) as z:
            for f in FILES:
                z.extract(f, folder)

raw = pd.concat([pd.read_csv(os.path.join(folder, f), low_memory=False) for f in FILES], ignore_index=True)
raw["date"] = pd.to_datetime(raw["date"])
raw = raw.rename(columns={c + "_percent_change_from_baseline": c for c in CATEGORIES})

# National series: the rows with no state or county are the figures for the United States as a whole
us = raw[raw["sub_region_1"].isna() & raw["sub_region_2"].isna() & raw["metro_area"].isna()].set_index("date").sort_index()
assert us.index.is_unique

# Weekly averages over full Monday to Sunday weeks, labelled by the Sunday that ends the week
weekly = us[["workplaces", "retail_and_recreation", "residential"]].resample("W-SUN").mean()
full_weeks = us["workplaces"].resample("W-SUN").count() == 7
weekly = weekly[full_weeks].round(1).rename(columns={"residential": "time_at_home"})
weekly.index.name = "week_ending"
weekly.to_csv(os.path.join("data", "figure2_national_weekly.csv"))

# Numbers quoted in the text
last8 = us[(us.index > weekly.index[-9]) & (us.index <= weekly.index[-1])]
weekend = last8.index.dayofweek >= 5
lines = [
    f"Weeks in Figure 2: {len(weekly)}, weeks ending {weekly.index[0].date()} to {weekly.index[-1].date()}",
    f"Week ending 2020-04-12: workplaces {weekly.loc['2020-04-12', 'workplaces']}, "
    f"retail and recreation {weekly.loc['2020-04-12', 'retail_and_recreation']}",
    f"Last eight weeks ({last8.index[0].date()} to {last8.index[-1].date()}): "
    f"retail and recreation {last8['retail_and_recreation'].mean():.1f}, workplaces {last8['workplaces'].mean():.1f}, "
    f"time at home {last8['residential'].mean():.1f}",
    f"Workplaces in the last eight weeks: weekdays {last8.loc[~weekend, 'workplaces'].mean():.1f}, "
    f"weekends {last8.loc[weekend, 'workplaces'].mean():.1f}",
    "Lowest five weeks for workplaces: "
    + ", ".join(f"{d.date()} ({v})" for d, v in weekly["workplaces"].nsmallest(5).items()),
    "Lowest five weeks for workplaces after June 2020: "
    + ", ".join(f"{d.date()} ({v})" for d, v in weekly.loc["2020-07-01":, "workplaces"].nsmallest(5).items()),
    f"Weeks in which workplaces is at or above retail and recreation: "
    f"{int((weekly['workplaces'] >= weekly['retail_and_recreation']).sum())}",
]
with open(os.path.join("output", "figure2_summary.txt"), "w") as f:
    f.write("\n".join(lines) + "\n")

# Coverage: for the counties that appear in the files, the share of county-days with a figure in each
# category. A day with no row for a county counts as a day with no figure.
county = raw[raw["census_fips_code"].notna()]
n_counties = county["census_fips_code"].nunique()
n_days = raw["date"].nunique()
coverage = pd.DataFrame({
    "category": CATEGORIES,
    "counties_with_any_figure": [county.loc[county[c].notna(), "census_fips_code"].nunique() for c in CATEGORIES],
    "percent_of_county_days_with_a_figure": [round(100 * county[c].notna().sum() / (n_counties * n_days), 1) for c in CATEGORIES],
})
coverage.to_csv(os.path.join("output", "category_coverage.csv"), index=False)
with open(os.path.join("output", "figure2_summary.txt"), "a") as f:
    f.write(f"US counties in the files: {n_counties}; days: {n_days} "
            f"({raw['date'].min().date()} to {raw['date'].max().date()})\n")
print("\n".join(lines))
print(coverage.to_string(index=False))
