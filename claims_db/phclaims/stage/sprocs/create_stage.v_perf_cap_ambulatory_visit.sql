
USE PHClaims;
GO

IF OBJECT_ID('[stage].[v_perf_cap_ambulatory_visit]', 'V') IS NOT NULL
DROP VIEW [stage].[v_perf_cap_ambulatory_visit];
GO
CREATE VIEW [stage].[v_perf_cap_ambulatory_visit]
AS
/*
SELECT [value_set_name]
      ,[code_system]
	  ,COUNT([code])
FROM [archive].[hedis_code_system]
WHERE [value_set_name] IN ('Ambulatory Visits')
GROUP BY [value_set_name], [code_system];
*/

WITH [get_claims] AS
(
SELECT 
 pr.[id_mcaid]
,pr.[claim_header_id]
,pr.[first_service_date]
,pr.[last_service_date]
,1 AS [flag]

--SELECT COUNT(*)
FROM [final].[mcaid_claim_procedure] AS pr
INNER JOIN [archive].[hedis_code_system] AS hed
ON [value_set_name] IN 
('Ambulatory Visits')
AND hed.[code_system] IN ('CPT', 'HCPCS')
AND pr.[procedure_code] = hed.[code]

UNION

SELECT 
 dx.[id_mcaid]
,dx.[claim_header_id]
,dx.[first_service_date]
,dx.[last_service_date]
,1 AS [flag]

--SELECT COUNT(*)
FROM [final].[mcaid_claim_icdcm_header] AS dx
INNER JOIN [archive].[hedis_code_system] AS hed
ON [value_set_name] IN 
('Ambulatory Visits')
AND hed.[code_system] = 'ICD10CM'
AND dx.[icdcm_version] = 10 
AND dx.[icdcm_norm] = hed.[code]

UNION

SELECT 
 ln.[id_mcaid]
,ln.[claim_header_id]
,ln.[first_service_date]
,ln.[last_service_date]
,1 AS [flag]

--SELECT COUNT(*)
FROM [final].[mcaid_claim_line] AS ln
INNER JOIN [archive].[hedis_code_system] AS hed
ON [value_set_name] IN 
('Ambulatory Visits')
AND hed.[code_system] = 'UBREV'
AND ln.[rev_code] = hed.[code]
)

SELECT 
 ym.[year_month]
,a.[id_mcaid]
,a.[claim_header_id]
,a.[first_service_date]
,a.[last_service_date]
,a.[flag]
FROM [get_claims] AS a
INNER JOIN [ref].[date] AS ym
ON a.[first_service_date] = ym.[date]
GO

/*
-- 10,271,484 rows
IF OBJECT_ID('tempdb..#temp') IS NOT NULL
DROP TABLE #temp;
SELECT * 
INTO #temp
FROM [stage].[v_perf_cap_ambulatory_visit];

SELECT TOP(100) * 
FROM #temp;

SELECT NumRows
      ,COUNT(*)
FROM
(
SELECT [id_mcaid]
      ,[claim_header_id]
      ,COUNT(*) AS NumRows
FROM #temp
GROUP BY [id_mcaid], [claim_header_id]
) AS SubQuery
GROUP BY NumRows
ORDER BY NumRows;
*/

