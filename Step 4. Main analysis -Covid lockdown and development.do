***********************************************************************************
*	Do-file:		Analysis file for covid lockdown and developmental outcomes.do
*	Project:		GEN2020 project
*	Date:			April 2025
*
*	Data used:		Maternal data merged with HV data
*   Data sources:   Badgernet DS1, DS2, HV datasets
* 	Purpose:  		To investigate the association between covid lockdown exposures and developmental outcomes
***********************************************************************************
cap log close
version 18.0
clear
set more off
*SET the directory* //cd "***********"
*****************************************************
**load master file
*********************************************************************************** 
use maternal_neoDS1DS2DS5_hv3, clear 
log using covidlockdown_analysis_v2_may25, replace
count //45859

*dropping multiplet  //1705 obs deleted
keep if multiplet==0

keep if LA_district_name=="Lambeth" | LA_district_name=="Southwark" //21850 deleted
count //22,304

* drop baby who were born after 30 sept 2023
drop if baby_age_atHVdataextraction==. //57 deleted

count //22247, 5428/7012 review 2 contact flag 

keep if baby_age_atHVdataextraction >=2 //9331 deleted 
count //12916
**************************************************
*create lockdown variables
* Define the lockdown dates and pandemic dates in the UK
gen LD1_Date = date("2020-03-23", "YMD")
gen LD1_enddate = date("2020-06-23", "YMD")
gen LD2_Date = date("2020-11-05", "YMD")
gen LD2_enddate = date("2020-12-02", "YMD")
gen LD3_Date = date("2021-01-06", "YMD")
gen LD3_enddate = date("2021-03-08", "YMD")
gen pandemicstart = date("2020-03-11", "YMD")
gen pandemicend = date("2022-04-01", "YMD")

* Convert the dates to Stata date format
format LD1_Date LD1_enddate LD2_Date LD2_enddate LD3_Date LD3_enddate pandemicstart pandemicend %td

* Calculate age at each lockdown dates, and pandemic dates in months
gen ageatLD1 = (LD1_Date - Truncated_DeliveryDate) / 30.44
gen ageatLD2 = (LD2_Date - Truncated_DeliveryDate) / 30.44
gen ageatLD3 = (LD3_Date - Truncated_DeliveryDate) / 30.44
gen ageatlockdownstart = (LD1_Date - Truncated_DeliveryDate) / 30.44
gen ageatlockdownend = (LD3_enddate - Truncated_DeliveryDate) / 30.44
gen ageatLD1_end = (LD1_enddate - Truncated_DeliveryDate) / 30.44

*age at review 2 in months
gen review2_date= date( completion_date_hv2, "MDY")
format review2_date %td
gen ageatreview2 = (review2_date - Truncated_DeliveryDate) / 30.44

* Generate age at LD1 start groups
gen ageatLD1_cat = .
replace ageatLD1_cat = 0 if ageatLD1 < 0
replace ageatLD1_cat = 1 if ageatLD1 >= 0 & ageatLD1 < 9
replace ageatLD1_cat = 2 if ageatLD1 >= 9 & ageatLD1 < 18
* Label the categories
label define ageatLD1 0 "Born after first lockdown" 1 "0-9 months at lock down 1" 2 "9-18 months at lockdown 1"
label values ageatLD1_cat ageatLD1

* Generate age at LD1_end groups
gen ageatLD1_end_cat = .
replace ageatLD1_end_cat = 0 if ageatLD1_end < 0
replace ageatLD1_end_cat = 1 if ageatLD1_end >= 0 
* Label the categories
label define ageatLD1_end 0 "Born after first lockdown ends" 1 "Born before first lockdown ends"
label values ageatLD1_end_cat ageatLD1_end

* Generate age at LD2 groups
gen ageatLD2_cat = .
replace ageatLD2_cat = 0 if ageatLD2 < 0
replace ageatLD2_cat = 1 if ageatLD2 >= 0 & ageatLD1 < 9
replace ageatLD2_cat = 2 if ageatLD2 >= 9 & ageatLD1 < 18
replace ageatLD2_cat = 3 if ageatLD2 >= 18 & ageatLD1 <27
* Label the categories
label define ageatLD2 0 "Born after second lockdown" 1 "0-9 months at lock down 2" 2 "9-18 months at lockdown 2" 3 "18-27 months at lockdown 2"
label values ageatLD2_cat ageatLD2

