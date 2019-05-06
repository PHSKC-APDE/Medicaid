--Code to load data to final.apcd_claim_header table
--Distinct header-level claim variables (e.g. claim type). In other words elements for which there is only one distinct 
--value per claim header.
--Eli Kern (PHSKC-APDE)
--2019-4-26
------------------
--STEP 1: Insert data that has passed QA in stage schema table
-------------------
insert into PHClaims.final.apcd_claim_header with (tablock)
select
id_apcd,
extract_id,
claim_header_id,
submitter_id,
provider_id_apcd,
product_code_id,
first_service_dt,
last_service_dt,
first_paid_dt,
last_paid_dt,
charge_amt,
primary_diagnosis,
icdcm_version,
header_status,
claim_type_apcd_id,
claim_type_id,
type_of_bill_code,
ipt_flag,
discharge_dt,
ed_flag,
or_flag
from PHClaims.stage.apcd_claim_header;


