
/*
This code creates table ([stage].[mcaid_claim_ndc]) to hold DISTINCT 
pharmacy information

Created by: Eli Kern, APDE, PHSKC, 2018-03-21
Modified by: Philip Sylling, 2019-06-06

Data Pull Run time: 00:04:08
Create Index Run Time: 00:02:49

Returns
[stage].[mcaid_claim_pharm]
 [id_mcaid]
,[claim_header_id]
,[ndc]
,[rx_days_supply]
,[rx_quantity]
,[rx_fill_date]
,[pharmacy_npi]

-- Some descriptives
SELECT DISTINCT LEN([NDC]) FROM [PHClaims].[stage].[mcaid_claim]; -- 11, Always left-zero-padded
SELECT DISTINCT [DRUG_STRENGTH] FROM [PHClaims].[stage].[mcaid_claim]; -- Free-text field
SELECT DISTINCT [DAYS_SUPPLY] FROM [PHClaims].[stage].[mcaid_claim] ORDER BY [DAYS_SUPPLY]; -- values 0 to 999
SELECT DISTINCT [DRUG_DOSAGE] FROM [PHClaims].[stage].[mcaid_claim] ORDER BY [DRUG_DOSAGE]; -- 3 or 4-character text codes
SELECT DISTINCT LEN([DRUG_DOSAGE]) FROM [PHClaims].[stage].[mcaid_claim] ORDER BY LEN([DRUG_DOSAGE]); -- values: NULL, 3, 4
SELECT DISTINCT [PACKAGE_SIZE_UOM] FROM [PHClaims].[stage].[mcaid_claim]; -- values: NULL, EA, GM, ML
SELECT DISTINCT [SBMTD_DISPENSED_QUANTITY] FROM [PHClaims].[stage].[mcaid_claim] ORDER BY [SBMTD_DISPENSED_QUANTITY]; -- values: NULL, 0.000 to 671187.000

SELECT DISTINCT LEN([PRSCRBR_ID]) FROM [PHClaims].[stage].[mcaid_claim] ORDER BY LEN([PRSCRBR_ID]); -- values: NULL, 6, 8, 9, 10, 15
See types of prescriber id
https://www.resdac.org/cms-data/variables/pde-prescriber-id-format-code
SELECT
 CASE WHEN (LEN([PRSCRBR_ID]) = 10 AND ISNUMERIC([PRSCRBR_ID]) = 1 AND LEFT([PRSCRBR_ID], 1) IN (1,2)) THEN 'NPI'
      WHEN (LEN([PRSCRBR_ID]) = 9 AND ISNUMERIC(SUBSTRING([PRSCRBR_ID], 1, 2)) = 0 AND ISNUMERIC(SUBSTRING([PRSCRBR_ID], 3, 7)) = 1) THEN 'DEA'
      WHEN (LEN([PRSCRBR_ID]) = 6 AND ISNUMERIC(SUBSTRING([PRSCRBR_ID], 1, 1)) = 0 AND ISNUMERIC(SUBSTRING([PRSCRBR_ID], 2, 5)) = 1) THEN 'UPIN'
	  WHEN [PRSCRBR_ID] = '5123456787' THEN 'WA HCA'
	  ELSE 'UNKNOWN'
 END AS [PRSCRBR_ID_FORMAT]
,COUNT(*)
FROM [PHClaims].[stage].[mcaid_claim]
WHERE [PRSCRBR_ID] IS NOT NULL
GROUP BY
 CASE WHEN (LEN([PRSCRBR_ID]) = 10 AND ISNUMERIC([PRSCRBR_ID]) = 1 AND LEFT([PRSCRBR_ID], 1) IN (1,2)) THEN 'NPI'
      WHEN (LEN([PRSCRBR_ID]) = 9 AND ISNUMERIC(SUBSTRING([PRSCRBR_ID], 1, 2)) = 0 AND ISNUMERIC(SUBSTRING([PRSCRBR_ID], 3, 7)) = 1) THEN 'DEA'
      WHEN (LEN([PRSCRBR_ID]) = 6 AND ISNUMERIC(SUBSTRING([PRSCRBR_ID], 1, 1)) = 0 AND ISNUMERIC(SUBSTRING([PRSCRBR_ID], 2, 5)) = 1) THEN 'UPIN'
	  WHEN [PRSCRBR_ID] = '5123456787' THEN 'WA HCA'
	  ELSE 'UNKNOWN'
 END;

-- 550 distinct [organization_name_legal]
SELECT
 [organization_name_legal]
,COUNT(*)
FROM [stage].[mcaid_claim] AS a
INNER JOIN [tmp].[ref_provider_master] AS b
ON TRY_CAST(a.[PRSCRBR_ID] AS BIGINT) = b.[npi] 
GROUP BY [organization_name_legal];


SELECT 
 DATEDIFF(DAY, [FROM_SRVC_DATE], [PRSCRPTN_FILLED_DATE])
,DATEDIFF(DAY, [TO_SRVC_DATE], [PRSCRPTN_FILLED_DATE])
,COUNT(*)
FROM [PHClaims].[stage].[mcaid_claim]
WHERE [PRSCRPTN_FILLED_DATE] IS NOT NULL
GROUP BY
 DATEDIFF(DAY, [FROM_SRVC_DATE], [PRSCRPTN_FILLED_DATE])
,DATEDIFF(DAY, [TO_SRVC_DATE], [PRSCRPTN_FILLED_DATE]);


SELECT COUNT(*)
FROM [PHClaims].[stage].[mcaid_claim]
WHERE [PRSCRPTN_FILLED_DATE] IS NOT NULL
AND [FROM_SRVC_DATE] = [PRSCRPTN_FILLED_DATE] AND [TO_SRVC_DATE] = [PRSCRPTN_FILLED_DATE];

SELECT COUNT(*)
FROM [PHClaims].[stage].[mcaid_claim]
WHERE [PRSCRPTN_FILLED_DATE] IS NOT NULL;
*/

