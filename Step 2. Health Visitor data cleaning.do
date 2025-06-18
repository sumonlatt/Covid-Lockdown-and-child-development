version 18.0
clear
set more off
*SET the directory* //cd "***********"

***************************************************************************************
*Health visitor AN visit cutdown file 
***************************************************************************************
use  "B:\BRC_Elixir\DL046- McAlonan\00. Raw data bulk extract v3\Health Visitor Data_October 2024\healthvisit_AN.dta" ,clear
count //26154

rename Elixir_id elixir_id_mother
rename Completion_Date completion_date_hv000

*gen seq variable for AN visit
sort elixir_id_mother Age_at_Time_Yrs completion_date_hv000
by elixir_id_mother Age_at_Time_Yrs: gen ANvisit_seq= _n

*number of unique women with multiple birth episodes 
by elixir_id_mother: gen AN_preg_seq= _n
tab AN_preg_seq
save healthvisit_AN_v1, replace

lab var completion_date_hv000 "Completion date for AN registration"
keep if AN_preg_seq==1
keep elixir_id_mother ANcarereg_flag 
save healthvisit_AN_cutdown, replace //23317>>23292

***************************************************************************************
*Health visitor Newborn visit cutdown file 
***************************************************************************************
use  "B:\BRC_Elixir\DL046- McAlonan\00. Raw data bulk extract v3\Health Visitor Data_October 2024\healthvisit_Newbirth.dta" ,clear

rename Elixir_id elixir_id_baby
rename Mother_elixir_id elixir_id_mother
rename Method_of_feeding_at_contact feeding_type_hv00
rename Achievement_Flag achievement_flag_hv00
rename Completion_Date completion_date_hv00
rename Birth_weight_centile birth_weight_centile_hv00

* Labelling healthy child status
lab define healthychild 0 "Healthy Child Programme:Universal" 1"Healthy Child Programme:Universal Plus" 2 "Healthy Child Programme:Universal Partnership Plus"
encode Healthy_Child_Status, gen(healthy_child_status_hv00) label(healthychild)
tab healthy_child_status_hv00, miss
order healthy_child_status_hv00, after(Healthy_Child_Status)
drop Healthy_Child_Status

*extracting birthweight in Kg
gen str20 birth_weight=regexs(0) if regexm( Birth_weight_KG , "([0-9]+(\.[0-9]+)?)")
destring birth_weight, replace
gen birth_weight_hv00= round(birth_weight, 0.1)
lab var birth_weight_hv00 "Birth weight of the baby measured by HV in Kg"
order birth_weight_hv00, after( Birth_weight_KG )
drop Birth_weight_KG birth_weight

destring elixir_id_mother, ignore("NULL") replace

save healthvisit_NBreview_v1, replace
drop if elixir_id_baby==.

lab var feeding_type_hv00 "Method of feeding at Newborn visit"
lab var completion_date_hv00 "Completion date for Newborn visit"
lab var birth_weight_centile_hv00 "birthweight centile for Newborn visit"
gen newborn_contact=1

keep elixir_id_baby feeding_type_hv00 newborn_contact_flag completion_date_hv00 newborn_contact healthy_child_status_hv00 birth_weight_hv00 birth_weight_centile_hv00
save healthvisit_NBreview_cutdown, replace //22689 >> 22644

***************************************************************************************
*Health visitor Breastfeeding cutdown file 
***************************************************************************************
use  "B:\BRC_Elixir\DL046- McAlonan\00. Raw data bulk extract v3\Health Visitor Data_October 2024\healthvisit_BF.dta" ,clear

rename Elixir_id elixir_id_baby
rename Mother_elixir_id elixir_id_mother
rename Feeding_Type_Description feeding_type_hv0
rename Achievement_Flag achievement_flag_hv0
rename Completion_Date completion_date_hv0

