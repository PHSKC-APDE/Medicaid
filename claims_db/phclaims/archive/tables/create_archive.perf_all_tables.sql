
USE [PHClaims]
GO

SELECT * 
INTO [archive].[perf_enroll_denom]
FROM [stage].[perf_enroll_denom];

CREATE CLUSTERED INDEX [idx_cl_perf_enroll_denom_id_year_month] ON [archive].[perf_enroll_denom]([id], [year_month]);
CREATE NONCLUSTERED INDEX [idx_nc_perf_enroll_denom_age_in_months] ON [archive].[perf_enroll_denom]([age_in_months]);
CREATE NONCLUSTERED INDEX [idx_nc_perf_enroll_denom_end_month_age] ON [archive].[perf_enroll_denom]([end_month_age]);

SELECT * 
INTO [archive].[perf_distinct_member]
FROM [stage].[perf_distinct_member];

CREATE CLUSTERED INDEX [idx_cl_perf_distinct_member_id] ON [archive].[perf_distinct_member]([id]);

SELECT * 
INTO [archive].[perf_staging]
FROM [stage].[perf_staging];

SELECT * 
INTO [archive].[perf_staging_event_date]
FROM [stage].[perf_staging_event_date];

IF OBJECT_ID('[archive].[mcaid_perf_measure]') IS NOT NULL
DROP TABLE [archive].[mcaid_perf_measure];
SELECT * 
INTO [archive].[mcaid_perf_measure]
FROM [stage].[mcaid_perf_measure];

