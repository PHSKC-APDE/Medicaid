--Code to load data to stage.apcd_dental_claim
--Eli Kern (PHSKC-APDE)
--2019-6-27

------------------
--STEP 1: Set cutoff date for pulling rows from archive table
-------------------
declare @cutoff_date date;
set @cutoff_date = '2017-12-31';

------------------
--STEP 2: Insert data into table shell
-------------------
insert into PHClaims.stage.apcd_dental_claim with (tablock)
--archived rows before cutoff date
select
[dental_claim_service_line_id]
,[extract_id]
,[submitter_id]
,[internal_member_id]
,[submitter_clm_control_num]
,[product_code_id]
,[product_code]
,[gender_code]
,[age]
,[age_in_months]
,[subscriber_relationship_id]
,[subscriber_relationship_code]
,[line_counter]
,[first_service_dt]
,[last_service_dt]
,[first_paid_dt]
,[last_paid_dt]
,[place_of_service_code]
,[procedure_code]
,[procedure_modifier_code_1]
,[procedure_modifier_code_2]
,[dental_tooth_system_id]
,[dental_tooth_system_code]
,[dental_tooth_code]
,[dental_quadrant_id]
,[dental_quadrant_code]
,[dental_tooth_surface_id]
,[dental_tooth_surface_code]
,[claim_status_id]
,[claim_status_code]
,[quantity]
,[charge_amt]
,[icd_version_ind]
,[principal_diagnosis_code]
,[rendering_provider_id]
,[rendering_internal_provider_id]
,[billing_provider_id]
,[billing_internal_provider_id]
,[network_indicator_id]
,[network_indicator_code]
,[city]
,[state]
,[zip]
,[age_65_flag]
,[out_of_state_flag]
,[orphaned_adjustment_flag]
,[denied_claim_flag]
from PHclaims.archive.apcd_dental_claim
where first_service_dt <= @cutoff_date
--new rows from new extract
union
select
[dental_claim_service_line_id]
,[extract_id]
,[submitter_id]
,[internal_member_id]
,[submitter_clm_control_num]
,[product_code_id]
,[product_code]
,[gender_code]
,[age]
,[age_in_months]
,[subscriber_relationship_id]
,[subscriber_relationship_code]
,[line_counter]
,[first_service_dt]
,[last_service_dt]
,[first_paid_dt]
,[last_paid_dt]
,[place_of_service_code]
,[procedure_code]
,[procedure_modifier_code_1]
,[procedure_modifier_code_2]
,[dental_tooth_system_id]
,[dental_tooth_system_code]
,[dental_tooth_code]
,[dental_quadrant_id]
,[dental_quadrant_code]
,[dental_tooth_surface_id]
,[dental_tooth_surface_code]
,[claim_status_id]
,[claim_status_code]
,[quantity]
,[charge_amt]
,[icd_version_ind]
,[principal_diagnosis_code]
,[rendering_provider_id]
,[rendering_internal_provider_id]
,[billing_provider_id]
,[billing_internal_provider_id]
,[network_indicator_id]
,[network_indicator_code]
,[city]
,[state]
,[zip]
,[age_65_flag]
,[out_of_state_flag]
,[orphaned_adjustment_flag]
,[denied_claim_flag]
from PHclaims.load_raw.apcd_dental_claim;


