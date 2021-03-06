
/*
This view gets claims that meet the requirements for the DSHS RDA Mental Health
Treatment Penetration rate numerator AND divides them into diagnosis groups.

Author: Philip Sylling
Created: 2019-04-23
Modified: 2019-08-07 | Point to new [final] analytic tables
Modified: 2019-11-05 | Modify view to retain diagnosis group

Returns:
 [id_mcaid]
,[claim_header_id]
,[first_service_date], [FROM_SRVC_DATE]
,[sub_group] (ADHD, Adjustment, Anxiety, Depression, Disrup/Impulse/Conduct, Mania/Bipolar, Psychotic)
,[flag], 1 for claim meeting numerator criteria
*/

USE [PHClaims];
GO

IF OBJECT_ID('[stage].[v_perf_tpm_by_dx_numerator]', 'V') IS NOT NULL
DROP VIEW [stage].[v_perf_tpm_by_dx_numerator];
GO
CREATE VIEW [stage].[v_perf_tpm_by_dx_numerator]
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
Receipt of an outpatient service with a procedure code in the MH-procedure-value-set.
This procedure will satisfy ANY of the diagnosis categories.
Programmatically, the qualifying procedures will be CROSS JOINED with the 7 diagnosis categories.
*/

SELECT 
--TOP(100)
 pr.[id_mcaid]
,pr.[claim_header_id]
,pr.[first_service_date]
,a.[sub_group]
,1 AS [flag]

--SELECT COUNT(*)
FROM [final].[mcaid_claim_procedure] AS pr
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_name] = 'MH-procedure-value-set'
AND rda.[code_set] IN ('CPT', 'HCPCS')
AND pr.[procedure_code] = rda.[code]
CROSS JOIN (VALUES
 ('ADHD')
,('Adjustment')
,('Anxiety')
,('Depression')
,('Disrup/Impulse/Conduct')
,('Mania/Bipolar')
,('Psychotic')
) AS a([sub_group])

/*
Receipt of an outpatient service with a servicing provider taxonomy code in the
MH-taxonomy-value-set AND primary diagnosis code in the MH-Dx-value-set
PROVIDER TAXONOMY CODE NOT AVAILABLE IN MEDICAID
*/

/*
Receipt of an outpatient service with a procedure code in the 
MH-procedure-with-Dx-value-set AND PRIMARY diagnosis code in the 
MH-Dx-value-set
*/

UNION

SELECT
 dx.[id_mcaid]
,dx.[claim_header_id]
,dx.[first_service_date]
,rda.[sub_group]
,1 AS [flag]

FROM [final].[mcaid_claim_icdcm_header] AS dx
INNER JOIN [ref].[rda_value_set] AS rda
ON [value_set_name] = 'MH-Dx-value-set'
AND rda.[code_set] = 'ICD9CM'
AND dx.[icdcm_version] = 9
-- Primary Diagnosis
AND dx.[icdcm_number] = '01'
AND dx.[icdcm_norm] = rda.[code]
WHERE dx.[first_service_date] < '2015-10-01'
AND dx.[claim_header_id] IN
(
SELECT [claim_header_id]
FROM [final].[mcaid_claim_procedure] AS pr
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_name] IN ('MH-procedure-with-Dx-value-set')
AND rda.[code_set] IN ('CPT', 'HCPCS')
AND pr.[procedure_code] = rda.[code]
)

UNION

SELECT 
 dx.[id_mcaid]
,dx.[claim_header_id]
,dx.[first_service_date]
,rda.[sub_group]
,1 AS [flag]

FROM [final].[mcaid_claim_icdcm_header] AS dx
INNER JOIN [ref].[rda_value_set] AS rda
ON [value_set_name] = 'MH-Dx-value-set'
AND rda.[code_set] = 'ICD10CM'
AND dx.[icdcm_version] = 10
-- Primary Diagnosis
AND dx.[icdcm_number] = '01'
AND dx.[icdcm_norm] = rda.[code]
WHERE dx.[first_service_date] >= '2015-10-01'
AND dx.[claim_header_id] IN
(
SELECT [claim_header_id]
FROM [final].[mcaid_claim_procedure] AS pr
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_name] IN ('MH-procedure-with-Dx-value-set')
AND rda.[code_set] IN ('CPT', 'HCPCS')
AND pr.[procedure_code] = rda.[code]
);
GO

/*
SELECT COUNT(*) FROM [stage].[v_perf_tpm_by_dx_numerator];

SELECT TOP(100) * FROM [stage].[v_perf_tpm_by_dx_numerator];
SELECT TOP(100) * FROM [stage].[v_perf_tpm_by_dx_denominator];
*/