
/*
This query combines and de-duplicates hospital stays from
[stage].[v_perf_bho_fuh_inpatient_index_stay] (PHP96)
[stage].[v_perf_fuh_inpatient_index_stay] (PHClaims)

_cmb_ is acronym for Combined

Includes
(1) BHO voluntary hospitalizations
(2) Western State hospitalizations
(3) Medicaid hospitalizations meeting either 'Mental Illness' or 'Mental Health Diagnosis' criteria

The stays are combined below if admit/discharge dates are identical or overlapping.
Example: For discharges in 2018, there are
(1) 1,995, (2) 280, (3) 691 = 2,966
After de-duplicating by identical [id_mcaid], [age], [admit_date], [discharge_date], there are 2,862
After combining overlapping dates, there are 2,837

Example:
1st record is Admit 2018-07-04, Discharge 2018-07-11
Next record is Admit 2018-07-04, Discharge 2018-07-19
Combine into one record
Admit 2018-07-04, Discharge 2018-07-19

Example:
1st record is Admit 2018-07-27, Discharge 2018-10-03
Next record is Admit 2018-09-05, Discharge 2018-09-26
Second stay is completely nested within first stay
Combine into one record
Admit 2018-07-27, Discharge 2018-10-03

Example:
1st record is Admit 2018-01-07, Discharge 2018-01-08
Next record is Admit 2018-01-08, Discharge 2018-01-31
Retain both records, last discharge would be used for follow-up in subsequent step

Author: Philip Sylling
Created: 2019-10-08

Returns
 [value_set_name], Either 'Mental Illness' or 'Mental Health Diagnosis' depending on input parameter
,[id_mcaid]
,[age], age at discharge
,[admit_date]
,[discharge_date]
,[flag] = 1
*/

USE [DCHS_Analytics];
GO
IF OBJECT_ID('[stage].[fn_perf_cmb_fuh_inpatient_index_stay]', 'IF') IS NOT NULL
DROP FUNCTION [stage].[fn_perf_cmb_fuh_inpatient_index_stay];
GO
CREATE FUNCTION [stage].[fn_perf_cmb_fuh_inpatient_index_stay]
(@dx_value_set_name VARCHAR(100))
RETURNS TABLE 
AS
RETURN

/*
SELECT [value_set_name]
      ,[code_system]
      ,COUNT([code])
FROM [archive].[hedis_code_system]
WHERE [value_set_name] IN
('Mental Illness'
,'Mental Health Diagnosis'
,'Inpatient Stay'
,'Nonacute Inpatient Stay')
GROUP BY [value_set_name], [code_system]
ORDER BY [value_set_name], [code_system];
*/

--DECLARE @dx_value_set_name VARCHAR(100) = 'Mental Illness';

WITH [inpatient_stays] AS
(
--DECLARE @dx_value_set_name VARCHAR(100) = 'Mental Illness';
SELECT
 @dx_value_set_name AS [value_set_name]
,[p1_id] AS [id_mcaid]
,[age]
,[admit_date]
,[discharge_date]
,[flag]
FROM [stage].[v_perf_bho_fuh_inpatient_index_stay]
WHERE 1 = 1
AND [p1_id] IS NOT NULL
AND [ip_type] = 'V'
--AND [discharge_date] BETWEEN '2018-01-01' AND '2018-12-31'

UNION

--DECLARE @dx_value_set_name VARCHAR(100) = 'Mental Illness';
SELECT
 @dx_value_set_name AS [value_set_name]
,[p1_id] AS [id_mcaid]
,[age]
,[admit_date]
,[discharge_date]
,[flag]
FROM [stage].[v_perf_bho_fuh_inpatient_index_stay]
WHERE 1 = 1
AND [p1_id] IS NOT NULL
AND [ip_type] = 'WSH'
--AND [discharge_date] BETWEEN '2018-01-01' AND '2018-12-31'

UNION

--DECLARE @dx_value_set_name VARCHAR(100) = 'Mental Illness';
SELECT
 [value_set_name]
,[id_mcaid]
,[age]
,[admit_date]
,[discharge_date]
,[flag]
FROM [PHClaims_RO].[PHClaims].[stage].[v_perf_fuh_inpatient_index_stay]
WHERE 1 = 1
AND [value_set_name] = @dx_value_set_name
--AND [admit_date] >= '2015-01-01'
--AND [discharge_date] BETWEEN '2018-01-01' AND '2018-12-31'
),

