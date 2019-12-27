--Code to load data to stage.mcare_snf_base_claims
--Union of single-year files
--Eli Kern (PHSKC-APDE)
--2019-12
--Run time: xx min


insert into PHClaims.stage.mcare_snf_base_claims_load with (tablock)

--2014 data
select
bene_id as id_mcare
,clm_id as claim_header_id
,clm_from_dt as first_service_date
,clm_thru_dt as last_service_date
,clm_mdcr_non_pmt_rsn_cd as denial_code_facility
,nch_clm_type_cd as claim_type
,clm_fac_type_cd as facility_type_code
,clm_srvc_clsfctn_type_cd as service_type_code
,clm_admsn_dt as admission_date
,nch_bene_dschrg_dt as discharge_date
,clm_ip_admsn_type_cd as ipt_admission_type
,clm_src_ip_admsn_cd as ipt_admission_source
,clm_drg_cd as drg_code
,nch_ptnt_status_ind_cd as patient_status
,ptnt_dschrg_stus_cd as patient_status_code
,at_physn_npi as provider_attending_npi
,at_physn_spclty_cd as provider_attending_specialty
,op_physn_npi as provider_operating_npi
,op_physn_spclty_cd as provider_operating_specialty
,org_npi_num as provider_org_npi
,ot_physn_npi as provider_other_npi
,ot_physn_spclty_cd as provider_other_specialty
,rndrng_physn_npi as provider_rendering_npi
,rndrng_physn_spclty_cd as provider_rendering_specialty
,admtg_dgns_cd as dxadmit
,prncpal_dgns_cd as dx01
,icd_dgns_cd1 as dx02
,icd_dgns_cd2 as dx03
,icd_dgns_cd3 as dx04
,icd_dgns_cd4 as dx05
,icd_dgns_cd5 as dx06
,icd_dgns_cd6 as dx07
,icd_dgns_cd7 as dx08
,icd_dgns_cd8 as dx09
,icd_dgns_cd9 as dx10
,icd_dgns_cd10 as dx11
,icd_dgns_cd11 as dx12
,icd_dgns_cd12 as dx13
,icd_dgns_cd13 as dx14
,icd_dgns_cd14 as dx15
,icd_dgns_cd15 as dx16
,icd_dgns_cd16 as dx17
,icd_dgns_cd17 as dx18
,icd_dgns_cd18 as dx19
,icd_dgns_cd19 as dx20
,icd_dgns_cd20 as dx21
,icd_dgns_cd21 as dx22
,icd_dgns_cd22 as dx23
,icd_dgns_cd23 as dx24
,icd_dgns_cd24 as dx25
,icd_dgns_cd25 as dx26
,fst_dgns_e_cd as dxecode_1
,icd_dgns_e_cd1 as dxecode_2
,icd_dgns_e_cd2 as dxecode_3
,icd_dgns_e_cd3 as dxecode_4
,icd_dgns_e_cd4 as dxecode_5
,icd_dgns_e_cd5 as dxecode_6
,icd_dgns_e_cd6 as dxecode_7
,icd_dgns_e_cd7 as dxecode_8
,icd_dgns_e_cd8 as dxecode_9
,icd_dgns_e_cd9 as dxecode_10
,icd_dgns_e_cd10 as dxecode_11
,icd_dgns_e_cd11 as dxecode_12
,icd_dgns_e_cd12 as dxecode_13
,icd_prcdr_cd1 as pc01
,icd_prcdr_cd2 as pc02
,icd_prcdr_cd3 as pc03
,icd_prcdr_cd4 as pc04
,icd_prcdr_cd5 as pc05
,icd_prcdr_cd6 as pc06
,icd_prcdr_cd7 as pc07
,icd_prcdr_cd8 as pc08
,icd_prcdr_cd9 as pc09
,icd_prcdr_cd10 as pc10
,icd_prcdr_cd11 as pc11
,icd_prcdr_cd12 as pc12
,icd_prcdr_cd13 as pc13
,icd_prcdr_cd14 as pc14
,icd_prcdr_cd15 as pc15
,icd_prcdr_cd16 as pc16
,icd_prcdr_cd17 as pc17
,icd_prcdr_cd18 as pc18
,icd_prcdr_cd19 as pc19
,icd_prcdr_cd20 as pc20
,icd_prcdr_cd21 as pc21
,icd_prcdr_cd22 as pc22
,icd_prcdr_cd23 as pc23
,icd_prcdr_cd24 as pc24
,icd_prcdr_cd25 as pc25
,getdate() as last_run
from PHClaims.load_raw.mcare_snf_base_claims_k_14

