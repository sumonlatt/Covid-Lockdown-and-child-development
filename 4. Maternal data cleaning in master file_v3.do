***********************************************************************************
*	Do-file:		Maternal data cleaning.do
*	Project:		GEN2020 elixir 
*	Date:			5 Nov 24
*
*	Data used:		maternal_neoDS1DS2DS5_v1- 2024 refresh data 
*   Data sources: Maternity DS1_DS2_DS10, Neonatal DS1 , DS2, DS5 
* 	Purpose:  		To clean up maternal string data variables using the linked master file
***********************************************************************************
cap log close
version 18.0
clear
set more off
cd "B:\BRC_Elixir\DL046- McAlonan\01. GEN 2020 STATA v3"


************************************************************************************************
***************************************************************************************************
use maternal_neoDS1DS2DS5_v1,clear

************************************************************************************************
*More maternal data cleaning for string variables
***************************************************************************************************
*destring numerical variables
destring MaternalAgeAtBooking AgeAtDelivery ParityAtBooking ParityAfterDelivery WeightAtBooking HeightAtBooking BMIAtBooking NumberOfBabies APGARscore1Minute APGARscore5Minutes APGARscore10Minutes GestationAtBookingWeeks GestationAtDeliveryWeeks TotalBloodLoss BirthWeightGrams AlcoholUnitsPerWeekBeforeConcept AlcoholUnitsPerDayBeforeConcepti AlcoholUnitsPerWeekSinceConcepti AlcoholUnitsPerDaySinceConceptio AlcoholUnitsPerWeekCurrentPartne SystolicBP DiastolicBP HeadCircumference BabyLength, replace force

describe

*mother age category
gen Agedel_cat=.
replace Agedel_cat=0 if AgeAtDelivery <=19
replace Agedel_cat=1 if AgeAtDelivery >=20 & AgeAtDelivery <25
replace Agedel_cat=2 if AgeAtDelivery >=25 & AgeAtDelivery <30
replace Agedel_cat=3 if AgeAtDelivery >=30 & AgeAtDelivery <35
replace Agedel_cat=4 if AgeAtDelivery >=35
tab AgeAtDelivery Agedel_cat
lab var Agedel_cat " Age at birth categories"
lab define Agedel_cat1 0  "<=19" 1 "20-24" 2"25-29" 3  "30-34" 4 ">=35"
lab value Agedel_cat Agedel_cat1
order Agedel_cat, after(AgeAtDelivery)

*parity at booking group variables
gen parity_booking_n=0 if ParityAtBooking!=.
replace parity_booking_n=1 if ParityAtBooking==1
replace parity_booking_n=2 if ParityAtBooking==2
replace parity_booking_n=3 if ParityAtBooking>=3
tab ParityAtBooking parity_booking_n, miss
lab define parity_booking_n 0 "Primiparous" 1"Parity 1" 2 "Parity 2" 3 " Parity >=3"
lab value parity_booking_n parity_booking_n
lab var parity_booking_n "Parity at the time of booking"
order parity_booking_n, after(ParityAtBooking)

*BMI category at booking
su BMIAtBooking 
br HeightAtBooking WeightAtBooking BMIAtBooking if BMIAtBooking>140 & BMIAtBooking!=.
replace BMIAtBooking=. if BMIAtBooking==143.8 //height is missing and bmi miscalculated
gen bmiatbooking_cat=0 if BMIAtBooking!=.
replace bmiatbooking_cat=1 if BMIAtBooking<18 
replace bmiatbooking_cat=2 if BMIAtBooking>=18 & BMIAtBooking<25
replace bmiatbooking_cat=3 if BMIAtBooking>=25 & BMIAtBooking<30
replace bmiatbooking_cat=4 if BMIAtBooking>=30 & BMIAtBooking!=.
tab bmiatbooking_cat, miss
lab var bmiatbooking_cat " Mother's BMI categories at booking"
lab define bmiatbooking_cat 1 "<18" 2 " 18.5-24" 3 "25-29" 4 ">=30"
lab values bmiatbooking_cat bmiatbooking_cat
order bmiatbooking_cat, after (BMIAtBooking)