[increment_stays_by_person] AS
(
SELECT
 [value_set_name]
,[id_mcaid]
,[age]
-- If [prior_discharge_date] IS NULL, then it is the first chronological discharge for the person
,LAG([discharge_date]) OVER(PARTITION BY [id_mcaid] ORDER BY [admit_date], [discharge_date]) AS [prior_discharge_date]
,[admit_date]
,[discharge_date]
-- Number of days between consecutive rows
,DATEDIFF(DAY, LAG([discharge_date]) OVER(PARTITION BY [id_mcaid] 
 ORDER BY [admit_date], [discharge_date]), [admit_date]) AS [date_diff]
/*
Create a chronological (0, 1) indicator column.
If 0, it is the first stay for the person OR the stay appears to be a duplicate
(overlapping admit/discharge dates) of the prior stay.
If 1, the prior stay appears to be distinct from the following stay.
This indicator column will be summed to create an episode_id.
*/
,CASE WHEN ROW_NUMBER() OVER(PARTITION BY [id_mcaid] 
      ORDER BY [admit_date], [discharge_date]) = 1 THEN 0
      WHEN DATEDIFF(DAY, LAG([discharge_date]) OVER(PARTITION BY [id_mcaid]
	  ORDER BY [admit_date], [discharge_date]), [admit_date]) < 0 THEN 0
	  WHEN DATEDIFF(DAY, LAG([discharge_date]) OVER(PARTITION BY [id_mcaid]
	  ORDER BY [admit_date], [discharge_date]), [admit_date]) >= 0 THEN 1
 END AS [increment]
FROM [inpatient_stays]
--ORDER BY [id_mcaid], [admit_date], [discharge_date]
),

/*
Sum [increment] column (Cumulative Sum) within person to create an stay_id that
combines duplicate/overlapping stays.
*/
[create_stay_id] AS
(
SELECT
 [value_set_name]
,[id_mcaid]
,[age]
,[prior_discharge_date]
,[admit_date]
,[discharge_date]
,[date_diff]
,[increment]
,SUM([increment]) OVER(PARTITION BY [id_mcaid] ORDER BY [admit_date], [discharge_date] ROWS UNBOUNDED PRECEDING) + 1 AS [stay_id]
FROM [increment_stays_by_person]
--ORDER BY [id_mcaid], [admit_date], [discharge_date]
),

/*
For duplicate/overlapping stays,
Calculate admit/discharge dates using FIRST_VALUE([admit_date]), 
LAST_VALUE([discharge_date]) grouping by [id_mcaid] and [stay_id] from the
previous step.
*/
[admit_discharge_date] AS
(
SELECT
 [value_set_name]
,[id_mcaid]
,[age]
,[prior_discharge_date]
,[admit_date]
,[discharge_date]
,[date_diff]
,[increment]
,[stay_id]
/*
,LAST_VALUE([age]) OVER(PARTITION BY [id_mcaid], [stay_id] 
 ORDER BY [admit_date], [discharge_date] ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS [last_age]
,FIRST_VALUE([admit_date]) OVER(PARTITION BY [id_mcaid], [stay_id] 
 ORDER BY [admit_date], [discharge_date] ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS [first_admit_date]
,LAST_VALUE([discharge_date]) OVER(PARTITION BY [id_mcaid], [stay_id] 
 ORDER BY [admit_date], [discharge_date] ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS [last_discharge_date]
*/
,MAX([age]) OVER(PARTITION BY [id_mcaid], [stay_id]) AS [last_age]
,MIN([admit_date]) OVER(PARTITION BY [id_mcaid], [stay_id]) AS [first_admit_date]
,MAX([discharge_date]) OVER(PARTITION BY [id_mcaid], [stay_id]) AS [last_discharge_date]
,COUNT(*) OVER(PARTITION BY [id_mcaid], [stay_id]) AS [row_num]
,ROW_NUMBER() OVER(PARTITION BY [id_mcaid], [stay_id] 
 ORDER BY [admit_date], [discharge_date]) AS [stay_counter]
FROM [create_stay_id]
--ORDER BY [id_mcaid], [admit_date], [discharge_date]
)

SELECT
 [value_set_name]
,[id_mcaid]
--,[age]
--,[prior_discharge_date]
--,[admit_date]
--,[discharge_date]
--,[date_diff]
--,[increment]
--,[stay_id]
,[last_age] AS [age]
,[first_admit_date] AS [admit_date]
,[last_discharge_date] AS [discharge_date]
--,[row_num]
--,[stay_counter]
,1 AS [flag]
FROM [admit_discharge_date]
WHERE [stay_counter] = 1;
GO

/*
SELECT *
FROM [stage].[fn_perf_cmb_fuh_inpatient_index_stay]('Mental Illness');
--FROM [stage].[fn_perf_cmb_fuh_inpatient_index_stay]('Mental Health Diagnosis');

SELECT DISTINCT
 [value_set_name]
,[id_mcaid]
,[age]
,[admit_date]
,[discharge_date]
,[flag]
FROM [stage].[fn_perf_cmb_fuh_inpatient_index_stay]('Mental Illness');
--FROM [stage].[fn_perf_cmb_fuh_inpatient_index_stay]('Mental Health Diagnosis');

SELECT 
 [year_quarter]
,COUNT(*)
FROM [stage].[fn_perf_cmb_fuh_inpatient_index_stay]('Mental Illness') AS a
INNER JOIN [ref].[date] AS b
ON a.[admit_date] = b.[date]
GROUP BY
 [year_quarter]
ORDER BY
 [year_quarter];
*/
