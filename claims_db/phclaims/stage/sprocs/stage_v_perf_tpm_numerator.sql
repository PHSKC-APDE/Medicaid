/*
This view gets claims that meet the requirements for the DSHS RDA Mental Health
Treatment Penetration rate numerator

Author: Philip Sylling
Last Modified: 2019-04-23

Returns:
 [id]
,[tcn]
,[from_date], [FROM_SRVC_DATE]
,[flag], 1 for claim meeting numerator criteria
*/

USE PHClaims;
GO

IF OBJECT_ID('[stage].[v_perf_tpm_numerator]', 'V') IS NOT NULL
DROP VIEW [stage].[v_perf_tpm_numerator];
GO
CREATE VIEW [stage].[v_perf_tpm_numerator]
AS
/*
SELECT [value_set_group]
      ,[value_set_name]
      ,[data_source_type]
      ,[code_set]
      ,COUNT([code])
FROM [ref].[rda_value_set]
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
Receipt of an outpatient service with a procedure code in the MH-procedure-value-set
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
Receipt of an outpatient service with a servicing provider taxonomy code in the
MH-taxonomy-value-set AND primary diagnosis code in the MH-Dx-value-set
PROVIDER TAXONOMY CODE NOT AVAILABLE IN MEDICAID
*/

/*
Receipt of an outpatient service with a procedure code in the 
MH-procedure-with-Dx-value-set AND primary diagnosis code in the 
MH-Dx-value-set
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
ON rda.[value_set_name] = 'MH-procedure-with-Dx-value-set'
AND rda.[code_set] IN ('CPT', 'HCPCS')
AND pr.[pcode] = rda.[code]
--INNER JOIN [ref].[perf_year_month] AS ym
--ON hd.[from_date] BETWEEN ym.[beg_month] AND ym.[end_month]
WHERE hd.[from_date] >= '2015-10-01'
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
ON [value_set_name] = 'MH-Dx-value-set'
AND rda.[code_set] = 'ICD10CM'
AND dx.[dx_ver] = 10 
AND dx.[dx_norm] = rda.[code]
--INNER JOIN [ref].[perf_year_month] AS ym
--ON hd.[from_date] BETWEEN ym.[beg_month] AND ym.[end_month]
WHERE hd.[from_date] >= '2015-10-01'
--WHERE hd.[from_date] BETWEEN @measurement_start_date AND @measurement_end_date
--WHERE hd.[from_date] BETWEEN CAST(DATEADD(YEAR, -1, @measurement_start_date) AS DATE) AND @measurement_end_date
) AS MH_procedure_with_Dx_value_set_ICD10CM

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
ON rda.[value_set_name] = 'MH-procedure-with-Dx-value-set'
AND rda.[code_set] IN ('CPT', 'HCPCS')
AND pr.[pcode] = rda.[code]
--INNER JOIN [ref].[perf_year_month] AS ym
--ON hd.[from_date] BETWEEN ym.[beg_month] AND ym.[end_month]
WHERE hd.[from_date] < '2015-10-01'
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
ON [value_set_name] = 'MH-Dx-value-set'
AND rda.[code_set] = 'ICD9CM'
AND dx.[dx_ver] = 9 
AND dx.[dx_norm] = rda.[code]
--INNER JOIN [ref].[perf_year_month] AS ym
--ON hd.[from_date] BETWEEN ym.[beg_month] AND ym.[end_month]
WHERE hd.[from_date] < '2015-10-01'
--WHERE hd.[from_date] BETWEEN @measurement_start_date AND @measurement_end_date
--WHERE hd.[from_date] BETWEEN CAST(DATEADD(YEAR, -1, @measurement_start_date) AS DATE) AND @measurement_end_date
) AS MH_procedure_with_Dx_value_set_ICD9CM;
GO

/*
-- 5,965,208
SELECT COUNT(*) FROM [stage].[v_perf_tpm_numerator];
*/

/*
This view gets BHO services that meet the requirements for the DSHS RDA Mental Health
Treatment Penetration rate numerator

Author: Philip Sylling
Created: 2019-05-06
Last Modified: 2019-05-06

Returns:
 [kcid]
,[ea_cpt_service_id]
,[tcn]
,[event_date]
,[flag], 1 for service meeting numerator criteria
*/

USE [DCHS_Analytics];
GO

