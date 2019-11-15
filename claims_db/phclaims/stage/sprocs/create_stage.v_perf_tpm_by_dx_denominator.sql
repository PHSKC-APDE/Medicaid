
/*
This view gets claims that meet the requirements for the DSHS RDA Mental Health
Treatment Penetration rate denominator AND divides them into diagnosis groups.

Author: Philip Sylling
Created: 2019-04-23
Modified: 2019-08-07 | Point to new [final] analytic tables
Modified: 2019-11-05 | Modify view to retain diagnosis group

Returns:
 [id_mcaid]
,[claim_header_id]
,[first_service_date], [FROM_SRVC_DATE]
,[sub_group] (ADHD, Adjustment, Anxiety, Depression, Disrup/Impulse/Conduct, Mania/Bipolar, Psychotic)
,[flag], 1 for claim meeting denominator criteria
*/

USE [PHClaims];
GO

IF OBJECT_ID('[stage].[v_perf_tpm_by_dx_denominator]', 'V') IS NOT NULL
DROP VIEW [stage].[v_perf_tpm_by_dx_denominator];
GO
CREATE VIEW [stage].[v_perf_tpm_by_dx_denominator]
AS

/*
SELECT [value_set_group]
      ,[value_set_name]
      ,[data_source_type]
      ,[code_set]
	  ,[active]
      ,COUNT([code])
FROM [ref].[rda_value_set]
WHERE [value_set_group] = 'MH'
GROUP BY [value_set_group], [value_set_name], [data_source_type], [code_set], [active]
ORDER BY [value_set_group], [value_set_name], [data_source_type], [code_set], [active];

SELECT 
 [value_set_group]
,[value_set_name]
,[data_source_type]
,[sub_group]
,[code_set]
,[active]
,[num_code]
FROM [metadata].[v_rda_value_set_summary]
ORDER BY
 [value_set_group]
,[value_set_name]
,[data_source_type]
,[sub_group]
,[code_set]
,[active];

SELECT 
 YEAR([first_service_date]) AS [year]
,MONTH([first_service_date]) AS [month]
,[icdcm_version]
,COUNT(*)
FROM [final].[mcaid_claim_icdcm_header] AS dx
GROUP BY YEAR([first_service_date]), MONTH([first_service_date]), [icdcm_version]
ORDER BY [icdcm_version], YEAR([first_service_date]), MONTH([first_service_date]);
*/

/*
Denominator: Data elements required for denominator: Medicaid beneficiaries, 
aged 6 and older on the last day of the measurement year, with a mental health 
service need identified in either the measurement year or the year prior to the
measurement year.
*/

/*
Receipt of any mental health service meeting the numerator service criteria in 
the 24‐month identification window.

Because [stage].[v_perf_tpm_by_dx_numerator] requires all procedures to 
accompany a PRIMARY diagnosis in MH-Dx-value-set, all the claim_header_id's in 
[stage].[v_perf_tpm_by_dx_numerator] WILL ALREADY BE INCLUDED IN 
[stage].[v_perf_tpm_by_dx_denominator] which includes ALL diagnoses in the 
MH-Dx-value-set. So the query below is not required.
*/
/*
SELECT
--TOP(100)
 [id_mcaid]
,[claim_header_id]
,[first_service_date]
,[sub_group]
,[flag]

FROM [stage].[v_perf_tpm_by_dx_numerator]

UNION
*/
/*
Any diagnosis of mental illness (not restricted to primary) in any of the 
categories listed in MH‐Dx‐value‐set in the 24-month identification window.
*/

SELECT 
 dx.[id_mcaid]
,dx.[claim_header_id]
,dx.[first_service_date]
,rda.[sub_group]
,1 AS [flag]

-- Any diagnosis (not restricted to primary)
FROM [final].[mcaid_claim_icdcm_header] AS dx
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_name] = 'MH-Dx-value-set'
AND rda.[code_set] = 'ICD9CM'
AND dx.[icdcm_version] = 9 
AND dx.[icdcm_norm] = rda.[code]
WHERE dx.[first_service_date] < '2015-10-01'

UNION

SELECT 
 dx.[id_mcaid]
,dx.[claim_header_id]
,dx.[first_service_date]
,rda.[sub_group]
,1 AS [flag]

--SELECT COUNT(*) -- 00:00:23
-- Any diagnosis (not restricted to primary)
FROM [final].[mcaid_claim_icdcm_header] AS dx
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_name] = 'MH-Dx-value-set'
AND rda.[code_set] = 'ICD10CM'
AND dx.[icdcm_version] = 10 
AND dx.[icdcm_norm] = rda.[code]
WHERE dx.[first_service_date] >= '2015-10-01'

UNION

/*
Receipt of any psychotropic medication listed in MH‐Rx‐value‐set in the 
24‐month identification window.
*/

SELECT 
 ph.[id_mcaid]
,ph.[claim_header_id]
,ph.[rx_fill_date] AS [first_service_date]
,CASE 
 WHEN rda.[sub_group] = 'ADHD Rx' THEN 'ADHD'
 WHEN rda.[sub_group] = 'Antianxiety Rx' THEN 'Anxiety'
 WHEN rda.[sub_group] = 'Antidepressants Rx' THEN 'Depression'
 WHEN rda.[sub_group] = 'Antimania Rx' THEN 'Mania/Bipolar'
 WHEN rda.[sub_group] = 'Antipsychotic Rx' THEN 'Psychotic'
 END AS [sub_group]
,1 AS [flag]

FROM [final].[mcaid_claim_pharm] AS ph
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_name] = 'MH-Rx-value-set'
AND rda.[code_set] = 'NDC'
AND ph.[ndc] = rda.[code];
GO

/*
-- 16,155,883
SELECT COUNT(*) FROM [stage].[v_perf_tpm_by_dx_denominator]; -- 00:03:01

SELECT TOP(100) * FROM [stage].[v_perf_tpm_by_dx_denominator];
*/