*gestation age at birth category
gen gestdel_n=0
replace gestdel_n=1 if GestationAtDeliveryWeeks <37
replace gestdel_n=2 if GestationAtDeliveryWeeks >=37  & GestationAtDeliveryWeeks <=40
replace gestdel_n=3 if GestationAtDeliveryWeeks >=41 
tab gestdel_n, miss 
lab var gestdel_n "Gestation at delivery (wks) categories"
lab define gestdel_n 1 "pre-term <37"2 "Term delivery 37-40" 3 "post-term delivery >=41" 
lab values gestdel_n gestdel_n
tab gestdel_n, miss
order gestdel_n, after (GestationAtDeliveryWeeks)

*generating birth weight of the baby category
gen birthweight_n=0
replace birthweight_n=1 if BirthWeightGrams <2500
replace birthweight_n=2 if BirthWeightGrams >=2500 & BirthWeightGrams <3500
replace birthweight_n=3 if BirthWeightGrams >=3500 & BirthWeightGrams <4000
replace birthweight_n=4 if BirthWeightGrams >=4000
lab define bwlab 1 " <2500 g"2 "25000-3499" 3"3500-3999" 4 ">=4000"
lab values birthweight_n bwlab 
tab birthweight_n, miss
lab var birthweight_n "Baby's birth weight in grams"
order birthweight_n, after (BirthWeightGrams)

*encode mode of delivery variables
encode ModeOfDelivery, gen(modeofdelivery) label (modeofdelivery)
tab modeofdelivery
tab modeofdelivery,nolabel
recode modeofdelivery  9=0 1/3=0 6/7=1 11=1 12/13=1 4=2 5=3 8=. 10=.
lab def modeofdelivery_lab 0 "Normal spontaeneous vaginal delivery" 1"Forceps or Ventouse delivery" 2" Elective CS" 3"Emergency and unspecified CS"
lab val modeofdelivery modeofdelivery_lab
tab modeofdelivery, miss
order modeofdelivery, after (ModeOfDelivery)
lab var modeofdelivery "Mode of delivery"
drop ModeOfDelivery

*mode of delivery binary variable
gen modeofdelivery_binary= modeofdelivery
recode modeofdelivery_binary 0/1=0 2/3=1
lab def modeofdelivery_binary 0 "Vaginal delivery" 1 "Caesarean Delivery"
lab val modeofdelivery_binary modeofdelivery_binary
tab modeofdelivery_binary, miss
order modeofdelivery_binary, after (modeofdelivery)

*Smoking at delivery and booking
label define smokingatdelivery 0 "No" 1 "Yes"
encode SmokerAtDelivery, gen (smokingatdelivery) label(smokingatdelivery)
tab smokingatdelivery,nolabel
recode smokingatdelivery 2/3=.
tab smokingatdelivery, miss
order smokingatdelivery, after(SmokerAtDelivery)
drop SmokerAtDelivery
label var smokingatdelivery "Smoker at the time of delivery"

encode SmokerAtBooking , gen (smokingatbooking) label(smokingatbooking)
tab smokingatbooking,nolabel
recode smokingatbooking 2/3=.
tab smokingatbooking, miss
order smokingatbooking, after( SmokerAtBooking )
drop SmokerAtBooking
label var smokingatbooking "Smoker at the time of antenatal booking"

*eversmoker
tab EverSmoked
encode EverSmoked , gen (eversmoker) 
tab eversmoker,nolabel
recode eversmoker 7=0 6=1 4/5=2 1/2=3 3=. 8/9=.
label define eversmoker1 0 "Never smoker" 1 "Ex-smokder gave up more than 6 weeks" 2 "Ex-smoker gave up less than 6 weeks" 3" current smoker"
lab val eversmoker eversmoker1
order eversmoker, after(EverSmoked)
drop EverSmoked
lab var eversmoker "Eversmoked at the time of booking"

