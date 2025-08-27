clear

set more off


*========================================================================
*Assignment Applied Microeconometrics
*Cappadona Fabio
*========================================================================


*** please change to the correct file path ***

cd "/Users/fabio/Desktop/cappadona_fabio_project"


*** Source Code: Generated using content covered in class and with assistance from AI Claude 3.7 Sonnet.


*.  My work starts with two datasets:

* - One contains treatment variables and instrumental variables from season 4-6.

* - The other contains control variables from seasons 1 to 3, including the extension decision point.

* These two datasets are then merged, as this is the most efficient way I found to organize the data for effective use with the ivregress 2sls command.


* Load Dataset containing outcome and treatment variables, as well as instrumental variables (IV) for seasons 4 to 6.


use "outcome_treatment_IV_data.dta", clear


*** Creation of Figure 1 "Extension Rate by Draft Position ***


* Flag unique players and use in tabulation

bysort player_id: gen unique_player = _n == 1
tabulate Draft_position rookie_extension_signed if unique_player == 1, row


* Save Current work
save "temp_current.dta", replace

* Create a temporary dataset for the chart
preserve

* Keep only unique players

bysort player_id: keep if _n == 1

* Calculate extension rates by draft position

collapse (mean) extension_rate = rookie_extension_signed_v (count) n_players = rookie_extension_signed_v, by(Draft_position)

* Create a percentage version of extension rate

gen extension_pct = extension_rate * 100

* Create the bar chart with percentage labels