* Labelling healthy child status
lab define healthychild 0 "Healthy Child Programme:Universal" 1"Healthy Child Programme:Universal Plus" 2 "Healthy Child Programme:Universal Partnership Plus"
encode Healthy_Child_Status, gen(healthy_child_status_hv0) label(healthychild)
tab healthy_child_status_hv0, miss
order healthy_child_status_hv0, after(Healthy_Child_Status)
drop Healthy_Child_Status
tab healthy_child_status_hv0, miss

destring elixir_id_mother, ignore("NULL") replace

save healthvisit_BFreview_v1, replace

lab var feeding_type_hv0 "Method of feeding at Breastfeeding contact"
lab var completion_date_hv0 "Completion date for Breastfeeding contact"
gen breastfeeding_contact=1

keep elixir_id_baby feeding_type_hv0 breastfeeding_contact_flag completion_date_hv0 breastfeeding_contact healthy_child_status_hv0
save healthvisit_BFreview_cutdown, replace //23304>>23253

***************************************************************************************
*Health visitor Review 1-15 month cleaning 
***************************************************************************************

use  "B:\BRC_Elixir\DL046- McAlonan\00. Raw data bulk extract v3\Health Visitor Data_October 2024\healthvisit_review1.dta" ,clear

* renaming variables- ensure tagging its from HV- review 1
rename Elixir_id elixir_id_baby
rename Mother_elixir_id elixir_id_mother
rename Gender gender_hv1 
rename Age_at_Quarter_End_Months baby_age_review1_mths
rename Mother_Age_at_Quarter_End_Yrs mother_age_review1_yrs
rename Healthy_Child_Status healthy_child_status_review1
rename Mother_elixir_id_alt elixir_id_mother_alt
rename Completion_Date completion_date_hv1
rename Achievement_Flag achievement_flag_hv1
rename Audiology_result audiology_result_hv1
rename Method_of_feeding_at_contact method_of_feeding_hv1
rename Date_mixed_feeding_was_introduce date_mixed_feeding_introduce_hv1
rename Date_breast_feeding_was_stopped Date_breast_feeding_stopped_hv1
rename Reason_breast_feeding_stopped reason_breastfeed_stopped_hv1
rename CC1_Service_Locality_Name CC1_Service_Locality_Name_hv1
rename Reporting_Period reporting_period_hv1

destring elixir_id_mother elixir_id_mother_alt mother_age_review1_yrs , ignore("NULL") replace

count // 16,802

*mother age at review 1
replace mother_age_review1_yrs=. if mother_age_review1_yrs<=14
tab mother_age_review1_yrs,miss 

* Labelling healthy child status
lab define healthychild 0 "Healthy Child Programme:Universal" 1"Healthy Child Programme:Universal Plus" 2 "Healthy Child Programme:Universal Partnership Plus"
encode healthy_child_status_review1, gen(healthy_child_status_HV1) label(healthychild)
tab healthy_child_status_HV1, miss
order healthy_child_status_HV1, after(healthy_child_status_review1)
drop healthy_child_status_review1

*extracting baby weight in Kg
gen str20 baby_weight=regexs(0) if regexm( Weight, "([0-9]+(\.[0-9]+)?)")
order baby_weight, after(Weight)
destring baby_weight, replace
gen baby_weight_hv1= round(baby_weight, 0.1)
replace baby_weight_hv1=. if baby_weight_hv1<=6 | baby_weight_hv1>=16
lab var baby_weight_hv1 "Weight of the baby in Kg"
drop Weight baby_weight

*extract baby length from string
gen str20 baby_length=regexs(0) if regexm( Length,"([0-9]+(\.[0-9]+)?)")
order baby_length, after(Length)
destring baby_length, replace
gen baby_length_hv1= round(baby_length, 0.01)
replace baby_length_hv1=. if baby_length_hv1<0.65 | baby_length_hv1>1
lab var baby_length_hv1 "length of the baby in metre"
drop Length baby_length 

