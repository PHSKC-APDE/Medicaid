/*
This view gets claims that meet the requirements for the DSHS RDA Mental Health
Treatment Penetration rate denominator

Author: Philip Sylling
Last Modified: 2019-04-23

Returns:
 [id]
,[tcn]
,[from_date], [FROM_SRVC_DATE]
,[flag], 1 for claim meeting denominator criteria
*/

USE PHClaims;
GO

IF OBJECT_ID('[stage].[v_perf_tpm_denominator]', 'V') IS NOT NULL
DROP VIEW [stage].[v_perf_tpm_denominator];
GO
CREATE VIEW [stage].[v_perf_tpm_denominator]
AS

/*
SELECT [value_set_group]
      ,[value_set_name]
      ,[data_source_type]
      ,[code_set]
      ,COUNT([code])
FROM [ref].[rda_value_set]
WHERE [value_set_group] = 'MH'
GROUP BY [value_set_group], [value_set_name], [data_source_type], [code_set]
ORDER BY [value_set_group], [value_set_name], [data_source_type], [code_set];

SELECT 
 YEAR([from_date]) AS [year]
,MONTH([from_date]) AS [month]
,[dx_ver]
,COUNT(*)
FROM [PHClaims].[dbo].[mcaid_claim_header] AS hd
INNER JOIN [PHClaims].[dbo].[mcaid_claim_dx] AS dx
ON hd.[tcn] = dx.[tcn]
GROUP BY YEAR([from_date]), MONTH([from_date]), [dx_ver]
ORDER BY [dx_ver], YEAR([from_date]), MONTH([from_date]);
*/

/*
Denominator: Data elements required for denominator: Medicaid beneficiaries, 
aged 6 and older on the last day of the measurement year, with a mental health 
service need identified in either the measurement year or the year prior to the
measurement year.
*/

/*
Receipt of any mental health service meeting the numerator service criteria in 
the 24‐ month identification window.

CLAIMS IN THE NUMERATOR WITH PROCEDURE/DX COMBINATIONS IN THE 'MH-procedure-with-Dx-value-set'
ARE ALREADY CONTAINED BELOW (ANY PRINCIPAL OR SECONDARY DX)
THUS, ONLY THE 'MH-procedure-value-set' IS INCLUDED HERE
*/

SELECT 
 hd.[id]
,hd.[tcn]
,hd.[from_date]
--,ym.[year_month]
,1 AS [flag]

FROM [dbo].[mcaid_claim_header] AS hd
INNER JOIN [dbo].[mcaid_claim_proc] AS pr
ON hd.[tcn] = pr.[tcn]
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_name] = 'MH-procedure-value-set'
AND rda.[code_set] IN ('CPT', 'HCPCS')
AND pr.[pcode] = rda.[code]
--INNER JOIN [ref].[perf_year_month] AS ym
--ON hd.[from_date] BETWEEN ym.[beg_month] AND ym.[end_month]
--WHERE hd.[from_date] BETWEEN @measurement_start_date AND @measurement_end_date
--WHERE hd.[from_date] BETWEEN CAST(DATEADD(YEAR, -1, @measurement_start_date) AS DATE) AND @measurement_end_date

UNION

/*
Any diagnosis of mental illness (not restricted to primary) in any of the 
categories listed in MH‐Dx‐value‐set in the 24-month identification window.
*/

SELECT 
 hd.[id]
,hd.[tcn]
,hd.[from_date]
--,ym.[year_month]
,1 AS [flag]

FROM [dbo].[mcaid_claim_header] AS hd
-- Any diagnosis (not restricted to primary)
INNER JOIN [PHClaims].[dbo].[mcaid_claim_dx] AS dx
ON hd.[tcn] = dx.[tcn]
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_name] = 'MH-Dx-value-set'
AND rda.[code_set] = 'ICD10CM'
AND dx.[dx_ver] = 10 
AND dx.[dx_norm] = rda.[code]
--INNER JOIN [ref].[perf_year_month] AS ym
--ON hd.[from_date] BETWEEN ym.[beg_month] AND ym.[end_month]
WHERE hd.[from_date] >= '2015-10-01'
--WHERE hd.[from_date] BETWEEN @measurement_start_date AND @measurement_end_date
--WHERE hd.[from_date] BETWEEN CAST(DATEADD(YEAR, -1, @measurement_start_date) AS DATE) AND @measurement_end_date

UNION

SELECT 
 hd.[id]
,hd.[tcn]
,hd.[from_date]
--,ym.[year_month]
,1 AS [flag]

FROM [dbo].[mcaid_claim_header] AS hd
-- Any diagnosis (not restricted to primary)
INNER JOIN [PHClaims].[dbo].[mcaid_claim_dx] AS dx
ON hd.[tcn] = dx.[tcn]
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_name] = 'MH-Dx-value-set'
AND rda.[code_set] = 'ICD9CM'
AND dx.[dx_ver] = 9 
AND dx.[dx_norm] = rda.[code]
--INNER JOIN [ref].[perf_year_month] AS ym
--ON hd.[from_date] BETWEEN ym.[beg_month] AND ym.[end_month]
WHERE hd.[from_date] < '2015-10-01'
--WHERE hd.[from_date] BETWEEN @measurement_start_date AND @measurement_end_date
--WHERE hd.[from_date] BETWEEN CAST(DATEADD(YEAR, -1, @measurement_start_date) AS DATE) AND @measurement_end_date

UNION

/*
Receipt of any psychotropic medication listed in MH‐Rx‐value‐set in the 
24‐month identification window.
*/

SELECT 
 hd.[id]
,hd.[tcn]
,hd.[from_date]
--,ym.[year_month]
,1 AS [flag]

FROM [dbo].[mcaid_claim_header] AS hd
INNER JOIN [dbo].[mcaid_claim_pharm] AS ph
ON hd.[tcn] = ph.[tcn]
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_name] = 'MH-Rx-value-set'
AND rda.[code_set] = 'NDC'
AND ph.[ndc_code] = rda.[code]
--INNER JOIN [PHClaims].[dbo].[ref_year_month] AS ym
--ON hd.[from_date] BETWEEN ym.[beg_month] AND ym.[end_month]
--WHERE hd.[from_date] BETWEEN @measurement_start_date AND @measurement_end_date
--WHERE hd.[from_date] BETWEEN CAST(DATEADD(YEAR, -1, @measurement_start_date) AS DATE) AND @measurement_end_date
GO

/*
-- 10,294,681
SELECT COUNT(*) FROM [stage].[v_perf_tpm_denominator];
*/