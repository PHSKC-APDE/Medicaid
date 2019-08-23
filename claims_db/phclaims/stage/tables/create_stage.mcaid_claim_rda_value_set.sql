
USE PHClaims;
GO

/*
SELECT 
 [value_set_group]
,[value_set_name]
,[data_source_type]
,[sub_group]
,[code_set]
,COUNT([code])
FROM [PHClaims].[ref].[rda_value_set]
WHERE [value_set_group] = 'OUD'
GROUP BY
 [value_set_group]
,[value_set_name]
,[data_source_type]
,[sub_group]
,[code_set];
*/

IF OBJECT_ID('[stage].[mcaid_claim_rda_value_set]') IS NOT NULL
DROP TABLE [stage].[mcaid_claim_rda_value_set];
CREATE TABLE [stage].[mcaid_claim_rda_value_set]
([value_set_name] VARCHAR(100) NOT NULL
,[data_source_type] VARCHAR(50) NOT NULL
,[sub_group] VARCHAR(50) NOT NULL
,[code_set] VARCHAR(50) NOT NULL
,[primary_dx_only] CHAR(1) NOT NULL
,[id_mcaid] VARCHAR(255) NOT NULL
,[claim_header_id] BIGINT NOT NULL
,[first_service_date] DATE NOT NULL
,[last_service_date] DATE NOT NULL);
GO

INSERT INTO [stage].[mcaid_claim_rda_value_set]
SELECT DISTINCT
 rda.[value_set_name]
,rda.[data_source_type]
,rda.[sub_group]
,rda.[code_set]
,'N' AS [primary_dx_only]
,dx.[id_mcaid]
,dx.[claim_header_id]
,dx.[first_service_date]
,dx.[last_service_date]
FROM [final].[mcaid_claim_icdcm_header] AS dx
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_name] = 'OUD-Tx-Pen-Value-Set-1'
AND rda.[code_set] = 'ICD9CM'
AND dx.[icdcm_version] = 9 
AND dx.[icdcm_norm] = rda.[code]
WHERE dx.[first_service_date] < '2015-10-01';

INSERT INTO [stage].[mcaid_claim_rda_value_set]
SELECT DISTINCT
 rda.[value_set_name]
,rda.[data_source_type]
,rda.[sub_group]
,rda.[code_set]
,'N' AS [primary_dx_only]
,dx.[id_mcaid]
,dx.[claim_header_id]
,dx.[first_service_date]
,dx.[last_service_date]
FROM [final].[mcaid_claim_icdcm_header] AS dx
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_name] = 'OUD-Tx-Pen-Value-Set-1'
AND rda.[code_set] = 'ICD10CM'
AND dx.[icdcm_version] = 10 
AND dx.[icdcm_norm] = rda.[code]
WHERE dx.[first_service_date] >= '2015-10-01';

INSERT INTO [stage].[mcaid_claim_rda_value_set]
SELECT DISTINCT
 rda.[value_set_name]
,rda.[data_source_type]
,rda.[sub_group]
,rda.[code_set]
,'N' AS [primary_dx_only]
,ph.[id_mcaid]
,ph.[claim_header_id]
,ph.[rx_fill_date] AS [first_service_date]
,ph.[rx_fill_date] AS [last_service_date]
FROM [final].[mcaid_claim_pharm] AS ph
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_name] = 'OUD-Tx-Pen-Value-Set-2'
AND rda.[code_set] = 'NDC'
AND rda.[active] = 'Y'
AND ph.[ndc] = rda.[code];

INSERT INTO [stage].[mcaid_claim_rda_value_set]
SELECT DISTINCT
 rda.[value_set_name]
,rda.[data_source_type]
,rda.[sub_group]
,rda.[code_set]
,'N' AS [primary_dx_only]
,pr.[id_mcaid]
,pr.[claim_header_id]
,pr.[first_service_date]
,pr.[last_service_date]
FROM [final].[mcaid_claim_procedure] AS pr
INNER JOIN [ref].[rda_value_set] AS rda
ON rda.[value_set_name] = 'OUD-Tx-Pen-Receipt-of-MAT'
AND rda.[code_set] IN ('HCPCS')
AND pr.[procedure_code] = rda.[code];