*extract BMI from string 
gen str20 baby_BMI=regexs(0) if regexm( BMI,"([0-9]+(\.[0-9]+)?)")
order baby_BMI, after(BMI)
destring baby_BMI, replace

*generate a new bmi variable 
gen baby_BMI_hv1= round(baby_weight_hv1/ ( baby_length_hv1^2)) if baby_weight_hv1!=. & baby_length_hv1!=.
tab baby_BMI_hv1, miss
lab var baby_BMI_hv1 "BMI of the baby kg/m2 at health review 1"
drop BMI baby_BMI

*Fine motor skills at review 1
gen fine_motor_skills_hv1= "Completed or satisfactory" if Fine_Motor_skills=="Completed" | Fine_Motor_skills=="Satisfactory" |Fine_Motor_skills=="Partially completed"
replace fine_motor_skills_hv1="Null" if Fine_Motor_skills=="NULL"|Fine_Motor_skills=="Non compliance" | Fine_Motor_skills=="Not done"|Fine_Motor_skills=="Refused"
replace fine_motor_skills_hv1="observation" if Fine_Motor_skills=="Observation" 
replace fine_motor_skills_hv1="problem suspected or identified" if Fine_Motor_skills=="Problem" | Fine_Motor_skills=="Problem identified"|Fine_Motor_skills=="Problem suspected"
replace fine_motor_skills_hv1="referral or treatment" if Fine_Motor_skills=="Referral"| Fine_Motor_skills=="Treatment"
order fine_motor_skills_hv1, after(Fine_Motor_skills)
drop Fine_Motor_skills
lab var fine_motor_skills_hv1 "Fine motor skills at Health review 1"
tab fine_motor_skills_hv1, miss

* Social developlement at review 1
gen social_development_hv1= "Completed or satisfactory" if Social_development=="Completed" | Social_development=="Satisfactory" |Social_development=="Partially completed"
replace social_development_hv1="Null" if Social_development=="NULL"|Social_development=="Non compliance" | Social_development=="Not done"|Social_development=="Refused"
replace social_development_hv1="observation" if Social_development=="Observation" 
replace social_development_hv1="problem suspected or identified" if Social_development=="Problem" | Social_development=="Problem identified"|Social_development=="Problem suspected"
replace social_development_hv1="referral or treatment" if Social_development=="Referral"| Social_development=="Treatment"
order social_development_hv1, after(Social_development)
drop Social_development
lab var social_development_hv1 "Social development at Health review 1"
tab social_development_hv1, miss

* Vocalisation at review 1
gen vocalisation_hv1= "Completed or satisfactory" if Vocalisation=="Completed" | Vocalisation=="Satisfactory" |Vocalisation=="Partially completed"
replace vocalisation_hv1="Null" if Vocalisation=="NULL"|Vocalisation=="Non compliance" | Vocalisation=="Not done"|Vocalisation=="Refused"
replace vocalisation_hv1="observation" if Vocalisation=="Observation" 
replace vocalisation_hv1="problem suspected or identified" if Vocalisation=="Problem" | Vocalisation=="Problem identified"|Vocalisation=="Problem suspected"
replace vocalisation_hv1="referral or treatment" if Vocalisation=="Referral"| Vocalisation=="Treatment"
order vocalisation_hv1, after(Vocalisation)
drop Vocalisation
lab var vocalisation_hv1 "Fine motor skills at Health review 1"
tab vocalisation_hv1, miss

*replace Null
foreach var in vocalisation_hv1 social_development_hv1 fine_motor_skills_hv1 {
    replace `var' = "" if `var' == "Null"
}

/* clean audiology result
gen audiology_result_hv1=Audiology_result 
replace audiology_result_hv1= "Completed or satisfactory" if Audiology_result=="Completed" | Audiology_result=="Satisfactory" 
replace audiology_result_hv1="." if Audiology_result=="NULL"|Audiology_result=="Testing in progress" | Audiology_result=="Testing pending"
tab audiology_result_hv1 */


