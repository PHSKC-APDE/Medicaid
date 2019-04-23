/*
This view gets claims that meet the requirements for the DSHS RDA Substance Use
Disorder Treatment Penetration rate numerator.

Author: Philip Sylling
Created: 2019-04-23
Last Modified: 2019-04-23

Returns:
 [id]
,[tcn]
,[from_date], [FROM_SRVC_DATE]
,[flag], 1 for claim meeting numerator criteria
*/

USE PHClaims;
GO

IF OBJECT_ID('[stage].[v_perf_tps_numerator]', 'V') IS NOT NULL
DROP VIEW [stage].[v_perf_tps_numerator];
GO
CREATE VIEW [stage].[v_perf_tps_numerator]
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
1. Procedure and DRG codes indicating receipt of inpatient/residential, 
outpatient, or methadone OST: SUD-Tx-Pen-Value-Set-2
SELECT *
FROM [PHClaims].[dbo].[ref_rda_value_sets] AS rda
WHERE rda.[value_set_name] = 'SUD-Tx-Pen-Value-Set-2'
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
ON rda.[value_set_name] = 'SUD-Tx-Pen-Value-Set-2'
AND rda.[code_set] IN ('HCPCS', 'ICD9PCS')
AND pr.[pcode] = rda.[code]
--INNER JOIN [ref].[perf_year_month] AS ym
--ON hd.[from_date] BETWEEN ym.[beg_month] AND ym.[end_month]
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
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_name] = 'SUD-Tx-Pen-Value-Set-2'
AND rda.[code_set] IN ('DRG')
AND hd.[drg_code] = rda.[code]
--INNER JOIN [ref].[perf_year_month] AS ym
--ON hd.[from_date] BETWEEN ym.[beg_month] AND ym.[end_month]
--WHERE hd.[from_date] BETWEEN @measurement_start_date AND @measurement_end_date
--WHERE hd.[from_date] BETWEEN CAST(DATEADD(YEAR, -1, @measurement_start_date) AS DATE) AND @measurement_end_date

UNION

/*
2. NDC codes indicating receipt of other forms of medication assisted treatment
for SUD: SUD-Tx-Pen-Value-Set-3
SELECT *
FROM [PHClaims].[dbo].[ref_rda_value_sets] AS rda
WHERE rda.[value_set_name] = 'SUD-Tx-Pen-Value-Set-3'
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
ON rda.[value_set_name] = 'SUD-Tx-Pen-Value-Set-3'
AND rda.[code_set] = 'NDC'
AND rda.[active] = 'Y'
AND ph.[ndc_code] = rda.[code]
--INNER JOIN [ref].[perf_year_month] AS ym
--ON hd.[from_date] BETWEEN ym.[beg_month] AND ym.[end_month]
--WHERE hd.[from_date] BETWEEN @measurement_start_date AND @measurement_end_date
--WHERE hd.[from_date] BETWEEN CAST(DATEADD(YEAR, -1, @measurement_start_date) AS DATE) AND @measurement_end_date

UNION

/*
3. Outpatient encounters meeting procedure code and primary diagnosis criteria:
a. Procedure code in SUD-Tx-Pen-Value-Set-6 AND
b. Primary diagnosis code in SUD-Tx-Pen-Value-Set-1
*/

SELECT
 [id]
,[tcn]
,[from_date]
--,[year_month]
,[flag]
FROM
(
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
ON rda.[value_set_name] = 'SUD-Tx-Pen-Value-Set-6'
AND rda.[code_set] IN ('CPT', 'HCPCS')
AND pr.[pcode] = rda.[code]
--INNER JOIN [ref].[perf_year_month] AS ym
--ON hd.[from_date] BETWEEN ym.[beg_month] AND ym.[end_month]
--WHERE hd.[from_date] BETWEEN @measurement_start_date AND @measurement_end_date
--WHERE hd.[from_date] BETWEEN CAST(DATEADD(YEAR, -1, @measurement_start_date) AS DATE) AND @measurement_end_date

INTERSECT

SELECT 
 hd.[id]
,hd.[tcn]
,hd.[from_date]
--,ym.[year_month]
,1 AS [flag]

FROM [dbo].[mcaid_claim_header] AS hd
INNER JOIN [dbo].[mcaid_claim_dx] AS dx
ON hd.[tcn] = dx.[tcn]
-- Primary Diagnosis
AND dx.[dx_number] = 1
INNER JOIN [ref].[rda_value_set] AS rda
ON [value_set_name] = 'SUD-Tx-Pen-Value-Set-1'
AND rda.[code_set] = 'ICD10CM'
AND dx.[dx_ver] = 10 
AND dx.[dx_norm] = rda.[code]
--INNER JOIN [ref].[perf_year_month] AS ym
--ON hd.[from_date] BETWEEN ym.[beg_month] AND ym.[end_month]
WHERE hd.[from_date] >= '2015-10-01'
--WHERE hd.[from_date] BETWEEN @measurement_start_date AND @measurement_end_date
--WHERE hd.[from_date] BETWEEN CAST(DATEADD(YEAR, -1, @measurement_start_date) AS DATE) AND @measurement_end_date
) AS SUD_Procedure_with_Dx_value_set_ICD10CM

UNION

SELECT
 [id]
,[tcn]
,[from_date]
--,[year_month]
,[flag]
FROM
(
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
ON rda.[value_set_name] = 'SUD-Tx-Pen-Value-Set-6'
AND rda.[code_set] IN ('CPT', 'HCPCS')
AND pr.[pcode] = rda.[code]
--INNER JOIN [ref].[perf_year_month] AS ym
--ON hd.[from_date] BETWEEN ym.[beg_month] AND ym.[end_month]
--WHERE hd.[from_date] BETWEEN @measurement_start_date AND @measurement_end_date
--WHERE hd.[from_date] BETWEEN CAST(DATEADD(YEAR, -1, @measurement_start_date) AS DATE) AND @measurement_end_date

INTERSECT

SELECT 
 hd.[id]
,hd.[tcn]
,hd.[from_date]
--,ym.[year_month]
,1 AS [flag]

FROM [dbo].[mcaid_claim_header] AS hd
INNER JOIN [dbo].[mcaid_claim_dx] AS dx
ON hd.[tcn] = dx.[tcn]
-- Primary Diagnosis
AND dx.[dx_number] = 1
INNER JOIN [ref].[rda_value_set] AS rda
ON [value_set_name] = 'SUD-Tx-Pen-Value-Set-1'
AND rda.[code_set] = 'ICD9CM'
AND dx.[dx_ver] = 9 
AND dx.[dx_norm] = rda.[code]
--INNER JOIN [ref].[perf_year_month] AS ym
--ON hd.[from_date] BETWEEN ym.[beg_month] AND ym.[end_month]
WHERE hd.[from_date] < '2015-10-01'
--WHERE hd.[from_date] BETWEEN @measurement_start_date AND @measurement_end_date
--WHERE hd.[from_date] BETWEEN CAST(DATEADD(YEAR, -1, @measurement_start_date) AS DATE) AND @measurement_end_date
) AS SUD_Procedure_with_Dx_value_set_ICD9CM;
GO

/*
4. Outpatient encounters meeting taxonomy and primary diagnosis criteria:
a. Billing or servicing provider taxonomy code in SUD-Tx-Pen-Value-Set-7 AND
b. Primary diagnosis code in SUD-Tx-Pen-Value-Set-1

TAXONOMY CODE NOT AVAILABLE IN MEDICAID DATA
*/

/*
-- 3,743,076
SELECT COUNT(*) FROM [stage].[v_perf_tps_numerator];
*/