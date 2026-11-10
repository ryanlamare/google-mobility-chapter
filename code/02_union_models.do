* Union membership models for the worked example in the chapter
* County averages of workplace mobility and time at home in the same February to April window of 2020, 2021 and 2022,
* regressed on county union membership, the share of Black residents and the 2016 Trump vote, with the controls and
* state fixed effects used in Lamare, Benton and Tabarani (2024). The sample is the counties identified in the CPS.

import delimited using "data/county_union_extract.csv", clear varnames(1) asdouble

local controls amindianalone_prop asianalone_prop hawpacalone_prop hispanic_prop essential_perc ///
    female_prop prop_age18to64 prop_age65plus percentofadultswithlessthanahigh ///
    percentofadultswithahighschooldi percentofadultscompletingsomecol unemployment_rate_2018 ///
    medhhinc_2018 i.ruralurban_continuumcode_2013 i.state_n

eststo clear
foreach yr in 2020 2021 2022 {
    foreach y in workplacemob residentmob {
        /*main effects*/
        eststo main_`y'_`yr': quietly reg `y' um_cps blackalone_prop per_gop `controls' if year==`yr'
        /*union membership interacted with Black share and with Trump vote*/
        eststo int_`y'_`yr': quietly reg `y' c.um_cps##c.blackalone_prop c.um_cps##c.per_gop `controls' if year==`yr'
    }
}

esttab main_* using "output/union_models_main.csv", replace b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles r2 plain noomitted nobaselevels drop(*state_n *ruralurban_continuumcode_2013)
esttab int_* using "output/union_models_interactions.csv", replace b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles r2 plain noomitted nobaselevels drop(*state_n *ruralurban_continuumcode_2013)
esttab main_* using "output/union_models_main.rtf", replace b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles r2 nogaps noomitted nobaselevels drop(*state_n *ruralurban_continuumcode_2013)
esttab int_* using "output/union_models_interactions.rtf", replace b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles r2 nogaps noomitted nobaselevels drop(*state_n *ruralurban_continuumcode_2013)