*multiple pregnancy
gen multiplet=0
replace multiplet=1 if NumberOfBabies>1
tab NumberOfBabies multiplet
lab var multiplet "Multiple Pregnancies"
lab def multiplet 0 "No" 1 "Yes"
lab val multiplet multiplet 
order multiplet, after (NumberOfBabies)
save maternal_neoDS1DS2DS5_v2,replace

*first feed variable 
rename FirstFeedMethod firstfeedmethod
gen first_feed=. 
replace first_feed=1 if firstfeedmethod=="Breast Only" | firstfeedmethod=="Breast and EBM" | firstfeedmethod=="Antenatal hand expressed colostrum"| firstfeedmethod=="Breast and Harvested Colostrum" | firstfeedmethod=="Expressed Breastmilk" | firstfeedmethod=="Harvested Colostrum" | firstfeedmethod=="Breast and antenatal hand expressed colostrum"
replace first_feed=2 if firstfeedmethod=="Formula Only"
replace first_feed=3 if firstfeedmethod=="Breast/EBM and Formula"
replace first_feed=4 if firstfeedmethod=="Unknown (NNU)" | firstfeedmethod=="Nil by Mouth" | firstfeedmethod=="Other (Non Milk Feed)"
tab first_feed firstfeedmethod
label define feed 1"breast" 2"formula" 3"mixed" 4"other"
label values first_feed feed
label var first_feed "First feeding method"

*feeding at discharge to the community
rename FeedingMethodAtTransferToCommuni feedingmethod_transfercommunity
gen feedingmethod_discharge=. 
replace feedingmethod_discharge=1 if feedingmethod_transfercommunity=="breast" | feedingmethod_transfercommunity=="breastAndExpressed" | feedingmethod_transfercommunity=="breastAndHarvestedColostrum"| feedingmethod_transfercommunity==" expressed" | feedingmethod_transfercommunity=="expressed" | feedingmethod_transfercommunity=="harvestedColostrum"
replace feedingmethod_discharge=2 if feedingmethod_transfercommunity=="formula"
replace feedingmethod_discharge=3 if feedingmethod_transfercommunity=="mixed"
replace feedingmethod_discharge=4 if feedingmethod_transfercommunity=="nbm" | feedingmethod_transfercommunity=="nonmilkfeed" 
label define feedingmethod_discharge 1"breast" 2"formula" 3"mixed" 4"other"
label values feedingmethod_discharge feedingmethod_discharge
label var feedingmethod_discharge "Feeding method at transfer to the community"

*GDM coding
rename Diabetes diabetes
gen gdm="0" if diabetes!=""
replace gdm="T1D" if diabetes=="Diabetes - Type 1"
replace gdm="T2D" if diabetes=="Diabetes - Type 2"
replace gdm="No" if diabetes=="No"
replace gdm="Yes-Current GDM" if diabetes=="Diabetes - Gestational" & diabetes=="Current Gestational Diabetes"
replace gdm="Unknown" if diabetes=="Unknown" | diabetes=="not recorded"
local vars1 "Current$Gestational" 
foreach v in `vars1' {
replace gdm ="Yes-Current GDM" if strpos(diabetes, "`v'")!=0
}
replace gdm="Previous GDM" if gdm=="0" 
tab gdm diabetes
lab def gdm_n 0 "No" 1 "Previous GDM" 2"T1D" 3 "T2D" 4"Yes-Current GDM"
encode gdm, gen(gestational_diabetes) label (gdm_n)
drop gdm
recode gestational_diabetes 5=.
tab gestational_diabetes, nolabel
lab var gestational_diabetes "gestational diabetes"
order gestational_diabetes, after(diabetes)

* binary variable for the gestatiaonal diabetes
gen gest_dm_binary= gestational_diabetes
recode gest_dm_binary 1/3=0 4=1 // previous and type 1 and 2 classed as no
tab gest_dm_binary
lab def gdmbi 0 "No" 1 "Yes"
lab value gest_dm_binary gdmbi
lab var gest_dm_binary "Gestational diabetes in current pregnancy"
tab gest_dm_binary

