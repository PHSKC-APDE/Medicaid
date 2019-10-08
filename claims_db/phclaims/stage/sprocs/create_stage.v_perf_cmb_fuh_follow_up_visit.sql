
/*
This view gets follow-up visits for the FUH measure:
Follow-up Hospitalization for Mental Illness: 7 days
Follow-up Hospitalization for Mental Illness: 30 days

This query combines and de-duplicates follow-up visits for the FUH measure from
[stage].[v_perf_bho_fuh_follow_up_visit] (PHP96)
[PHClaims_RO].[PHClaims].[stage].[v_perf_fuh_follow_up_visit] (PHClaims)

_cmb_ is acronym for Combined

Author: Philip Sylling
Created: 2019-10-08

Returns:
 [id_mcaid]
,[event_date]
,[flag] = 1 for encounter meeting FUH follow-up criteria
,[only_30_day_fu], if 'Y' encounter only meets requirement for 30-day follow-up, if 'N' encounter meets requirement for 7-day and 30-day follow-up
*/

USE [DCHS_Analytics];
GO

IF OBJECT_ID('[stage].[v_perf_cmb_fuh_follow_up_visit]', 'V') IS NOT NULL
DROP VIEW [stage].[v_perf_cmb_fuh_follow_up_visit];
GO
CREATE VIEW [stage].[v_perf_cmb_fuh_follow_up_visit]
AS
/*
SELECT [measure_id]
      ,[value_set_name]
      ,[value_set_oid]
FROM [archive].[hedis_value_set]
WHERE [measure_id] = 'FUH';

SELECT [value_set_name]
      ,[code_system]
      ,COUNT([code])
FROM [archive].[hedis_code_system]
WHERE [value_set_name] IN
('FUH POS Group 1'
,'FUH POS Group 2'
,'FUH RevCodes Group 1'
,'FUH RevCodes Group 2'
,'FUH Stand Alone Visits'
,'FUH Visits Group 1'
,'FUH Visits Group 2'
,'Inpatient Stay'
,'Mental Health Diagnosis'
,'Mental Illness'
,'Nonacute Inpatient Stay'
,'TCM 14 Day'
,'TCM 7 Day'
,'Telehealth Modifier')
GROUP BY [value_set_name], [code_system]
ORDER BY [value_set_name], [code_system];
*/

SELECT
 [p1_id] AS [id_mcaid]
,[event_date]
,[flag]
,[only_30_day_fu]
FROM [stage].[v_perf_bho_fuh_follow_up_visit]
WHERE [p1_id] IS NOT NULL

UNION

SELECT
 [id_mcaid]
,[service_date] AS [event_date]
,[flag]
,[only_30_day_fu]
FROM [PHClaims_RO].[PHClaims].[stage].[v_perf_fuh_follow_up_visit];
GO

/*
SELECT TOP(100) *
FROM [stage].[v_perf_cmb_fuh_follow_up_visit]
WHERE [event_date] BETWEEN '2017-01-01' AND '2017-12-31';

SELECT COUNT(*)
FROM [stage].[v_perf_cmb_fuh_follow_up_visit]
WHERE [event_date] BETWEEN '2017-01-01' AND '2017-12-31';
*/