use PHClaims;
go

if object_id('[stage].[mcaid_claim_ndc]', 'U') IS NOT NULL 
drop table [stage].[mcaid_claim_ndc];
--if object_id('tempdb..#mcaid_claim_ndc', 'U') IS NOT NULL 
--drop table #mcaid_claim_ndc;

select distinct 
 cast(MEDICAID_RECIPIENT_ID as varchar(200)) as id_mcaid
,cast(TCN as bigint) as claim_header_id
,cast(NDC as varchar(200)) as ndc_code
,cast(DRUG_STRENGTH as varchar(200)) as drug_strength
,cast(DAYS_SUPPLY as smallint) as drug_supply_d
,cast(DRUG_DOSAGE as varchar(200)) as drug_dosage
,cast(SBMTD_DISPENSED_QUANTITY as numeric(19,3)) as drug_dispensed_amt
,cast(PRSCRPTN_FILLED_DATE as date) as drug_fill_date
,cast(PRSCRBR_ID as varchar(200)) as prescriber_id

into [stage].[mcaid_claim_ndc]
--into #mcaid_claim_ndc

from [stage].[mcaid_claim]
where ndc is not null;

--create indexes
CREATE CLUSTERED INDEX [idx_cl_stage_mcaid_claim_ndc_claim_header_id] ON [stage].[mcaid_claim_ndc]([claim_header_id]);
GO
CREATE NONCLUSTERED INDEX [idx_nc_stage_mcaid_claim_ndc_ndc_code] ON [stage].[mcaid_claim_ndc]([ndc_code]);
GO

--CREATE CLUSTERED INDEX [idx_cl_#mcaid_claim_ndc_claim_header_id] ON #mcaid_claim_ndc([claim_header_id]);
--CREATE NONCLUSTERED INDEX [idx_nc_#mcaid_claim_ndc_ndc_code] ON #mcaid_claim_ndc([ndc_code]);
--GO