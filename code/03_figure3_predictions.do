* Figure 3 and the effect sizes quoted with it
* Lockdown (2020) predictions from the interaction models at the 10th and 90th percentiles of county union membership,
* across Black shares of 0 to 50 percent, and the difference in the Black-share effect between low and high membership.

import delimited using "data/county_union_extract.csv", clear varnames(1) asdouble
keep if year==2020

local controls amindianalone_prop asianalone_prop hawpacalone_prop hispanic_prop essential_perc ///
    female_prop prop_age18to64 prop_age65plus percentofadultswithlessthanahigh ///
    percentofadultswithahighschooldi percentofadultscompletingsomecol unemployment_rate_2018 ///
    medhhinc_2018 i.ruralurban_continuumcode_2013 i.state_n

log using "output/figure3_margins.log", text replace name(fig3)
foreach y in workplacemob residentmob {
    display _n "==== `y', lockdown 2020 ===="
    quietly reg `y' c.um_cps##c.blackalone_prop c.um_cps##c.per_gop `controls'
    quietly summarize um_cps if e(sample), detail
    local u10 = r(p10)
    local u90 = r(p90)
    quietly summarize blackalone_prop if e(sample), detail
    local b10 = r(p10)
    local b90 = r(p90)
    display "union membership p10/p90: `u10' / `u90'; Black share p10/p90: `b10' / `b90'"
    /*the lines in Figure 3*/
    margins, at(um_cps=(`u10' `u90') blackalone_prop=(0(.05).5)) saving("output/margins_`y'.dta", replace)
    /*predictions at the 10th and 90th percentiles of both measures*/
    margins, at(um_cps=(`u10' `u90') blackalone_prop=(`b10' `b90')) pwcompare(effects)
    /*difference in the Black-share effect between high and low union membership*/
    lincom (`u90' - `u10') * (`b90' - `b10') * c.um_cps#c.blackalone_prop
}
log close fig3

/* The plotted numbers, in percent */
clear
foreach y in workplacemob residentmob {
    append using "output/margins_`y'.dta", generate(src_`y')
}
generate outcome = cond(src_workplacemob==1, "work", "home")
bysort outcome (_at1): generate union = cond(_at1==_at1[1], "low", "high")
generate union_membership_pct = round(100*_at1, .1)
generate black_share_pct = round(100*_at2)
generate predicted = 100*_margin
generate ci_low = 100*_ci_lb
generate ci_high = 100*_ci_ub
generate order = (outcome=="home")*2 + (union=="high")
sort order black_share_pct
format union_membership_pct %4.1f
format predicted ci_low ci_high %6.2f
export delimited outcome union union_membership_pct black_share_pct predicted ci_low ci_high ///
    using "output/figure3_predictions.csv", replace datafmt
erase "output/margins_workplacemob.dta"
erase "output/margins_residentmob.dta"
