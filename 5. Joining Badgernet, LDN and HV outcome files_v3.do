***********************************************************************************
*	Do-file:		Merging HV data to Maternity data files.do
*	Project:		GEN2020 elixir 
*	Date:			April 2025
*
*	Data used:		lambeth_maternal_neo_v1
*   Data sources:   Merging HV datasets to Maternity data file 
* 	Purpose:  		Master data file 
***********************************************************************************
cap log close
version 18.0
clear
set more off
cd "B:\BRC_Elixir\DL046- McAlonan\01. GEN 2020 STATA v3"
********************
***********************************************************************************
** Adding health visitor data to the main data file  
***********************************************************************************
use maternal_neoDS1DS2DS5_v3, clear //

*adding birthweight centile data
merge 1:1 elixir_id_baby using "B:\BRC_Elixir\DL046- McAlonan\00. Raw data bulk extract v3\Maternal data\birthweight_centiles.dta"
drop if _m==2
drop _m

*Adding AN registration data 
merge m:1 elixir_id_mother using healthvisit_AN_cutdown
drop if _m==2 //19441 matched, 6743 drop 
drop _m

*adding new born review file 
merge 1:1 elixir_id_baby using healthvisit_NBreview_cutdown
drop if _m==2 //19389 matched, 3255 dropped 
drop _m
replace newborn_contact=0 if newborn_contact==.
tab newborn_contact

*adding HV breastfeeding review file 
merge 1:1 elixir_id_baby using healthvisit_BFreview_cutdown
drop if _m==2 //20016 matched, 3237 dropped 
drop _m
replace breastfeeding_contact=0 if breastfeeding_contact==.
tab breastfeeding_contact

*adding HV review 1 file
merge 1:1 elixir_id_baby elixir_id_mother using healthvisit_review1_cutdown //13849 merged, 2895 dropped 
drop if _m==2
drop _m
replace review1_contact=0 if review1_contact==.
tab review1_contact_flag

*adding HV review 2 file 
merge 1:1 elixir_id_baby elixir_id_mother using healthvisit_review2_cutdown //7551 merged, 2419 dropped 
drop if _m==2
drop _m
replace review2_contact=0 if review2_contact==.
tab review2_contact

*dropping multiplet 
*keep if multiplet==0 //1462 deleted, 36,539 left, 13516 kids with health review 1, 7328 health review 2

*calculate age at the time of health visitor dataset extraction
gen HVdata_extractdate=mdy(9,30,2023)
format HVdata_extractdate %td
gen baby_age_atHVdataextraction=age(Truncated_DeliveryDate, HVdata_extractdate) 
*Note, 147 babies who were born on 1st oct are not in HVdata extract date so excluded in the table
tab HVdata_extractdate,miss 
tab baby_age_atHVdataextraction  
drop HVdata_extractdate

*labelling variable 
lab var ANcarereg_flag "Antenatal registration with the Health Visiting Team"
replace ANcarereg_flag=0 if ANcarereg_flag==.
lab var newborn_contact "Newborn contact"
lab var  breastfeeding_contact "Breastfeeding contact at 6-8 weeks"
lab var review1_contact "Review 1 contact at Age 1"
lab var review2_contact "Review 2 contact at Age 2"

lab var baby_age_atHVdataextraction "Baby's age on 30 Sept 2023- Last date available for HV data extract "
lab define contact_flag 0 "No" 1"Yes"
lab val ANcarereg_flag contact_flag
lab val  newborn_contact_flag contact_flag
lab val  breastfeeding_contact_flag contact_flag
lab val  review1_contact_flag contact_flag
lab val  review2_contact_flag contact_flag
lab val  newborn_contact contact_flag
lab val  breastfeeding_contact contact_flag
lab val  review1_contact contact_flag
lab val  review2_contact contact_flag

** REVIEW THIS- are we counting the visits with no information?***
*generating total health visit 
egen total_hvvisit=rowtotal( newborn_contact breastfeeding_contact review1_contact review2_contact)
replace total_hvvisit=. if newborn_contact==. & breastfeeding_contact==. & review1_contact==. & review2_contact==.
tab total_hvvisit
br total_hvvisit ANcarereg_flag newborn_contact breastfeeding_contact review1_contact review2_contact
label variable total_hvvisit "Total number of health visiting contacts between birth and 30 Sept 23"