* Generate age at LD3 groups
gen ageatLD3_cat = .
replace ageatLD3_cat = 0 if ageatLD3 < 0
replace ageatLD3_cat = 1 if ageatLD3 >= 0 & ageatLD1 < 9
replace ageatLD3_cat = 2 if ageatLD3 >= 6 & ageatLD1 < 18
replace ageatLD3_cat = 3 if ageatLD3 >= 12 & ageatLD1 < 27
* Label the categories
label define ageatLD3 0 "Born after third lockdown" 1 "0-9 months at lock down 3" 2 "9-18 months at lockdown 3" 3 "18-27 months at lockdown 3"
label values ageatLD3_cat ageatLD3


*create binary variable for lockdown and pandemic expereinces 
gen exp_lockdown1= 0
replace exp_lockdown1=1 if ageatLD1>0

gen exp_lockdown2= 0
replace exp_lockdown2=1 if ageatLD2>0

gen exp_lockdown3= 0
replace exp_lockdown3=1 if ageatLD3>0

*number of lockdown experienced
gen numlockdowns= exp_lockdown1 + exp_lockdown2 + exp_lockdown3
lab variable numlockdowns "Number of lockdowns experienced"
lab define numlockdown 0 "No" 1 "1 lockdown" 2 "2 lockdowns" 3 "3 lockdowns"
lab val numlockdowns numlockdown

*create local imd tertile
sort imd_rank
xtile local_imd_3grp = imd_rank, nq(3)
lab var local_imd_3grp "Local IMD Quintiles- 1 Most deprived"
tab local_imd_3grp, miss

*label below cut off
tab belowcutoffscore_anyASQdomain
lab var belowcutoffscore_anyASQdomain "Problem identified in any of ASQ domain"
lab define belowcutoff 0 "No" 1 "Yes"
lab value belowcutoffscore_anyASQdomain belowcutoff
tab belowcutoffscore_anyASQdomain, miss

save covidlockdown_wholecohort_v1, replace
***********************************************
use covidlockdown_wholecohort_v1, clear 

*baseline descriptive table
dtable  ASQ_communication i.sex i.eth_cat i.imd_quint AgeAtDelivery i.birthweight_n i.gestdel_n ageatreview2 i.mother_ever_slam_referral i.healthy_child_status_hv2, by(numlockdowns)

dtable  ASQ_communication ASQ_grossmotor ASQ_finemotor ASQ_problemsolving ASQ_personal_social i.belowcutoffscore_anyASQdomain i.sex i.eth_cat i.imd_quint AgeAtDelivery i.Agedel_cat i.local_imd_3grp i.birthweight_n i.gestdel_n ageatreview2 i.mother_ever_slam_referral i.healthy_child_status_hv2, by(numlockdowns)

dtable  ASQ_communication ASQ_grossmotor ASQ_finemotor ASQ_problemsolving ASQ_personal_social i.belowcutoffscore_anyASQdomain i.sex i.eth_cat i.imd_quint AgeAtDelivery i.Agedel_cat i.local_imd_3grp i.birthweight_n i.gestdel_n ageatreview2 i.mother_ever_slam_referral i.healthy_child_status_hv2 if review2_contact_flag==1 , by(numlockdowns)

*propensity score weighing- discuss 
gen observed=0
replace observed=1 if review2_contact_flag==1
tab observed
logit observed i.eth_cat i.imd_quint , or
predict pscore_observed, pr
gen ipw= 1/pscore_observed

*Associations between the number of lockdowns as exposure on continuous score
*univariable models 
regress ASQ_communication i.numlockdowns
regress ASQ_grossmotor i.numlockdowns
regress ASQ_finemotor i.numlockdowns
regress ASQ_problemsolving i.numlockdowns
regress ASQ_personal_social i.numlockdowns
logit belowcutoffscore_anyASQdomain i.numlockdowns, or 