*labelling variables
lab var mother_age_review1_yrs "Mother's age at review 1"
lab var method_of_feeding_hv1 "Method of Feeding at Health Review 1"
lab var completion_date_hv1 "Completion Date for Health Review 1"
lab var achievement_flag_hv1 "Timely Achievement Flag for Review 1"
lab var baby_weight_hv1 "Baby weight in Kg at Health Review 1"
lab var baby_length_hv1 "Baby Length in metre at Health Review 1"
lab var Ethnicity_Code "baby ethnicity code from HV data"
lab var Ethnicity_Description "baby's ethnicity description from HV data"

*method of feeding recoding
rename method_of_feeding_hv1 method_of_feeding_hv1_string
encode method_of_feeding_hv1_string, gen( method_of_feeding_hv1)
tab method_of_feeding_hv1
tab method_of_feeding_hv1, nolabel
order method_of_feeding_hv1, after( method_of_feeding_hv1_string)
drop method_of_feeding_hv1_string

gen review1_contact=1 

save healthvisit_review1_v1, replace

drop PK elixir_id_mother_alt Cohort_Description LSOA  Practice_Code Practice_Name Weight_centile Height_length_centile Method_of_feeding_first_feed date_mixed_feeding_introduce_hv1 Date_breast_feeding_stopped_hv1  How_would_mother_rate_breastfeed Who_has_supported_you_with_breas Team_Name Reporting_Month Truncated_DoB Truncated_Mother_DoB Weight_at_contact_KG Recall gender_hv1 achievement_flag_hv1 reporting_period_hv1 CC1_Service_Locality_Name_hv1 datasource_HV1 healthvisit_number n_missing_fields reason_breastfeed_stopped_hv1

save healthvisit_review1_cutdown, replace //16802 >>16744 observation 
***************************************************************************************
*Health visitor Review 2 cleaning 
***************************************************************************************
use  "B:\BRC_Elixir\DL046- McAlonan\00. Raw data bulk extract v3\Health Visitor Data_October 2024\healthvisit_review2.dta" ,clear
rename Elixir_id elixir_id_baby
rename Mother_elixir_id elixir_id_mother
rename Gender gender_hv2
rename Age_at_Quarter_End_Years baby_age_review2_years
rename Mother_Age_at_Quarter_End_Yrs mother_age_review2_yrs
rename Healthy_Child_Status healthy_child_status_review2
rename Ethnicity_Code ethnicity_code_hv2
rename Ethnicity_Description ethnicity_description_hv2
rename CC1_Service_Locality_Name cc1_service_locality_name_hv2
rename Completion_Date completion_date_hv2
rename Achievement_Flag achievement_flag_hv2

* Labelling healthy child status
lab define healthychild 0 "Healthy Child Programme:Universal" 1"Healthy Child Programme:Universal Plus" 2 "Healthy Child Programme:Universal Partnership Plus"
encode healthy_child_status_review2, gen(healthy_child_status_hv2) label(healthychild)
tab healthy_child_status_hv2, miss
order healthy_child_status_hv2, after(healthy_child_status_review2)
drop healthy_child_status_review2

*change into numerical variable 
destring elixir_id_mother mother_age_review2_yrs ASQ24monthquestionnaire_Communic ASQ24monthquestionnaire_Gross_Mo ASQ24monthquestionnaire_Fine_Mot ASQ24monthquestionnaire_Problem_ ASQ24monthquestionnaire_Personal ASQ27monthquestionnaire_Communic ASQ27monthquestionnaire_Gross_Mo ASQ27monthquestionnaire_Fine_Mot ASQ27monthquestionnaire_Problem_ ASQ27monthquestionnaire_Personal ASQ30monthquestionnaire_Communic ASQ30monthquestionnaire_Gross_Mo ASQ30monthquestionnaire_Fine_Mot ASQ30monthquestionnaire_Problem_ ASQ30monthquestionnaire_Personal ASQAgesandstagesquestionnaire_So ASQAgesandstages3Socialandemotio , ignore("NULL") replace