*hv total at 2 years categorical 
gen total_hvvisit_2yr= total_hvvisit if baby_age_atHVdataextraction>=2
recode total_hvvisit_2yr (0/2=0) (3=1) (4=2)
tab total_hvvisit_2yr
lab define healthvisittotal 0 "received less than 3 mandated contacts" 1"received 3 mandated contacts" 2 "received all 4 mandated contacts"
lab value total_hvvisit_2yr healthvisittotal
tab total_hvvisit_2yr
lab var total_hvvisit_2yr " total number of health visiting contacts between birth and age 2"

*hv total at one year categorical 
gen total_hvvisit_1yr= total_hvvisit if baby_age_atHVdataextraction<2
recode total_hvvisit_1yr (0/1=0) (2=1) (3=2)
tab total_hvvisit_1yr
lab define healthvisittotal_1yr 0 "None or only 1 mandated contact" 1"received 2 mandated contacts" 2 "received all 3 mandated contacts"
lab value total_hvvisit_1yr healthvisittotal_1yr
tab total_hvvisit_1yr

*hv total at 1 year and two years numeric variables
gen total_hvvisit_2yr_numeric= total_hvvisit if baby_age_atHVdataextraction>=2
gen total_hvvisit_1yr_numeric= total_hvvisit if baby_age_atHVdataextraction>=1

* baby age at HV extraction category variables
gen baby_age_atHVdataextraction_cat= baby_age_atHVdataextraction
recode baby_age_atHVdataextraction_cat (3/4=2)
tab baby_age_atHVdataextraction_cat
lab define babyage 0 " 0-1 year old" 1" 1-2 year old" 2 "2-4 year old"
lab value baby_age_atHVdataextraction_cat babyage
tab baby_age_atHVdataextraction_cat

replace child_slam_referral=0 if child_slam_referral==.
replace mother_ever_slam_referral =0 if mother_ever_slam_referral ==.
lab define slamreferral 0 "No" 1 "Yes"
lab value mother_ever_slam_referral slamreferral
lab value child_slam_referral slamreferral

*removing PRUH data - review this 
*gen drop1= bookingdate <daily("01july2021","DMY")  & BookingHospital=="Princess Royal University Hospital"
*gen drop2= bookingdate <daily("01july2021","DMY")  & DeliveryHospital=="Princess Royal University Hospital"
drop if yearofbooking==2020 & DeliveryHospital=="Princess Royal University Hospital"
*drop if drop1==1 | drop2==1
*count // 45,859

save maternal_neoDS1DS2DS5_hv3, replace
******************************************************
*data summary for the HV contacts number by age 
******************************************************
use maternal_neoDS1DS2DS5_hv3, clear 

count if LA_district_name=="Lambeth" | LA_district_name=="Southwark" //23,094
gen district_name= "other"
replace district_name= "Lambeth and Southwark" if LA_district_name=="Lambeth" | LA_district_name=="Southwark"
keep if LA_district_name=="Lambeth" | LA_district_name=="Southwark"
drop if baby_age_atHVdataextraction_cat==. //59 obs deleted 
count //23035

*saving as a different file for the sub-cohort
save DS1and2_healthvisit_ldnswk,replace 

*Health visiting paper descriptive 
use DS1and2_healthvisit_ldnswk, clear

log using healthvisit_descriptive_v3_april25, replace

*unique pregnancy count
sort elixir_id_mother bookingdate
by elixir_id_mother bookingdate : gen pregseq= _n
tab pregseq //22644  mums
lab var pregseq "sequence of pregnancy within elixir cohort"

* country of origin
tab CountryofBirth if pregseq==1

*total hv visit binary
gen total_hvvisit_binary= 0
replace total_hvvisit_binary=1 if total_hvvisit>=1
lab define totalhvcat 0 "No HV contact" 1 " One or more HV contact"
lab value total_hvvisit_binary totalhvcat

*slam binary 
generate preg_slam_referral=0
replace preg_slam_referral= 1 if preg_ePJS==1 | Preg_IAPT==1
tab preg_slam_referral, miss
lab val preg_slam_referral slamreferral
tab preg_slam_referral, miss
lab var preg_slam_referral "Referral to SLAM for either mental health services or talking therapies during pregnancy"

dtable i.ANcarereg_flag i.newborn_contact i.newborn_contact_flag i.breastfeeding_contact i.breastfeeding_contact_flag i.review1_contact i.review1_contact_flag i.review2_contact i.review2_contact_flag, by (baby_age_atHVdataextraction_cat)

*healthy child status 
dtable i.healthy_child_status_hv00 i.healthy_child_status_hv0 i.healthy_child_status_HV1 i.healthy_child_status_hv2, by( data_source )