* use the local quintiles and inverse probability weights, used the robust standard errors to account for clustering
regress ASQ_communication i.numlockdowns i.sex i.eth_cat i.local_imd_3grp ib3.Agedel_cat ib2.birthweight_n ib2.gestdel_n ageatreview2 i.mother_ever_slam_referral i.healthy_child_status_hv2 [pw=ipw] , vce (cluster elixir_id_mother)
est store m1

regress ASQ_grossmotor i.numlockdowns i.sex i.eth_cat i.local_imd_3grp ib3.Agedel_cat ib2.birthweight_n ib2.gestdel_n ageatreview2 i.mother_ever_slam_referral i.healthy_child_status_hv2 [pw=ipw] , vce (cluster elixir_id_mother)
est store m2

regress ASQ_finemotor i.numlockdowns i.sex i.eth_cat i.local_imd_3grp ib3.Agedel_cat ib2.birthweight_n ib2.gestdel_n ageatreview2 i.mother_ever_slam_referral i.healthy_child_status_hv2 [pw=ipw], vce (cluster elixir_id_mother)
est store m3

regress ASQ_problemsolving i.numlockdowns i.sex i.eth_cat i.local_imd_3grp ib3.Agedel_cat ib2.birthweight_n ib2.gestdel_n ageatreview2 i.mother_ever_slam_referral i.healthy_child_status_hv2 [pw=ipw] , vce(cluster elixir_id_mother)
est store m4

regress ASQ_personal_social i.numlockdowns i.sex i.eth_cat i.local_imd_3grp ib3.Agedel_cat ib2.birthweight_n ib2.gestdel_n ageatreview2 i.mother_ever_slam_referral i.healthy_child_status_hv2 [pw=ipw], vce (cluster elixir_id_mother)
est store m5

*result tables
etable, estimate(m1) cstat(_r_b) cstat(_r_ci) cstat(_r_p) showstars showstarsnote  mstat(N,   nformat(%8.0fc) label("Observations")) mstat(aic, nformat(%5.0f)) mstat(r2_p, nformat(%5.4f) label("Pseudo R2"))
etable, estimate(m2) cstat(_r_b) cstat(_r_ci) cstat(_r_p) showstars showstarsnote  mstat(N,   nformat(%8.0fc) label("Observations")) mstat(aic, nformat(%5.0f)) mstat(r2_p, nformat(%5.4f) label("Pseudo R2"))
etable, estimate(m3) cstat(_r_b) cstat(_r_ci) cstat(_r_p) showstars showstarsnote  mstat(N,   nformat(%8.0fc) label("Observations")) mstat(aic, nformat(%5.0f)) mstat(r2_p, nformat(%5.4f) label("Pseudo R2"))
etable, estimate(m4) cstat(_r_b) cstat(_r_ci) cstat(_r_p) showstars showstarsnote  mstat(N,   nformat(%8.0fc) label("Observations")) mstat(aic, nformat(%5.0f)) mstat(r2_p, nformat(%5.4f) label("Pseudo R2"))
etable, estimate(m5) cstat(_r_b) cstat(_r_ci) cstat(_r_p) showstars showstarsnote  mstat(N,   nformat(%8.0fc) label("Observations")) mstat(aic, nformat(%5.0f)) mstat(r2_p, nformat(%5.4f) label("Pseudo R2"))

****************************************************************************
*Association between the lockdown and composite outcomes
*interaction between ethnicity and num of lockdowns
logit belowcutoffscore_anyASQdomain i.numlockdowns##i.eth_cat ib3.Agedel_cat i.sex i.local_imd_3grp ib2.birthweight_n ib2.gestdel_n i.mother_ever_slam_referral i.healthy_child_status_hv2 ,or
est store eth_interaction 

logit belowcutoffscore_anyASQdomain i.numlockdowns i.sex i.eth_cat ib3.Agedel_cat i.local_imd_3grp ib2.birthweight_n ib2.gestdel_n i.mother_ever_slam_referral i.healthy_child_status_hv2 ,or
est store nointeraction  

lrtest eth_interaction nointeraction // p>0.05 no evidence of interaction 