*extracting baby weight in Kg
gen str20 baby_weight=regexs(0) if regexm( Weight_KG, "([0-9]+(\.[0-9]+)?)")
order baby_weight, after(Weight_KG)
destring baby_weight, replace
gen baby_weight_hv2= round(baby_weight, 0.1)
replace baby_weight_hv2=. if baby_weight_hv2<=8 | baby_weight_hv2>=25
lab var baby_weight_hv2 "Weight of the baby in Kg at health review 2"
drop Weight_KG baby_weight

*extract baby height from string
gen str20 baby_height=regexs(0) if regexm( Height,"([0-9]+(\.[0-9]+)?)")
order baby_height, after(Height)
destring baby_height, replace
gen baby_height_hv2= round(baby_height, 0.01)
replace baby_height_hv2=. if baby_height_hv2<=0.8 | baby_height_hv2>=1.1
lab var baby_height_hv2 "Height of the baby in metre at health review 2"
drop Height baby_height

*generate a new bmi variable 
gen baby_BMI_hv2= round(baby_weight_hv2/ ( baby_height_hv2^2)) if baby_weight_hv2!=. & baby_height_hv2!=.
tab baby_BMI_hv2, miss
lab var baby_BMI_hv2 "BMI of the baby kg/m2 at health review 2"
drop BMI 

*generate one value for ASQ score 
egen ASQ_communication=rowmax( ASQ24monthquestionnaire_Communic ASQ27monthquestionnaire_Communic ASQ30monthquestionnaire_Communic)
egen ASQ_grossmotor=rowmax( ASQ24monthquestionnaire_Gross_Mo ASQ27monthquestionnaire_Gross_Mo ASQ30monthquestionnaire_Gross_Mo )
egen ASQ_finemotor=rowmax( ASQ24monthquestionnaire_Fine_Mot ASQ27monthquestionnaire_Fine_Mot ASQ30monthquestionnaire_Fine_Mot )
egen ASQ_problemsolving=rowmax( ASQ24monthquestionnaire_Problem_ ASQ27monthquestionnaire_Problem_ ASQ30monthquestionnaire_Problem_ )
egen ASQ_personal_social=rowmax( ASQ24monthquestionnaire_Personal ASQ27monthquestionnaire_Personal ASQ30monthquestionnaire_Personal)

replace ASQ_communication=. if ASQ_communication==0
replace ASQ_grossmotor=. if ASQ_grossmotor==0
replace ASQ_finemotor=. if ASQ_finemotor==0
replace ASQ_problemsolving=. if ASQ_problemsolving==0
replace ASQ_personal_social=. if ASQ_personal_social==0

tab ASQWasitcompletedaspartofa2yearr

*tagging question type1=24 month, 2= 27 month questions, 3=30 month questions
gen ASQ_questiontype=.
replace ASQ_questiontype=1 if ASQ24monthquestionnaire_Communic!=.
replace ASQ_questiontype=2 if ASQ27monthquestionnaire_Communic !=.
replace ASQ_questiontype=3 if ASQ30monthquestionnaire_Communic !=.
tab ASQ_questiontype, miss
lab def ASQ_question 1"24 month questionnarie" 2"27 month questionnaire" 3"30 month questionnaire"
lab value ASQ_questiontype ASQ_question 

