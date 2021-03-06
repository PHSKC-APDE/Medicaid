
/*
This view gets claims that meet the requirements for the DSHS RDA Substance Use
Disorder Treatment Penetration rate denominator.

Author: Philip Sylling
Created: 2019-04-23
Modified: 2019-08-08 | Point to new [final] analytic tables

Returns:
 [id_mcaid]
,[claim_header_id]
,[first_service_date], [FROM_SRVC_DATE]
,[flag], 1 for claim meeting denominator criteria
*/

USE [PHClaims];
GO

IF OBJECT_ID('[stage].[v_perf_tps_denominator]', 'V') IS NOT NULL
DROP VIEW [stage].[v_perf_tps_denominator];
GO
CREATE VIEW [stage].[v_perf_tps_denominator]
AS

/*
SELECT [value_set_group]
      ,[value_set_name]
      ,[data_source_type]
      ,[code_set]
	  ,[active]
      ,COUNT([code])
FROM [ref].[rda_value_set]
WHERE [value_set_group] = 'SUD'
GROUP BY [value_set_group], [value_set_name], [data_source_type], [code_set], [active]
ORDER BY [value_set_group], [value_set_name], [data_source_type], [code_set], [active];
*/

/*
1. Diagnosis of a drug or alcohol use disorder in any health service event (SUD-Tx-Pen-Value-Set-1)
SELECT * 
FROM [ref].[rda_value_set] AS rda
WHERE rda.[value_set_name] = 'SUD-Tx-Pen-Value-Set-1';
*/

SELECT 
 dx.[id_mcaid]
,dx.[claim_header_id]
,dx.[first_service_date]
--,ym.[year_month]
,1 AS [flag]

--SELECT COUNT(*) -- 00:00:23
-- Any diagnosis (not restricted to primary)
FROM [final].[mcaid_claim_icdcm_header] AS dx
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_name] = 'SUD-Tx-Pen-Value-Set-1'
AND rda.[code_set] = 'ICD9CM'
AND dx.[icdcm_version] = 9 
AND dx.[icdcm_norm] = rda.[code]
WHERE dx.[first_service_date] < '2015-10-01'

UNION

SELECT 
 dx.[id_mcaid]
,dx.[claim_header_id]
,dx.[first_service_date]
--,ym.[year_month]
,1 AS [flag]

--SELECT COUNT(*) -- 00:00:23
-- Any diagnosis (not restricted to primary)
FROM [final].[mcaid_claim_icdcm_header] AS dx
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_name] = 'SUD-Tx-Pen-Value-Set-1'
AND rda.[code_set] = 'ICD10CM'
AND dx.[icdcm_version] = 10 
AND dx.[icdcm_norm] = rda.[code]
WHERE dx.[first_service_date] >= '2015-10-01'

UNION

/*
2. Receipt of brief intervention (SBIRT) services (SUD-Tx-Pen-Value-Set-4)
SELECT * 
FROM [ref].[rda_value_set] AS rda
WHERE rda.[value_set_name] = 'SUD-Tx-Pen-Value-Set-4';
*/

SELECT 
 pr.[id_mcaid]
,pr.[claim_header_id]
,pr.[first_service_date]
--,ym.[year_month]
,1 AS [flag]

FROM [final].[mcaid_claim_procedure] AS pr
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_name] = 'SUD-Tx-Pen-Value-Set-4'
AND rda.[code_set] IN ('CPT', 'HCPCS')
AND pr.[procedure_code] = rda.[code]

UNION

/*
3. Receipt of medically managed detox services (SUD-Tx-Pen-Value-Set-5)
SELECT *
FROM [ref].[rda_value_set] AS rda
WHERE rda.[value_set_name] = 'SUD-Tx-Pen-Value-Set-5';
*/

SELECT 
 pr.[id_mcaid]
,pr.[claim_header_id]
,pr.[first_service_date]
--,ym.[year_month]
,1 AS [flag]

FROM [final].[mcaid_claim_procedure] AS pr
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_name] = 'SUD-Tx-Pen-Value-Set-5'
AND rda.[code_set] IN ('HCPCS', 'ICD10PCS', 'ICD9PCS')
AND pr.[procedure_code] = rda.[code]

UNION

SELECT 
 ln.[id_mcaid]
,ln.[claim_header_id]
,ln.[first_service_date]
--,ym.[year_month]
,1 AS [flag]

FROM [final].[mcaid_claim_line] AS ln
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_name] = 'SUD-Tx-Pen-Value-Set-5'
AND rda.[code_set] IN ('UBREV')
AND ln.[rev_code] = rda.[code]

UNION