*Characteristics of women and their birth outcomes attending antenatal appointments at GSTT and KCH residing in Southwark and Lambeth LAs between 1 Oct 2018 and 30 September 2023"
dtable AgeAtDelivery i.Agedel_cat i.eth_cat i.imd_quint i.born_in_uk i.primary_language_eng GestationAtDeliveryWeeks i.gestdel_n i.parity_booking_n i.multiplet i.modeofdelivery i.modeofdelivery_binary i.sex BirthWeightGrams i.birthweight_n i.livebirth, by( data_source  )

*descriptives by number of contacts
dtable AgeAtDelivery i.Agedel_cat i.eth_cat i.imd_quint i.born_in_uk i.primary_language_eng i.parity_booking_n GestationAtDeliveryWeeks i.gestdel_n i.multiplet i.modeofdelivery i.modeofdelivery_binary i.sex BirthWeightGrams i.birthweight_n i.centile_category i.livebirth i.epilepsy i.bmiatbooking_cat i.preg_slam_referral i.neonadm , by( total_hvvisit_binary, test  )

tab eth_cat total_hvvisit_binary, column miss

*Characteristics of women and their birth outcomes attending antenatal appointments at GSTT and KCH residing in Southwark and Lambeth LAs between 1 Oct 2018 and 30 September 2023"
dtable i.baby_age_atHVdataextraction_cat i.review2_contact i.review2_contact_flag  i.healthy_child_status_hv2 i.ASQscore_completed_hv2 baby_weight_hv2 baby_height_hv2 ASQ_communication i.ASQ_communication_binary ASQ_grossmotor i.ASQ_grossmotor_binary ASQ_finemotor i.ASQ_finemotor_binary ASQ_problemsolving i.ASQ_problemsolving_binary ASQ_personal_social i.ASQ_personal_social_binary, by( data_source  )

* Healthy child status 
tab healthy_child_status_hv00 if newborn_contact==1, miss
tab healthy_child_status_hv0 if breastfeeding_contact ==1, miss
tab healthy_child_status_HV1  if review1_contact ==1, miss
tab healthy_child_status_hv2  if review2_contact ==1, miss

*baby weight 
replace birth_weight_hv00=. if birth_weight_hv00==19.3
su birth_weight_hv00 if newborn_contact==1 
su baby_weight_hv1 if review1_contact ==1
su baby_weight_hv2 if review2_contact ==1
su baby_length_hv1 if review1_contact ==1
su baby_height_hv2 if review2_contact ==1


count if baby_length_hv1 ==. & review1_contact ==1
count if baby_weight_hv1==. & review2_contact ==1

count if ASQ_communication !=. & review2_contact_flag==1
count if ASQ_grossmotor !=. & review2_contact_flag==1
count if ASQ_finemotor !=. & review2_contact_flag==1
count if ASQ_problemsolving !=. & review2_contact_flag==1
count if ASQ_personal_social !=. & review2_contact_flag==1
count if ASQ_questiontype !=. & review2_contact_flag==1
tab ASQ_questiontype if review2_contact_flag==1 , miss

* feeding type
tab feeding_type_hv00  if newborn_contact==1, miss
tab feeding_type_hv0  if breastfeeding_contact ==1, miss
tab method_of_feeding_hv1  if review1_contact ==1, miss

* imd differences between 2 boroughs no major differences 
tab imd_quintile LA_district_name, column miss
tab eth_cat LA_district_name, column miss

*ethnicity differences
tab ANcarereg_flag eth_cat, column miss
tab newborn_contact eth_cat, column miss
tab breastfeeding_contact eth_cat,column miss
tab review1_contact eth_cat if baby_age_atHVdataextraction>=1 ,column miss
tab review2_contact eth_cat if baby_age_atHVdataextraction>=2, column miss

*imd differences
tab ANcarereg_flag imd_quintile, column miss
tab newborn_contact imd_quintile, column miss
tab breastfeeding_contact imd_quintile,column miss
tab review1_contact imd_quintile if baby_age_atHVdataextraction>=1 ,column miss
tab review2_contact imd_quintile if baby_age_atHVdataextraction>=2, column miss

*borough differences
tab ANcarereg_flag LA_district_name, column miss
tab newborn_contact LA_district_name, column miss
tab breastfeeding_contact LA_district_name,column miss
tab review1_contact LA_district_name if baby_age_atHVdataextraction>=1 ,column miss
tab review2_contact LA_district_name if baby_age_atHVdataextraction>=2, column miss

log close
***********************************************************************************