*health review 2- behavioural problem
gen behavioural_dev_hv2= "Completed or satisfactory" if Behavioural_and_emotional_develo=="Completed" | Behavioural_and_emotional_develo=="Satisfactory" |Behavioural_and_emotional_develo=="Partially completed"
replace behavioural_dev_hv2="Null" if Behavioural_and_emotional_develo=="NULL"|Behavioural_and_emotional_develo=="Non compliance" | Behavioural_and_emotional_develo=="Not done"|Behavioural_and_emotional_develo=="Refused"
replace behavioural_dev_hv2="observation" if Behavioural_and_emotional_develo=="Observation" 
replace behavioural_dev_hv2="problem suspected or identified" if Behavioural_and_emotional_develo=="Problem" | Behavioural_and_emotional_develo=="Problem identified"|Behavioural_and_emotional_develo=="Problem suspected"
replace behavioural_dev_hv2="referral or treatment" if Behavioural_and_emotional_develo=="Referral"| Behavioural_and_emotional_develo=="Treatment"
tab behavioural_dev_hv2 Behavioural_and_emotional_develo
order behavioural_dev_hv2, after(Behavioural_and_emotional_develo)
drop Behavioural_and_emotional_develo
lab var behavioural_dev_hv2 "Behaviour and emotional development problems at Health review 2"
tab behavioural_dev_hv2, miss 

* health review 2- speech and language problems
gen speech_language_hv2= "Completed or satisfactory" if Speech_and_language_communicatio=="Completed" | Speech_and_language_communicatio=="Satisfactory" |Speech_and_language_communicatio=="Partially completed"
replace speech_language_hv2="Null" if Speech_and_language_communicatio=="NULL"|Speech_and_language_communicatio=="Non compliance" | Speech_and_language_communicatio=="Not done"|Speech_and_language_communicatio=="Refused"
replace speech_language_hv2="observation" if Speech_and_language_communicatio=="Observation" 
replace speech_language_hv2="problem suspected or identified" if Speech_and_language_communicatio=="Problem" | Speech_and_language_communicatio=="Problem identified"|Speech_and_language_communicatio=="Problem suspected"
replace speech_language_hv2="referral or treatment" if Speech_and_language_communicatio=="Referral"| Speech_and_language_communicatio=="Treatment"
order speech_language_hv2, after(Speech_and_language_communicatio)
drop Speech_and_language_communicatio
lab var speech_language_hv2 "Speech and language problems at Health review 2"
tab speech_language_hv2, miss 

*health review 2- diet and nutrition 
gen diet_nutrition_hv2= "Completed or satisfactory" if Diet_and_nutrition=="Completed" | Diet_and_nutrition=="Satisfactory" |Diet_and_nutrition=="Partially completed"
replace diet_nutrition_hv2="Null" if Diet_and_nutrition=="NULL"|Diet_and_nutrition=="Non compliance" | Diet_and_nutrition=="Not done"|Diet_and_nutrition=="Refused"
replace diet_nutrition_hv2="observation" if Diet_and_nutrition=="Observation" 
replace diet_nutrition_hv2="problem suspected or identified" if Diet_and_nutrition=="Problem" | Diet_and_nutrition=="Problem identified"|Diet_and_nutrition=="Problem suspected"
replace diet_nutrition_hv2="referral or treatment" if Diet_and_nutrition=="Referral"| Diet_and_nutrition=="Treatment"
order diet_nutrition_hv2, after(Diet_and_nutrition)
drop Diet_and_nutrition
lab var diet_nutrition_hv2 "Diet and Nurtition problems at Health review 2"
tab diet_nutrition_hv2, miss

*health review 2- family and social relationships 
gen family_social_relationships_hv2= "Completed or satisfactory" if Family_and_social_relationships=="Completed" | Family_and_social_relationships=="Satisfactory" |Family_and_social_relationships=="Partially completed"
replace family_social_relationships_hv2="Null" if Family_and_social_relationships=="NULL"|Family_and_social_relationships=="Non compliance" | Family_and_social_relationships=="Not done"|Family_and_social_relationships=="Refused"
replace family_social_relationships_hv2="observation" if Family_and_social_relationships=="Observation" 
replace family_social_relationships_hv2="problem suspected or identified" if Family_and_social_relationships=="Problem" | Family_and_social_relationships=="Problem identified"|Family_and_social_relationships=="Problem suspected"
replace family_social_relationships_hv2="referral or treatment" if Family_and_social_relationships=="Referral"| Family_and_social_relationships=="Treatment"
order family_social_relationships_hv2, after(Family_and_social_relationships)
drop Family_and_social_relationships
lab var family_social_relationships_hv2 "Family and Social relationship problems at Health review 2"
tab family_social_relationships_hv2, miss