/*
4a. Procedure and DRG codes indicating receipt of inpatient/residential, 
outpatient, or methadone OST: SUD-Tx-Pen-Value-Set-2
SELECT *
FROM [ref].[rda_value_set] AS rda
WHERE rda.[value_set_name] = 'SUD-Tx-Pen-Value-Set-2';
*/

SELECT 
 pr.[id_mcaid]
,pr.[claim_header_id]
,pr.[first_service_date]
--,ym.[year_month]
,1 AS [flag]

FROM [final].[mcaid_claim_procedure] AS pr
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_name] = 'SUD-Tx-Pen-Value-Set-2'
AND rda.[code_set] IN ('HCPCS', 'ICD9PCS')
AND pr.[procedure_code] = rda.[code]

UNION

SELECT 
 hd.[id_mcaid]
,hd.[claim_header_id]
,hd.[first_service_date]
--,ym.[year_month]
,1 AS [flag]

FROM [final].[mcaid_claim_header] AS hd
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_name] = 'SUD-Tx-Pen-Value-Set-2'
AND rda.[code_set] IN ('DRG')
AND hd.[drvd_drg_code] = rda.[code]

UNION

/*
4b. NDC codes indicating receipt of other forms of medication assisted 
treatment for SUD: SUD-Tx-Pen-Value-Set-3
SELECT *
FROM [ref].[rda_value_set] AS rda
WHERE rda.[value_set_name] = 'SUD-Tx-Pen-Value-Set-3';
*/

SELECT 
 ph.[id_mcaid]
,ph.[claim_header_id]
,ph.[rx_fill_date] AS [first_service_date]
--,ym.[year_month]
,1 AS [flag]

FROM [final].[mcaid_claim_pharm] AS ph
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_name] = 'SUD-Tx-Pen-Value-Set-3'
AND rda.[code_set] = 'NDC'
AND rda.[active] = 'Y'
AND ph.[ndc] = rda.[code]

UNION

/*
4c. Outpatient encounters meeting procedure code and primary diagnosis 
criteria: SUD-Tx-Pen-Value-Set-6.xls: procedure code in SUD-Tx-Pen-Value-Set-6 
AND primary diagnosis code in SUD-Tx-Pen-Value-Set-1
SELECT *
FROM [ref].[rda_value_set] AS rda
WHERE rda.[value_set_name] = 'SUD-Tx-Pen-Value-Set-1';
SELECT *
FROM [ref].[rda_value_set] AS rda
WHERE rda.[value_set_name] = 'SUD-Tx-Pen-Value-Set-6';
*/

(
SELECT 
 pr.[id_mcaid]
,pr.[claim_header_id]
,pr.[first_service_date]
--,ym.[year_month]
,1 AS [flag]

FROM [final].[mcaid_claim_procedure] AS pr
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_name] = 'SUD-Tx-Pen-Value-Set-6'
AND rda.[code_set] IN ('CPT', 'HCPCS')
AND pr.[procedure_code] = rda.[code]

INTERSECT

(
SELECT 
 dx.[id_mcaid]
,dx.[claim_header_id]
,dx.[first_service_date]
--,ym.[year_month]
,1 AS [flag]

FROM [final].[mcaid_claim_icdcm_header] AS dx
INNER JOIN [ref].[rda_value_set] AS rda
ON [value_set_name] = 'SUD-Tx-Pen-Value-Set-1'
AND rda.[code_set] = 'ICD9CM'
AND dx.[icdcm_version] = 9
-- Primary Diagnosis
AND dx.[icdcm_number] = '01'
AND dx.[icdcm_norm] = rda.[code]
WHERE dx.[first_service_date] < '2015-10-01'

UNION

SELECT 
 dx.[id_mcaid]
,dx.[claim_header_id]
,dx.[first_service_date]
--,ym.[year_month]
,1 AS [flag]

FROM [final].[mcaid_claim_icdcm_header] AS dx
INNER JOIN [ref].[rda_value_set] AS rda
ON [value_set_name] = 'SUD-Tx-Pen-Value-Set-1'
AND rda.[code_set] = 'ICD10CM'
AND dx.[icdcm_version] = 10
-- Primary Diagnosis
AND dx.[icdcm_number] = '01'
AND dx.[icdcm_norm] = rda.[code]
WHERE dx.[first_service_date] >= '2015-10-01'
));
GO

/*
4d. Outpatient encounters meeting taxonomy and primary diagnosis criteria: 
billing or servicing provider taxonomy code in SUD-Tx-Pen-Value-Set-7 AND 
primary diagnosis code in SUD-Tx-Pen-Value-Set-1

TAXONOMY CODE NOT AVAILABLE IN MEDICAID DATA
*/

/*
-- 7,183,430
SELECT COUNT(*) FROM [stage].[v_perf_tps_denominator];
*/