--2015 data
union
select
bene_id as id_mcare
,clm_id as claim_header_id
,clm_from_dt as first_service_date
,clm_thru_dt as last_service_date
,clm_mdcr_non_pmt_rsn_cd as denial_code_facility
,nch_clm_type_cd as claim_type
,clm_fac_type_cd as facility_type_code
,clm_srvc_clsfctn_type_cd as service_type_code
,clm_admsn_dt as admission_date
,nch_bene_dschrg_dt as discharge_date
,clm_ip_admsn_type_cd as ipt_admission_type
,clm_src_ip_admsn_cd as ipt_admission_source
,clm_drg_cd as drg_code
,nch_ptnt_status_ind_cd as patient_status
,ptnt_dschrg_stus_cd as patient_status_code
,at_physn_npi as provider_attending_npi
,at_physn_spclty_cd as provider_attending_specialty
,op_physn_npi as provider_operating_npi
,op_physn_spclty_cd as provider_operating_specialty
,org_npi_num as provider_org_npi
,ot_physn_npi as provider_other_npi
,ot_physn_spclty_cd as provider_other_specialty
,rndrng_physn_npi as provider_rendering_npi
,rndrng_physn_spclty_cd as provider_rendering_specialty
,admtg_dgns_cd as dxadmit
,prncpal_dgns_cd as dx01
,icd_dgns_cd1 as dx02
,icd_dgns_cd2 as dx03
,icd_dgns_cd3 as dx04
,icd_dgns_cd4 as dx05
,icd_dgns_cd5 as dx06
,icd_dgns_cd6 as dx07
,icd_dgns_cd7 as dx08
,icd_dgns_cd8 as dx09
,icd_dgns_cd9 as dx10
,icd_dgns_cd10 as dx11
,icd_dgns_cd11 as dx12
,icd_dgns_cd12 as dx13
,icd_dgns_cd13 as dx14
,icd_dgns_cd14 as dx15
,icd_dgns_cd15 as dx16
,icd_dgns_cd16 as dx17
,icd_dgns_cd17 as dx18
,icd_dgns_cd18 as dx19
,icd_dgns_cd19 as dx20
,icd_dgns_cd20 as dx21
,icd_dgns_cd21 as dx22
,icd_dgns_cd22 as dx23
,icd_dgns_cd23 as dx24
,icd_dgns_cd24 as dx25
,icd_dgns_cd25 as dx26
,fst_dgns_e_cd as dxecode_1
,icd_dgns_e_cd1 as dxecode_2
,icd_dgns_e_cd2 as dxecode_3
,icd_dgns_e_cd3 as dxecode_4
,icd_dgns_e_cd4 as dxecode_5
,icd_dgns_e_cd5 as dxecode_6
,icd_dgns_e_cd6 as dxecode_7
,icd_dgns_e_cd7 as dxecode_8
,icd_dgns_e_cd8 as dxecode_9
,icd_dgns_e_cd9 as dxecode_10
,icd_dgns_e_cd10 as dxecode_11
,icd_dgns_e_cd11 as dxecode_12
,icd_dgns_e_cd12 as dxecode_13
,icd_prcdr_cd1 as pc01
,icd_prcdr_cd2 as pc02
,icd_prcdr_cd3 as pc03
,icd_prcdr_cd4 as pc04
,icd_prcdr_cd5 as pc05
,icd_prcdr_cd6 as pc06
,icd_prcdr_cd7 as pc07
,icd_prcdr_cd8 as pc08
,icd_prcdr_cd9 as pc09
,icd_prcdr_cd10 as pc10
,icd_prcdr_cd11 as pc11
,icd_prcdr_cd12 as pc12
,icd_prcdr_cd13 as pc13
,icd_prcdr_cd14 as pc14
,icd_prcdr_cd15 as pc15
,icd_prcdr_cd16 as pc16
,icd_prcdr_cd17 as pc17
,icd_prcdr_cd18 as pc18
,icd_prcdr_cd19 as pc19
,icd_prcdr_cd20 as pc20
,icd_prcdr_cd21 as pc21
,icd_prcdr_cd22 as pc22
,icd_prcdr_cd23 as pc23
,icd_prcdr_cd24 as pc24
,icd_prcdr_cd25 as pc25
,getdate() as last_run
from PHClaims.load_raw.mcare_snf_base_claims_k_15