IF OBJECT_ID('[stage].[v_perf_bho_tpm_numerator]', 'V') IS NOT NULL
DROP VIEW [stage].[v_perf_bho_tpm_numerator];
GO
CREATE VIEW [stage].[v_perf_bho_tpm_numerator]
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
*/

/*
Receipt of an outpatient service with a procedure code in the MH-procedure-value-set
*/
SELECT
--TOP(100)
 svc.[kcid]
,svc.[ea_cpt_service_id]
,svc.[tcn]
,svc.[event_date]
,1 AS [flag]

--SELECT COUNT(*)
FROM [php96].[service_procedure] AS svc
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_group] = 'MH'
AND rda.[value_set_name] = 'MH-procedure-value-set'
AND rda.[data_source_type] = 'Procedure'
AND rda.[code_set] IN ('CPT', 'HCPCS')
AND svc.[pcode] = rda.[code]

UNION

/*
Receipt of an outpatient service with a servicing provider taxonomy code in the
MH-taxonomy-value-set AND primary diagnosis code in the MH-Dx-value-set

SELECT [value_set_group]
      ,[value_set_name]
      ,[data_source_type]
      ,[code_set]
      ,[code]
FROM [ref].[rda_value_set]
WHERE [value_set_name] IN ('MH-taxonomy-value-set')
ORDER BY [code];
*/
(
SELECT
--TOP(100)
 svc.[kcid]
,svc.[ea_cpt_service_id]
,svc.[tcn]
,svc.[event_date]
,1 AS [flag]

--SELECT COUNT(*)
FROM [php96].[service_procedure] AS svc
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_group] = 'MH'
AND rda.[value_set_name] = 'MH-taxonomy-value-set'
AND rda.[data_source_type] = 'Provider'
AND rda.[code_set] IN ('HPT')
AND svc.[taxonomy] = rda.[code]

INTERSECT

SELECT
--TOP(100)
 dx.[kcid]
,dx.[ea_cpt_service_id]
,dx.[tcn]
,dx.[event_date]
,1 AS [flag]

--SELECT COUNT(*)
FROM [php96].[auth_service_dx] AS dx
INNER JOIN [ref].[rda_value_set] AS rda
ON [dx_number] = 1
AND rda.[value_set_group] = 'MH'
AND rda.[value_set_name] = 'MH-Dx-value-set'
AND rda.[data_source_type] = 'Diagnosis'
AND rda.[code_set] IN ('ICD10CM')
AND dx.[dx_norm] = rda.[code]
WHERE [event_date] >= '2015-10-01'
)

UNION

/*
Receipt of an outpatient service with a procedure code in the 
MH-procedure-with-Dx-value-set AND primary diagnosis code in the 
MH-Dx-value-set

SELECT [value_set_group]
      ,[value_set_name]
      ,[data_source_type]
      ,[code_set]
      ,[code]
FROM [ref].[rda_value_set]
WHERE [value_set_name] = 'MH-procedure-with-Dx-value-set'
ORDER BY [code];
*/
(
SELECT
--TOP(100)
 svc.[kcid]
,svc.[ea_cpt_service_id]
,svc.[tcn]
,svc.[event_date]
,1 AS [flag]

--SELECT COUNT(*)
FROM [php96].[service_procedure] AS svc
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_group] = 'MH'
AND rda.[value_set_name] = 'MH-procedure-with-Dx-value-set'
AND rda.[data_source_type] = 'Procedure'
AND rda.[code_set] IN ('CPT', 'HCPCS')
AND svc.[pcode] = rda.[code]

INTERSECT

SELECT
--TOP(100)
 dx.[kcid]
,dx.[ea_cpt_service_id]
,dx.[tcn]
,dx.[event_date]
,1 AS [flag]

--SELECT COUNT(*)
FROM [php96].[auth_service_dx] AS dx
INNER JOIN [ref].[rda_value_set] AS rda
ON [dx_number] = 1
AND rda.[value_set_group] = 'MH'
AND rda.[value_set_name] = 'MH-Dx-value-set'
AND rda.[data_source_type] = 'Diagnosis'
AND rda.[code_set] IN ('ICD10CM')
AND dx.[dx_norm] = rda.[code]
WHERE [event_date] >= '2015-10-01'
);
GO

/*
SELECT COUNT(*) FROM [stage].[v_perf_bho_tpm_numerator];
*/