*interaction between imd and number of lockdowns
logit belowcutoffscore_anyASQdomain i.numlockdowns##i.local_imd_3grp i.sex i.eth_cat ib3.Agedel_cat ib2.birthweight_n ib2.gestdel_n i.mother_ever_slam_referral i.healthy_child_status_hv2, or
est store imd_interaction 

lrtest imd_interaction nointeraction // p- 0.16 no evidence of interaction 

tab  belowcutoffscore_anyASQdomain local_imd_3grp
tab belowcutoffscore_anyASQdomain eth_cat

****************************************************************************
* final model with weights association between number of lockdowns and the composite outcome
logit belowcutoffscore_anyASQdomain i.numlockdowns i.sex i.eth_cat ib3.Agedel_cat i.local_imd_3grp ib2.birthweight_n ib2.gestdel_n ageatreview2 i.mother_ever_slam_referral i.healthy_child_status_hv2 [pw=ipw], vce(cluster elixir_id_mother) or
est store finalmodel

*result table for final model 
etable, estimate(finalmodel) cstat(_r_b) cstat(_r_ci) cstat(_r_p) showstars showstarsnote  mstat(N,   nformat(%8.0fc) label("Observations")) mstat(aic, nformat(%5.0f)) mstat(r2_p, nformat(%5.4f) label("Pseudo R2"))
***************************************************
*Repeat all the final models with age at lockdown exposure
****************************************************** 
logit belowcutoffscore_anyASQdomain i.ageatLD1_cat i.sex i.eth_cat ib3.Agedel_cat i.local_imd_3grp ib2.birthweight_n ib2.gestdel_n  i.mother_ever_slam_referral i.healthy_child_status_hv2 [pw=ipw], vce(cluster elixir_id_mother) or
est store logistic3

logit belowcutoffscore_anyASQdomain i.ageatLD2_cat i.sex i.eth_cat ib3.Agedel_cat i.local_imd_3grp ib2.birthweight_n ib2.gestdel_n  i.mother_ever_slam_referral i.healthy_child_status_hv2 [pw=ipw],vce(cluster elixir_id_mother) or
est store logistic4

logit belowcutoffscore_anyASQdomain i.ageatLD3_cat i.sex i.eth_cat ib3.Agedel_cat  i.local_imd_3grp ib2.birthweight_n ib2.gestdel_n  i.mother_ever_slam_referral i.healthy_child_status_hv2 [pw=ipw],vce(cluster elixir_id_mother) or
est store logistic5

etable, estimate(logistic3 logistic4 logistic5) cstat(_r_b) cstat(_r_ci) cstat(_r_p) showstars showstarsnote  mstat(N,   nformat(%8.0fc) label("Observations")) mstat(aic, nformat(%5.0f)) mstat(r2_p, nformat(%5.4f) label("Pseudo R2"))


******* to test individual lockdown effects
logit belowcutoffscore_anyASQdomain i.exp_lockdown1 i.sex i.eth_cat ib3.Agedel_cat i.local_imd_3grp ib2.birthweight_n ib2.gestdel_n ageatreview2 i.mother_ever_slam_referral i.healthy_child_status_hv2 [pw=ipw], vce(cluster elixir_id_mother) or

logit belowcutoffscore_anyASQdomain i.exp_lockdown2 i.sex i.eth_cat ib3.Agedel_cat i.local_imd_3grp ib2.birthweight_n ib2.gestdel_n ageatreview2 i.mother_ever_slam_referral i.healthy_child_status_hv2 [pw=ipw], vce(cluster elixir_id_mother) or

logit belowcutoffscore_anyASQdomain i.exp_lockdown3 i.sex i.eth_cat ib3.Agedel_cat i.local_imd_3grp ib2.birthweight_n ib2.gestdel_n ageatreview2 i.mother_ever_slam_referral i.healthy_child_status_hv2 [pw=ipw], vce(cluster elixir_id_mother) or

* to test first lockdowns effects compared with second and third lockdown
logit belowcutoffscore_anyASQdomain i.ageatLD1_end_cat i.sex i.eth_cat ib3.Agedel_cat i.local_imd_3grp ib2.birthweight_n ib2.gestdel_n ageatreview2 i.mother_ever_slam_referral i.healthy_child_status_hv2 [pw=ipw], vce(cluster elixir_id_mother) or