*health review 2- General health and medical condition
gen general_health_hv2= "Completed or satisfactory" if General_health_medical_condition=="Completed" | General_health_medical_condition=="Satisfactory" |General_health_medical_condition=="Partially completed"
replace general_health_hv2="Null" if General_health_medical_condition=="NULL"|General_health_medical_condition=="Non compliance" | General_health_medical_condition=="Not done"|General_health_medical_condition=="Refused"
replace general_health_hv2="observation" if General_health_medical_condition=="Observation" 
replace general_health_hv2="problem suspected or identified" if General_health_medical_condition=="Problem" | General_health_medical_condition=="Problem identified"|General_health_medical_condition=="Problem suspected"
replace general_health_hv2="referral or treatment" if General_health_medical_condition=="Referral"| General_health_medical_condition=="Treatment"
order general_health_hv2, after(General_health_medical_condition)
drop General_health_medical_condition
lab var general_health_hv2 "General health and medical condition at Health review 2"
tab general_health_hv2, miss

*health review 2 - Indepandent self care skills 
gen self_careskills_hv2= "Completed or satisfactory" if Independence_self_care_skills=="Completed" | Independence_self_care_skills=="Satisfactory" |Independence_self_care_skills=="Partially completed"
replace self_careskills_hv2="Null" if Independence_self_care_skills=="NULL"|Independence_self_care_skills=="Non compliance" | Independence_self_care_skills=="Not done"|Independence_self_care_skills=="Refused"
replace self_careskills_hv2="observation" if Independence_self_care_skills=="Observation" 
replace self_careskills_hv2="problem suspected or identified" if Independence_self_care_skills=="Problem" | Independence_self_care_skills=="Problem identified"|Independence_self_care_skills=="Problem suspected"
replace self_careskills_hv2="referral or treatment" if Independence_self_care_skills=="Referral"| Independence_self_care_skills=="Treatment"
order self_careskills_hv2, after(Independence_self_care_skills)
drop Independence_self_care_skills
lab var self_careskills_hv2 "General health and medical condition at Health review 2"
tab self_careskills_hv2, miss

foreach var in behavioural_dev_hv2 diet_nutrition_hv2 family_social_relationships_hv2 general_health_hv2 self_careskills_hv2 speech_language_hv2 {
    replace `var' = "" if `var' == "Null"
}

* rename var whether ASQ score completed or not
rename ASQWasitcompletedaspartofa2yearr ASQscore_completed_binary_hv2
replace ASQscore_completed_binary_hv2="No" if ASQscore_completed_binary_hv2=="NULL"
encode ASQscore_completed_binary_hv2, gen(ASQscore_completed_hv2)
order ASQscore_completed_hv2, after(ASQscore_completed_binary_hv2)
drop ASQscore_completed_binary_hv2
save healthvisit_review2_v1, replace

*dropping variables and creating cutdown file
drop PK Mother_elixir_id_alt Cohort_Description LSOA Practice_Code Practice_Name Weight_centile Height_centile AH Reporting_Month Reporting_Period Team_Name Truncated_DoB Truncated_Mother_DoB ASQ24monthquestionnaire_Communic ASQ24monthquestionnaire_Gross_Mo ASQ24monthquestionnaire_Fine_Mot ASQ24monthquestionnaire_Problem_ ASQ24monthquestionnaire_Personal ASQ27monthquestionnaire_Communic ASQ27monthquestionnaire_Gross_Mo ASQ27monthquestionnaire_Fine_Mot ASQ27monthquestionnaire_Problem_ ASQ27monthquestionnaire_Personal ASQ30monthquestionnaire_Communic ASQ30monthquestionnaire_Gross_Mo ASQ30monthquestionnaire_Fine_Mot ASQ30monthquestionnaire_Problem_ ASQ30monthquestionnaire_Personal ASQAgesandstagesquestionnaire_So ASQAgesandstages3Socialandemotio

