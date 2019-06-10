
/*
This code creates table ([stage].[mcaid_claim_icdcm_header]) to hold DISTINCT 
diagnoses in long format for Medicaid claims data

Created by: Eli Kern, APDE, PHSKC, 2018-03-21
Modified by: Philip Sylling, 2019-06-05

Run time: 00:28:51

Returns
[stage].[mcaid_claim_icdcm_header]
 [id_mcaid]
,[claim_header_id]
,[icdcm_raw]
,[icdcm_norm]
,[icdcm_version]
,[icdcm_number]
*/

use PHClaims;
go

if object_id('stage.mcaid_claim_icdcm_header', 'U') IS NOT NULL
drop table stage.mcaid_claim_icdcm_header;
--if object_id('tempdb..#mcaid_claim_icdcm_header', 'U') IS NOT NULL
--drop table #mcaid_claim_icdcm_header;

select distinct
 cast(id_mcaid as varchar(200)) as id_mcaid
,cast(claim_header_id as bigint ) as claim_header_id
--original diagnosis codes without zero right-padding
,cast(diagnoses as varchar(200)) as icdcm_raw

,	
	cast(
		case
		    -- right-zero-pad ICD-9 diagnoses
			when (diagnoses like '[0-9]%' and len(diagnoses) = 3) then diagnoses + '00'
			when (diagnoses like '[0-9]%' and len(diagnoses) = 4) then diagnoses + '0'
			-- Both ICD-9 and ICD-10 codes have 'V' and 'E' prefixes
			-- Diagnoses prior to 2015-10-01 are ICD-9
			when (diagnoses like 'V%' and TO_SRVC_DATE < '2015-10-01' and len(diagnoses) = 3) then diagnoses + '00'
			when (diagnoses like 'V%' and TO_SRVC_DATE < '2015-10-01' and len(diagnoses) = 4) then diagnoses + '0'
			when (diagnoses like 'E%' and TO_SRVC_DATE < '2015-10-01' and len(diagnoses) = 3) then diagnoses + '00'
			when (diagnoses like 'E%' and TO_SRVC_DATE < '2015-10-01' and len(diagnoses) = 4) then diagnoses + '0'
			else diagnoses 
		end 
	as varchar(200)) as icdcm_norm

,
	cast(
		case
			when (diagnoses like '[0-9]%') then 9
			when (diagnoses like 'V%' and TO_SRVC_DATE < '2015-10-01') then 9
			when (diagnoses like 'E%' and TO_SRVC_DATE < '2015-10-01') then 9
			else 10 
		end 
	as tinyint) as icdcm_version

--,cast(substring(dx_number, 3,2) as tinyint) as icdcm_number
,cast(dx_number as varchar(5)) as icdcm_number

into stage.mcaid_claim_icdcm_header
--into #mcaid_claim_icdcm_header

from 
(
select 
 MEDICAID_RECIPIENT_ID AS id_mcaid
,TCN as claim_header_id
--,CLM_LINE_TCN
,TO_SRVC_DATE
,PRIMARY_DIAGNOSIS_CODE AS [01]
,DIAGNOSIS_CODE_2 AS [02]
,DIAGNOSIS_CODE_3 AS [03]
,DIAGNOSIS_CODE_4 AS [04]
,DIAGNOSIS_CODE_5 AS [05]
,DIAGNOSIS_CODE_6 AS [06]
,DIAGNOSIS_CODE_7 AS [07]
,DIAGNOSIS_CODE_8 AS [08]
,DIAGNOSIS_CODE_9 AS [09]
,DIAGNOSIS_CODE_10 AS [10]
,DIAGNOSIS_CODE_11 AS [11]
,DIAGNOSIS_CODE_12 AS [12]
,ADMTNG_DIAGNOSIS_CODE AS [admit]

from stage.mcaid_claim
) AS a

unpivot(diagnoses for dx_number IN ([01], [02], [03], [04], [05], [06], [07], [08], [09], [10], [11], [12], [admit])) as diagnoses;


--create indexes
CREATE CLUSTERED INDEX [idx_cl_stage_mcaid_claim_icdcm_header_claim_header_id_icdcm_number]
ON [stage].[mcaid_claim_icdcm_header]([claim_header_id], [icdcm_number]);
GO

CREATE NONCLUSTERED INDEX [idx_nc_stage_mcaid_claim_icdcm_header_icdcm_version_icdcm_norm] 
ON [stage].[mcaid_claim_icdcm_header]([icdcm_version], [icdcm_norm]);
GO


/*
--create indexes
CREATE CLUSTERED INDEX [idx_cl_#mcaid_claim_icdcm_header_claim_header_id_icdcm_number]
ON #mcaid_claim_icdcm_header([claim_header_id], [icdcm_number]);
GO

CREATE NONCLUSTERED INDEX [idx_nc_#mcaid_claim_icdcm_header_icdcm_version_icdcm_norm] 
ON #mcaid_claim_icdcm_header([icdcm_version], [icdcm_norm]);
GO
*/