*hypertension in current pregnancy //Katie do file ref 
rename SystolicBP systolicbp
rename DiastolicBP diastolicbp
gen sbp_cat = (systolicbp>= 140) +  (systolicbp>= 160) + 1 if systolicbp<.
gen dbp_cat = (diastolicbp>= 90) + (diastolicbp>= 110) + 1 if diastolicbp<.
gen bp_cat = max(sbp_cat , dbp_cat)
label define bp_cat 1 "Green (<140/90)" 2 "Amber(140/90 to 160/110)" 3 "Red (>= 160/110)"
label values bp_cat bp_cat 
lab var bp_cat "Blood pressure category in current pregnancy"

**PPH variables
rename TotalBloodLoss bldloss
* mild and severe PPH categories 
gen PPH_cat=0 
replace PPH_cat=1 if bldloss>500 & bldloss<1500
replace PPH_cat=2 if bldloss >=1500 
tab PPH_cat, miss
lab var PPH_cat "PPH categories"
lab define PPHlab1 0 "no PPH" 1 "PPH" 2 "Severe PPH"
lab values PPH_cat PPHlab1

*epilepsy variable
gen any_epilepsy="No" if Epilepsy=="No"
replace any_epilepsy="Yes" if Epilepsy=="Generalised" |Epilepsy=="History Of" |Epilepsy=="Partial Onset" |Epilepsy=="Yes"
replace any_epilepsy="Unknown" if Epilepsy=="Unknown" |Epilepsy=="not recorded"
tab Epilepsy any_epilepsy
lab define epilepsylab 0 "No" 1 "Yes" 2"Unknown"
encode any_epilepsy, gen (epilepsy) lab(epilepsylab)
recode epilepsy 2=.
tab epilepsy, miss
order epilepsy, after (Epilepsy)
drop Epilepsy any_epilepsy

*Seen psychiatrist before"
lab def psychiatrist 0 "no" 1"yes" 2"not recorded"
encode SeenPsychiatristBefore, gen(seenpsychiatrist) label (psychiatrist)
tab seenpsychiatrist, nolabel
recode seenpsychiatrist 2=.
order seenpsychiatrist, after ( SeenPsychiatristBefore)
drop SeenPsychiatristBefore

*recoding finalbirthoutcome might be helpful to do it at the beginning and drop them from DS2? or keep it here 
rename FinalBirthOutcome finalbirthoutcome
gen livebirth="0"
replace livebirth="1" if finalbirthoutcome=="Livebirth"
destring livebirth, replace
lab define livebirth 0 "No- stillbirth or neonataldeath" 1"Yes-livebirth"
lab value livebirth livebirth
lab var livebirth "Birth outcome binary"

*ethnicity
* mentalhealthproblems
gen selfreport_mhprobs="1"
replace selfreport_mhprobs= "0" if MentalHealthProblems=="no"
replace selfreport_mhprobs= "2" if MentalHealthProblems=="not recorded" | MentalHealthProblems=="unknown" 
tab selfreport_mhprobs
destring selfreport_mhprobs,replace
recode selfreport_mhprobs 2=.
lab define selfreport_mhprobs 0 "No" 1 "Yes"
lab var selfreport_mhprobs selfreport_mhprobs

*destring datasource variable 
encode Data_Source, generate (data_source)

*generate born in the UK variable
gen born_in_uk=0
replace born_in_uk=1 if CountryofBirth=="United Kingdom of Great Britain and Northern Ireland"
lab var born_in_uk "Born in the UK"
lab define borninuk 0 "No" 1 "Yes"
lab val  born_in_uk borninuk
tab born_in_uk

*primary language English
gen primary_language_eng=0
replace primary_language_eng=1 if PrimaryLanguage=="English"
lab var primary_language_eng "Primary language English"
lab val  primary_language_eng borninuk
tab primary_language_eng

save maternal_neoDS1DS2DS5_v2,replace
*encode following variables maternal education, alcohol use, drug use, family conflict, downdepressedhopeless, ppd,