twoway (bar extension_pct Draft_position, barwidth(0.8) bcolor(navy) lwidth(thin) lcolor(black)), ///
    title("Extension Rates by Draft Position", size(medium)) ///
    ytitle("Extension Rate (%)", size(small)) ///
    xtitle("Draft Position", size(small)) ///
    ylabel(0(20)100, labsize(small)) ///
    xlabel(1(1)14, labsize(small)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    note("Sample: 123 players from 2007-2015 drafts", size(vsmall))

graph export "extension_rates.png", width(3000) replace
	
* Restore original dataset

restore


* Dataset containing control variables from seasons 1 to 3, including the extension decision point.


use "control_variables_data.dta", clear

* Make copy of control_variables_data set

save "temp_controls.dta",replace



* Create team_id  for each team in dataset facing extension situation if it doesn't already exist

capture confirm variable team_id
if _rc {
    * team_id doesn't exist, create it
    tabulate Team if extension_decision_point == 1
    encode Team, generate(team_id)
}

* In dataset outcome_treatment_IV_data, keep only rows with extension point decisions.


keep if extension_decision_point == 1

* Save the processed controls

save "temp_controls.dta",replace


* Load outcomes dataset again

use "outcome_treatment_IV_data.dta", clear

* Merge in the pre-treatment controls

merge m:1 player_id using "temp_controls.dta"

* After merging, check the merge results

tab _merge

* Drop in merged dataset observations where WS_num is missing

drop if missing(WS)




*** VALUES PREPARATION ***



* Dummy variable: 1 if the rookie was traded before receiving an extension, 0 otherwise.

gen team_switched_num = real(switch_team)


* Convert WS into an integer

gen WS_num = real(WS)
replace WS_num = round(WS_num, 0.01)


* Convert dummy variable all_rookie_team to an integer

gen all_rookie_team_num = real(all_rookie_team)


*** Convert dummy variable GM_Change to an integer

gen GM_change_num = real(GM_change)



*** Generate 'PER_trend' per position: captures player's PER trend (regression) from season 1 to season 3 ***


sum PER_trend if Position == "PG"
gen PER_trend_PG = r(mean)

sum PER_trend if Position == "SG"
gen PER_trend_SG = r(mean)

sum PER_trend if Position == "SF"
gen PER_trend_SF = r(mean)

sum PER_trend if Position == "PF"
gen PER_trend_PF = r(mean)

sum PER_trend if Position == "C"
gen PER_trend_C = r(mean)


*** Create 'PER_trend_pos_adj': measures how a player's PER trend deviates from the average PER trend for their position

gen PER_trend_pos_adj = .
replace PER_trend_pos_adj = PER_trend - PER_trend_PG if Position == "PG"
replace PER_trend_pos_adj = PER_trend - PER_trend_SG if Position == "SG"
replace PER_trend_pos_adj = PER_trend - PER_trend_SF if Position == "SF"
replace PER_trend_pos_adj = PER_trend - PER_trend_PF if Position == "PF"
replace PER_trend_pos_adj = PER_trend - PER_trend_C if Position == "C"




* Generate variable for league average minutes per game trend from season 1 to season 3


* Generate the variable league_avg_min_game_trend: captures the evolution of the league's average minutes per game from season 1 to season 3, highlighting changes in playing time trends during the early seasons.

sum avg_minutes_game_trend
gen league_avg_min_game_trend = r(mean)


*Generate a variable to capture how a player's average minutes per game changed relative to the league average

gen minutes_trend = avg_minutes_game_trend - league_avg_min_game_trend if extension_decision_point == 1


* Pick number 1 has a substantially higher extension rate (78%) compared to lower picks, typically around 30%, therefore I use the reciprocal of draft position to capture this non-linear relationship.

gen draft_value_inverse = 1 / Draft_position






***  Variables and Their Interpretation:




* - draft_value_inverse: Captures initial talent evaluation and perceived upside at the time of the draft.


* - availability_durability: Captures a player's reliability by measuring games played relative to total possible games over their first three seasons. This indicates whether a player is injury-prone and signals potential future availability risk,
 

* - all_rookie_team: Reflects early career recognition through All-Rookie team selection, indicating exceptional performance and potential upside relative to draft peers.


* - PER_trend_pos_adj: Measures performance trajectory relative to players at the same position from season 1 to season 3, indicating how a player's efficiency evolves compared to positional benchmarks.


* - team_success_index_trend: Evaluates whether a player's contributions meaningfully impact team performance improvement or if they are accumulating statistics without translating to team success.


* - minutes_trend: Tracks playing time evolution from season 1 to season 3, indicating increasing coach trust and responsibility.


* - team_switched: Signals organizational commitment to player development; switching teams may indicates lower commitment from the original organization reduced likelihood of extension.


* - GM_change_num: Captures organizational instability; a change in the GM who drafted the player may lead to reduced investment, as new management often prioritizes their own selections.



*** After data preparation and merging steps, create separate datasets ***

* First, save the full dataset (all seasons)

save "temp_full.dta", replace

* Create season 4 only dataset

keep if number_season == 4
save "temp_season_4.dta", replace

* Create season 5 only dataset

use "temp_full.dta", clear

keep if number_season == 5

save "temp_season_5.dta", replace

* Create season 6 only dataset

use "temp_full.dta", clear
keep if number_season == 6
count
if r(N) > 0 {
    save "temp_season_6.dta", replace
}



* Step 1: Load Season 4 Data

use "temp_season_4.dta", clear



* Step 2: Generate Pre-Treatment Characteristics Table 

tabstat PER_trend_pos_adj minutes_trend availability_durability all_rookie_team_num GM_change_num team_switched_num , ///
    by(rookie_extension_signed_v) statistics(mean sd count) format(%9.2f)


	
* Run IV Regression for Season 4

* Perform IV regression (2SLS) without including fixed efffects and control variables.

ivregress 2sls WS_num (rookie_extension_signed_v = draft_value_inverse), robust first
estat firststage



*Perform IV regression (2SLS) including only team and draft fixed effects 

ivregress 2sls WS_num (rookie_extension_signed_v = draft_value_inverse) i.draft_year i.team_id, robust first
estat firststage


*Perform IV regression (2SLS) including team and draft fixed effects and control variables 

ivregress 2sls WS_num (rookie_extension_signed_v = draft_value_inverse) ///
    PER_trend_pos_adj minutes_trend availability_durability all_rookie_team_num GM_change_num ///
    team_success_index_trend i.draft_year i.team_id, robust first
estat firststage




* Step 1: Load Season 5 Data

use "temp_season_5.dta", clear


*Perform IV regression (2SLS) without fixed effects and without control variables 
* (not part of the main analysis, included out of curiosity).

*ivregress 2sls WS_num (rookie_extension_signed_v = draft_value_inverse), robust first
*estat firststage


*ivregress 2sls WS_num (rookie_extension_signed_v = draft_value_inverse) i.draft_year i.team_id, robust first
*estat firststage


*Perform IV regression (2SLS) including team and draft fixed effects and control variables => prefered specification


ivregress 2sls WS_num (rookie_extension_signed_v = draft_value_inverse) ///
    PER_trend_pos_adj minutes_trend availability_durability all_rookie_team_num GM_change_num ///
    team_success_index_trend i.draft_year i.team_id, robust first
estat firststage




* Step 1: Load Season 6 Data

use "temp_season_6.dta", clear


*Perform IV regression (2SLS) without fixed effects and without control variables 
* (not part of the main analysis, included out of curiosity).

*ivregress 2sls WS_num (rookie_extension_signed_v = draft_value_inverse), robust first
*estat firststage

*ivregress 2sls WS_num (rookie_extension_signed_v = draft_value_inverse) i.draft_year i.team_id, robust first
*estat firststage



*Perform IV regression (2SLS) including team and draft fixed effects and control variables => prefered specification


ivregress 2sls WS_num (rookie_extension_signed_v = draft_value_inverse) ///
    PER_trend_pos_adj minutes_trend availability_durability all_rookie_team_num GM_change_num ///
    team_success_index_trend i.draft_year i.team_id, robust first
estat firststage


*** Create the effect size visualization across seasons *** 

*create a dataset to visualize the effects over time
clear
set obs 3
gen season = _n + 3
gen effect = .
replace effect = 5.07 if season == 4
replace effect = 0.06 if season == 5
replace effect = -0.86 if season == 6
gen se = .
replace se = 2.08 if season == 4
replace se = 1.98 if season == 5
replace se = 2.16 if season == 6
gen lower = effect - 1.96*se
gen upper = effect + 1.96*se

* Create the graph
twoway (rcap upper lower season, lcolor(navy)) ///
       (connected effect season, msymbol(circle) mcolor(navy) lcolor(navy)), ///
       yline(0, lpattern(dash) lcolor(gray)) ///
       xtitle("Season After Extension") ytitle("Win Shares Effect") ///
       xlabel(4 "Season 4" 5 "Season 5" 6 "Season 6") ///
       title("Extension Effect on Win Shares Over Time") ///
       note("Note: Vertical lines represent 95% confidence intervals") ///
       graphregion(color(white)) bgcolor(white)

graph export "extension_effects_over_time.png", replace width(3000)