--2016 data
union
select
bene_id as id_mcare
,clm_id as claim_header_id
,clm_from_dt as first_service_date
,clm_thru_dt as last_service_date
,clm_mdcr_non_pmt_rsn_cd as denial_code_facility
,nch_clm_type_cd as claim_type
,clm_fac_type_cd as facility_type_code
,clm_srvc_clsfctn_type_cd as service_type_code
,clm_admsn_dt as admission_date
,nch_bene_dschrg_dt as discharge_date
,clm_ip_admsn_type_cd as ipt_admission_type
,clm_src_ip_admsn_cd as ipt_admission_source
,clm_drg_cd as drg_code
,nch_ptnt_status_ind_cd as patient_status
,ptnt_dschrg_stus_cd as patient_status_code
,at_physn_npi as provider_attending_npi
,at_physn_spclty_cd as provider_attending_specialty
,op_physn_npi as provider_operating_npi
,op_physn_spclty_cd as provider_operating_specialty
,org_npi_num as provider_org_npi
,ot_physn_npi as provider_other_npi
,ot_physn_spclty_cd as provider_other_specialty
,rndrng_physn_npi as provider_rendering_npi
,rndrng_physn_spclty_cd as provider_rendering_specialty
,admtg_dgns_cd as dxadmit
,prncpal_dgns_cd as dx01
,icd_dgns_cd1 as dx02
,icd_dgns_cd2 as dx03
,icd_dgns_cd3 as dx04
,icd_dgns_cd4 as dx05
,icd_dgns_cd5 as dx06
,icd_dgns_cd6 as dx07
,icd_dgns_cd7 as dx08
,icd_dgns_cd8 as dx09
,icd_dgns_cd9 as dx10
,icd_dgns_cd10 as dx11
,icd_dgns_cd11 as dx12
,icd_dgns_cd12 as dx13
,icd_dgns_cd13 as dx14
,icd_dgns_cd14 as dx15
,icd_dgns_cd15 as dx16
,icd_dgns_cd16 as dx17
,icd_dgns_cd17 as dx18
,icd_dgns_cd18 as dx19
,icd_dgns_cd19 as dx20
,icd_dgns_cd20 as dx21
,icd_dgns_cd21 as dx22
,icd_dgns_cd22 as dx23
,icd_dgns_cd23 as dx24
,icd_dgns_cd24 as dx25
,icd_dgns_cd25 as dx26
,fst_dgns_e_cd as dxecode_1
,icd_dgns_e_cd1 as dxecode_2
,icd_dgns_e_cd2 as dxecode_3
,icd_dgns_e_cd3 as dxecode_4
,icd_dgns_e_cd4 as dxecode_5
,icd_dgns_e_cd5 as dxecode_6
,icd_dgns_e_cd6 as dxecode_7
,icd_dgns_e_cd7 as dxecode_8
,icd_dgns_e_cd8 as dxecode_9
,icd_dgns_e_cd9 as dxecode_10
,icd_dgns_e_cd10 as dxecode_11
,icd_dgns_e_cd11 as dxecode_12
,icd_dgns_e_cd12 as dxecode_13
,icd_prcdr_cd1 as pc01
,icd_prcdr_cd2 as pc02
,icd_prcdr_cd3 as pc03
,icd_prcdr_cd4 as pc04
,icd_prcdr_cd5 as pc05
,icd_prcdr_cd6 as pc06
,icd_prcdr_cd7 as pc07
,icd_prcdr_cd8 as pc08
,icd_prcdr_cd9 as pc09
,icd_prcdr_cd10 as pc10
,icd_prcdr_cd11 as pc11
,icd_prcdr_cd12 as pc12
,icd_prcdr_cd13 as pc13
,icd_prcdr_cd14 as pc14
,icd_prcdr_cd15 as pc15
,icd_prcdr_cd16 as pc16
,icd_prcdr_cd17 as pc17
,icd_prcdr_cd18 as pc18
,icd_prcdr_cd19 as pc19
,icd_prcdr_cd20 as pc20
,icd_prcdr_cd21 as pc21
,icd_prcdr_cd22 as pc22
,icd_prcdr_cd23 as pc23
,icd_prcdr_cd24 as pc24
,icd_prcdr_cd25 as pc25
,getdate() as last_run
from PHClaims.load_raw.mcare_snf_base_claims_k_16;