************************************************************************************************
***************************************************************************************************
************************************************************************************************
*Generating Covid timeline
***********************************************************************************
use maternal_neoDS1DS2DS5_v2, clear //revisit this

label var bookingdate "Booking date"
* generating covid period at the date of birth
gen covid_period= Truncated_DeliveryDate >daily("01march2020","DMY") & Truncated_DeliveryDate <daily("31dec2022","DMY")
replace covid_period= 2 if Truncated_DeliveryDate >daily("31dec2022","DMY")
tab covid_period YOB_baby
lab define covid_period 0 "*Before 01 March 2020" 1" 01 Mar 2020- 31 Dec 2022" 2"After 31 Dec 2022"
lab value covid_period covid_period
lab var covid_period "Simplified pandemic timeline at baby's date of birth"
rename covid_period covid_period_atbirth


* generating covid period at the booking date 
gen covidperiod_atbooking= bookingdate >daily("01march2020","DMY") & bookingdate <daily("31dec2022","DMY")
replace covidperiod_atbooking= 2 if bookingdate >daily("31dec2022","DMY")
tab covidperiod_atbooking YOB_baby
lab value covidperiod_atbooking covid_period
lab var covidperiod_atbooking "Simplified pandemic timeline at first antenatal booking"

*pandemic time reference at the date of birth 
gen pandemic_timeline= Truncated_DeliveryDate >daily("23march2020","DMY") & Truncated_DeliveryDate <daily("07mar2021","DMY")
replace pandemic_timeline= 2 if Truncated_DeliveryDate >daily("08march2021","DMY") & Truncated_DeliveryDate <daily("31oct2021","DMY")
replace pandemic_timeline= 3 if Truncated_DeliveryDate >daily("01nov2021","DMY")
label define pandemic_timeline 0"pre-pandemic" 1"first/second lockdown" 2"omicron wave" 3"post"
label values pandemic_timeline pandemic_timeline 
lab variable pandemic_timeline "Pandemic timeline at baby's date of birth"

lab def neonadm 0 "No" 1 "yes"
lab val neonadm neonadm
rename pandemic_timeline pandemic_timeline_atbirth 

*generating pandemic timeline for the booking date 
gen pandemic_timeline_atbooking= bookingdate >daily("23march2020","DMY") & bookingdate <daily("07mar2021","DMY")
replace pandemic_timeline_atbooking= 2 if bookingdate >daily("08march2021","DMY") & bookingdate <daily("31oct2021","DMY")
replace pandemic_timeline_atbooking= 3 if bookingdate >daily("01nov2021","DMY")
label values pandemic_timeline_atbooking pandemic_timeline 
lab var pandemic_timeline_atbooking "Pandemic timeline at first antenatal booking date"

*ethnicity data cleaning
rename MotherEthnicity motherethnicity
replace motherethnicity = "Missing" if inlist(motherethnicity, "Declined to answer", "Not Stated", "not recorded", "")
gen eth_missing = motherethnicity == "Missing" 
label var eth_missing "Ethnicity not recorded"

* generating white ethnicity 
gen temp_eth_white1 = inlist(motherethnicity, "British", "Irish", "Gypsy or Irish Traveller", "Roma", "White-Other", "White-Albanian", "White-Any other")
gen temp_eth_white2 = inlist(motherethnicity, "White-British", "White-English", "White-Former USSR", "White-Greek", "White-Greek Cypriot", "White-Irish", "White-Italian")
gen temp_eth_white3 = inlist(motherethnicity, "White-Kosovan", "White-Kurdish", "White-Oth Yugoslavia", "White-Oth unspec", "White-Polish", "White-Portuguese")
gen temp_eth_white4 = inlist(motherethnicity, "White-Scottish", "White-T'kish Cypriot", "White-Turkish", "White-Welsh")
gen eth_white = temp_eth_white1 | temp_eth_white2 | temp_eth_white3 | temp_eth_white4
drop temp_eth_white1 temp_eth_white2 temp_eth_white3 temp_eth_white4