count // 10022 observation 
*gen communication score binary
gen ASQ_communication_binary=0 if ASQ_communication !=.
replace ASQ_communication_binary=1 if ASQ_communication <25 & ASQ_questiontype==1
replace ASQ_communication_binary=1 if ASQ_communication <24 & ASQ_questiontype==2
replace ASQ_communication_binary=1 if ASQ_communication <33 & ASQ_questiontype==3
tab ASQ_communication_binary
lab define asq_binary 0 "above the expected ASQ-3 threshold"  1 "below the expected ASQ-3 threshold"
lab value  ASQ_communication_binary asq_binary

*generate gross motor score binary 
gen ASQ_grossmotor_binary=0 if ASQ_grossmotor !=.
replace ASQ_grossmotor_binary=1 if ASQ_grossmotor <38 & ASQ_questiontype==1
replace ASQ_grossmotor_binary=1 if ASQ_grossmotor <28 & ASQ_questiontype==2
replace ASQ_grossmotor_binary=1 if ASQ_grossmotor <36 & ASQ_questiontype==3
tab ASQ_grossmotor_binary
lab value  ASQ_grossmotor_binary asq_binary

* creat binary for ASQ_finemotor  
gen ASQ_finemotor_binary=0 if ASQ_finemotor !=.
replace ASQ_finemotor_binary=1 if ASQ_finemotor <35 & ASQ_questiontype==1
replace ASQ_finemotor_binary=1 if ASQ_finemotor <18 & ASQ_questiontype==2
replace ASQ_finemotor_binary=1 if ASQ_finemotor <19 & ASQ_questiontype==3
tab ASQ_finemotor_binary
lab value  ASQ_finemotor_binary asq_binary

*create binary variable for ASQ_problemsolving
gen ASQ_problemsolving_binary=0 if ASQ_problemsolving !=.
replace ASQ_problemsolving_binary=1 if ASQ_problemsolving <29 & ASQ_questiontype==1
replace ASQ_problemsolving_binary=1 if ASQ_problemsolving <27 & ASQ_questiontype==2
replace ASQ_problemsolving_binary=1 if ASQ_problemsolving <27 & ASQ_questiontype==3
tab ASQ_problemsolving_binary 
lab value  ASQ_problemsolving_binary asq_binary

*create binary variable for ASQ_personal_social
gen ASQ_personal_social_binary=0 if ASQ_personal_social !=.
replace ASQ_personal_social_binary=1 if ASQ_personal_social <31 & ASQ_questiontype==1
replace ASQ_personal_social_binary=1 if ASQ_personal_social <25 & ASQ_questiontype==2
replace ASQ_personal_social_binary=1 if ASQ_personal_social <32 & ASQ_questiontype==3
tab ASQ_personal_social_binary
lab value  ASQ_personal_social_binary asq_binary

* create a variable to indicate the number of domains with the below threshold score
gen ASQ_alldomain_temp= ASQ_communication_binary+ ASQ_grossmotor_binary+ASQ_finemotor_binary+ASQ_problemsolving_binary+ASQ_personal_social_binary

gen belowcutoffscore_anyASQdomain=0 if ASQ_alldomain_temp!=.
replace belowcutoffscore_anyASQdomain=1 if ASQ_alldomain_temp>=1 & ASQ_alldomain_temp!=.

gen review2_contact=1

*dropping more variables 
drop gender_hv2 ethnicity_code_hv2 ethnicity_description_hv2 achievement_flag_hv2 cc1_service_locality_name_hv2 healthvisit_number n_missing_fields ASQ_alldomain_temp

save healthvisit_review2_cutdown, replace 

***********************
