
/*
This view gets claims that meet the requirements for the DSHS RDA Substance Use
Disorder Treatment Penetration (Opioid) rate denominator.

Author: Philip Sylling
Created: 2019-05-22
Modified: 2019-08-09 | Point to new [final] analytic tables
Modified: 2019-11-15 | Add [value_set_group], [value_set_name], [data_source_type], [code_set] columns to view

Returns:
 [value_set_group]
,[value_set_name]
,[data_source_type]
,[sub_group]
,[code_set]
,[id_mcaid]
,[claim_header_id]
,[first_service_date], [FROM_SRVC_DATE]
,[flag], 1 for claim meeting denominator criteria
*/

USE [PHClaims];
GO

IF OBJECT_ID('[stage].[v_perf_tpo_denominator]', 'V') IS NOT NULL
DROP VIEW [stage].[v_perf_tpo_denominator];
GO
CREATE VIEW [stage].[v_perf_tpo_denominator]
AS

/*
SELECT [value_set_group]
      ,[value_set_name]
      ,[data_source_type]
	  ,[sub_group]
      ,[code_set]
	  ,[active]
      ,COUNT([code])
FROM [ref].[rda_value_set]
WHERE [value_set_group] = 'OUD'
GROUP BY [value_set_group], [value_set_name], [data_source_type], [sub_group], [code_set], [active]
ORDER BY [value_set_group], [value_set_name], [data_source_type], [sub_group], [code_set], [active];
*/

/*
1. Diagnosis of OUD in any health service event (OUD-Tx-Pen-Value-Set-1)
SELECT * 
FROM [ref].[rda_value_set] AS rda
WHERE rda.[value_set_name] = 'OUD-Tx-Pen-Value-Set-1';
*/

SELECT 
 rda.[value_set_group]
,rda.[value_set_name]
,rda.[data_source_type]
,rda.[sub_group]
,rda.[code_set]
,dx.[id_mcaid]
,dx.[claim_header_id]
,dx.[first_service_date]
,1 AS [flag]

--SELECT COUNT(*) -- 00:00:23
-- Any diagnosis (not restricted to primary)
FROM [final].[mcaid_claim_icdcm_header] AS dx
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_group] = 'OUD'
AND rda.[value_set_name] = 'OUD-Tx-Pen-Value-Set-1'
AND rda.[code_set] = 'ICD9CM'
AND dx.[icdcm_version] = 9 
AND dx.[icdcm_norm] = rda.[code]
WHERE dx.[first_service_date] < '2015-10-01'

UNION

SELECT 
 rda.[value_set_group]
,rda.[value_set_name]
,rda.[data_source_type]
,rda.[sub_group]
,rda.[code_set]
,dx.[id_mcaid]
,dx.[claim_header_id]
,dx.[first_service_date]
,1 AS [flag]

--SELECT COUNT(*) -- 00:00:23
-- Any diagnosis (not restricted to primary)
FROM [final].[mcaid_claim_icdcm_header] AS dx
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_group] = 'OUD'
AND rda.[value_set_name] = 'OUD-Tx-Pen-Value-Set-1'
AND rda.[code_set] = 'ICD10CM'
AND dx.[icdcm_version] = 10 
AND dx.[icdcm_norm] = rda.[code]
WHERE dx.[first_service_date] >= '2015-10-01'

UNION

/*
2. Receipt of a medication meeting numerator criteria: NDC codes indicating 
receipt of other forms of medication assisted treatment for 
OUD: OUD-Tx-Pen-Value-Set-2
SELECT * 
FROM [ref].[rda_value_set] AS rda
WHERE rda.[value_set_name] = 'OUD-Tx-Pen-Value-Set-2';
*/

SELECT 
 rda.[value_set_group]
,rda.[value_set_name]
,rda.[data_source_type]
,rda.[sub_group]
,rda.[code_set]
,ph.[id_mcaid]
,ph.[claim_header_id]
,ph.[rx_fill_date] AS [first_service_date]
,1 AS [flag]

FROM [final].[mcaid_claim_pharm] AS ph
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_group] = 'OUD'
AND rda.[value_set_name] = 'OUD-Tx-Pen-Value-Set-2'
AND rda.[code_set] = 'NDC'
AND rda.[active] = 'Y'
AND ph.[ndc] = rda.[code]

UNION

/*
3. Receipt of methadone opiate substitution treatment indicated by an 
outpatient encounter with procedure code H0020
SELECT * 
FROM [ref].[rda_value_set] AS rda
WHERE rda.[value_set_name] = 'OUD-Tx-Pen-Receipt-of-MAT';
*/

SELECT 
 rda.[value_set_group]
,rda.[value_set_name]
,rda.[data_source_type]
,rda.[sub_group]
,rda.[code_set]
,pr.[id_mcaid]
,pr.[claim_header_id]
,pr.[first_service_date]
,1 AS [flag]

FROM [final].[mcaid_claim_procedure] AS pr
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_group] = 'OUD'
AND rda.[value_set_name] = 'OUD-Tx-Pen-Receipt-of-MAT'
AND rda.[code_set] IN ('HCPCS')
AND pr.[procedure_code] = rda.[code];
GO

/*
-- 6,173,072
SELECT COUNT(*) FROM [stage].[v_perf_tpo_denominator];

SELECT TOP(100) * FROM [stage].[v_perf_tpo_denominator];
*/