*generating asian ethnicity
gen temp_eth_asian1 = inlist(motherethnicity, "Asian-Any other", "Asian-Other", "Asian-Other unspec", "Asian-Bangladeshi", "Bangladeshi")
gen temp_eth_asian2 = inlist(motherethnicity, "Asian-British Asian", "Chinese", "Indian", "Pakistani", "Asian-Indian/Brt Ind")
gen temp_eth_asian3 = inlist(motherethnicity, "Asian-Pakistani", "Other-Chinese", "Other-Filipino", "Other-Vietnamese")
gen eth_asian = temp_eth_asian1 | temp_eth_asian2 | temp_eth_asian3
drop temp_eth_asian1 temp_eth_asian2 temp_eth_asian3

*generate black ethnicity
gen temp_eth_black1 = inlist(motherethnicity, "Black African", "Black Caribbean", "Black-Other", "Black-Algerian", "Black-Angolan")
gen temp_eth_black2 = inlist(motherethnicity, "Black-Any other", "Black-Black British", "Black-Caribbean", "Black-Eritrean", "Black-Ethiopian")
gen temp_eth_black3 = inlist(motherethnicity, "Black-Ghanaian", "Black-Nigerian", "Black-Other", "Black-Other African", "Black-Other unspec")
gen temp_eth_black4 = inlist(motherethnicity, "Black-Somali", "Black-Sudanese", "Black-Ugandan")
gen eth_black = temp_eth_black1 | temp_eth_black2 | temp_eth_black3 | temp_eth_black4
drop temp_eth_black1 temp_eth_black2 temp_eth_black3 temp_eth_black4

*generate mixed ethnicity
gen temp_eth_mixed1 = inlist(motherethnicity, "White and Asian", "White and Black African", "White and Black Caribbean", "Mixed-Other", "Asian-Mixed Asian", "Black-Mixed Black")
gen temp_eth_mixed2 = inlist(motherethnicity, "Mixed-Any other", "Mixed-Asian/Chinese", "Mixed-Black/White", "Mixed-Chinese/White", "Mixed-Other unspec")
gen temp_eth_mixed3 = inlist(motherethnicity, "Mixed-Wh/Blk African", "Mixed-Wh/Blk C'bean", "Mixed-White/Asian", "White-Oth/Mixed Euro")
gen eth_mixed = temp_eth_mixed1 | temp_eth_mixed2 | temp_eth_mixed3
drop temp_eth_mixed1 temp_eth_mixed2 temp_eth_mixed3

*generate any other group ethnicity
gen temp_eth_other1 = inlist(motherethnicity, "Arab", "Any Other ethnic group", "Other-Any Other Grp", "Other-Any ethnic Grp", "Other-Arab", "Other-Columbian")
gen temp_eth_other2 = inlist(motherethnicity, "Other-Ecuadorian", "Other-Iranian", "Other-Iraqi", "Other-Latin American", "Other-Middle Eastern", "White-Mixed White")
gen eth_other = temp_eth_other1 | temp_eth_other2
drop temp_eth_other1 temp_eth_other2

cap drop eth_cat 
gen eth_cat = 1*eth_white + 2*eth_asian + 3*eth_black + 4*eth_mixed + 5*eth_other

#delim ;
label define eth_cat 
	1 "White"
	2 "Asian or Asian British" 
	3 "Black, Black British, Caribbean or African" 
	4 "Mixed or multiple ethnic groups"
	5 "Other ethnic group"
	, modify 
	;
#delim cr
label values eth_cat eth_cat 	
label var eth_cat "Mother's ethnicity"

bys eth_cat : tab motherethnicity

gen eth_unk = eth_cat == 0 | eth_cat == . 
label var eth_unk "Ethnicity unknown"
replace eth_cat = . if eth_cat == 0 

drop eth_missing eth_white eth_asian eth_black eth_mixed eth_other eth_unk

save maternal_neoDS1DS2DS5_v3, replace //45862
*************************************