log close
***************************************************
****************************************************** 
*Figures for covid lockdown analysis  for GEN2020
graph box AgeAtDelivery, over(numlockdowns) title("Maternal Age at Delivery by no of COVID lockdowns experienced", size(small)) ylabel(, angle(horizontal)) ytitle("Age at Delivery") name(g1_ld,replace) nodraw
graph bar (percent), over (eth_cat) over(numlockdowns) asyvars stack title("Maternal Ethnicity by no of COVID lockdowns experienced", size(small))  ytitle("Percentage") percent name(g2_ld,replace) nodraw
graph bar (percent), over (imd_quint) over(numlockdowns) asyvars stack title("IMD quintiles by no of COVID lockdowns experienced",size(small))  ytitle("Percentage") percent name(g3_ld,replace) nodraw
graph box GestationAtDeliveryWeeks, over(numlockdowns) title("Gestational Age at Delivery by no of COVID lockdowns experienced",size(small)) ylabel(, angle(horizontal)) ytitle("Gestation age at Delivery") name(g4_ld,replace) nodraw
graph box BirthWeightGrams, over(numlockdowns) title("Baby's birthweight by no of COVID lockdowns experienced",size(small)) ylabel(, angle(horizontal)) ytitle("Baby's birthweight") name(g5_ld,replace) nodraw 
graph bar (percent), over (sex) over(numlockdowns) asyvars stack title("Baby's sex by no of COVID lockdowns experienced",size(small))  ytitle("Percentage") percent name(g6_ld,replace) nodraw 

graph combine g1_ld g4_ld g3_ld g2_ld g5_ld, name(covidlockdown, replace) cols(2) rows(2) imargin(medsmall)
graph export "B:\BRC_Elixir\DL046- McAlonan\03. Documents\covidlockdown_v2_april25.jpg", replace as(jpg) name("covidlockdown") quality(100)
*********************************************
************************************************
*Figures for covid lockdown graphs for GEN2020
graph box ASQ_communication, over(numlockdowns) title("ASQ communication score by no of COVID lockdowns experienced", size(small)) ylabel(, angle(horizontal)) ytitle("ASQ communication score") name(g_ld_com,replace) nodraw

graph box ASQ_grossmotor, over(numlockdowns) title("ASQ Gross Motor score by no of COVID lockdowns experienced", size(small)) ylabel(, angle(horizontal)) ytitle("ASQ Gross Motor score") name(g_ld_grossmotor,replace) nodraw

graph box ASQ_finemotor, over(numlockdowns) title("ASQ Fine Motor score by no of COVID lockdowns experienced", size(small)) ylabel(, angle(horizontal)) ytitle("ASQ Fine Motor score") name(g_ld_finemotor,replace) nodraw

graph box ASQ_problemsolving, over(numlockdowns) title("ASQ Problem Solving score by no of COVID lockdowns experienced", size(small)) ylabel(, angle(horizontal)) ytitle("ASQ Problem Solving score") name(g_ld_problem,replace) nodraw

graph box ASQ_personal_social, over(numlockdowns) title("ASQ Personal Social score by no of COVID lockdowns experienced", size(small)) ylabel(, angle(horizontal)) ytitle("ASQ Personal Social score") name(g_ld_personalsocial,replace) nodraw

graph bar (percent), over (belowcutoffscore_anyASQdomain) over(numlockdowns) asyvars stack title("Problem identified in any ASQ domains (%) by COVID lockdowns",size(small)) ytitle("Percentage") percent name(g_ld_anydomain,replace)
graph export "B:\BRC_Elixir\DL046- McAlonan\03. Documents\anydomain_lockdowns_v2_april25.jpg", replace as(jpg)quality(100)

graph combine g_ld_com g_ld_grossmotor g_ld_finemotor g_ld_problem g_ld_personalsocial, name(ASQ_covidlockdowns, replace) cols(2) rows(2) imargin(medsmall)
graph export "B:\BRC_Elixir\DL046- McAlonan\03. Documents\asq_covidlockdowns_v2_april25.jpg", replace as(jpg) name("ASQ_covidlockdowns") quality(100)
*********************************************
************************************************









