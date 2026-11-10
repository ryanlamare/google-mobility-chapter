* Master do-file for the union example in Lamare, "Some Went to Work While Others Stayed Home"
* Run this file from the package folder. It reads data/county_union_extract.csv and writes to output/.

clear all
set more off

cap mkdir "output"

log using "output/master.log", text replace name(master)

do "code/02_union_models.do"
do "code/03_figure3_predictions.do"

log close master
