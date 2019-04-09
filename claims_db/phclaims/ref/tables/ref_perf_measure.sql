
USE PHClaims;
GO

IF OBJECT_ID('[ref].[perf_measure]') IS NOT NULL
DROP TABLE [ref].[perf_measure];
CREATE TABLE [ref].[perf_measure]
([measure_id] INT NOT NULL
,[measure_short_name] VARCHAR(200)
,[measure_name] VARCHAR(200)
,[age_group] VARCHAR(200)
,[age_group_desc] VARCHAR(200)
,[mcaid_enrolled] VARCHAR(200)
,[expressed_as] VARCHAR(200)
,CONSTRAINT [PK_ref_perf_measure] PRIMARY KEY CLUSTERED ([measure_id])
);
GO
INSERT INTO [ref].[perf_measure]([measure_id], [measure_short_name], [measure_name], [age_group], [age_group_desc], [mcaid_enrolled], [expressed_as])
VALUES
 (1, 'ED', 'All-Cause ED Visits', 'age_grp_2', 'Age 0-17, Age 18-64, Age 65+', '7+ months Medicaid enrolled in measurement period', 'Per 1,000 member months')
,(2, 'AH', 'Acute Hospital Utilization', 'age_grp_1', 'Age 18+', '11+ months Medicaid enrolled in measurement period', 'Per 1,000 members')
,(3, 'FUA_7', 'Follow-up ED visit for Alcohol/Drug Abuse: 7 days', 'age_grp_3', 'Age 13+', '30+ days Medicaid enrolled following event', 'Proportion of index events')
,(4, 'FUA_30', 'Follow-up ED visit for Alcohol/Drug Abuse: 30 days', 'age_grp_3', 'Age 13+', '30+ days Medicaid enrolled following event', 'Proportion of index events')
,(5, 'FUM_7', 'Follow-up ED visit for Mental Illness: 7 days', 'age_grp_4', 'Age 6+', '30+ days Medicaid enrolled following event', 'Proportion of index events')
,(6, 'FUM_30', 'Follow-up ED visit for Mental Illness: 30 days', 'age_grp_4', 'Age 6+', '30+ days Medicaid enrolled following event', 'Proportion of index events')
,(7, 'FUH_7', 'Follow-up Hospitalization for Mental Illness: 7 days', 'age_grp_4', 'Age 6+', '30+ days Medicaid enrolled following event', 'Proportion of index events')
,(8, 'FUH_30', 'Follow-up Hospitalization for Mental Illness: 30 days', 'age_grp_4', 'Age 6+', '30+ days Medicaid enrolled following event', 'Proportion of index events')
,(9, 'TPM', 'Mental Health Treatment Penetration', 'age_grp_5', 'Age 6-17, Age 18-64, Age 65+', '11+ months Medicaid enrolled in measurement period', 'Proportion of members')
,(10, 'TPS', 'SUD Treatment Penetration', 'age_grp_6', 'Age 12-17, Age 18-64, Age 65+', '11+ months Medicaid enrolled in measurement period', 'Proportion of members')
,(11, 'TPO', 'SUD Treatment Penetration (Opioid)', 'age_grp_7', 'Age 18-64, Age 65+', '11+ months Medicaid enrolled in measurement period', 'Proportion of members')
,(12, 'PCR', 'Plan All-Cause Readmissions (30 days)', 'age_grp_8', 'Age 18-64', '11+ months Medicaid enrolled prior to discharge, 30+ days following discharge', 'Proportion of index events')
,(13, 'CAP', 'Child and Adolescent Access to Primary Care', 'age_grp_9_months', 'Age 12-24 Months, Age 25 Months-6, Age 7-11, Age 12-19', '11+ months Medicaid enrolled in measurement period, if applicable: 11+ months Medicaid enrolled in year prior to measurement period', '')
,(14, '', 'Diabetes Care: Eye Exam', '', '', '', '')
,(15, '', 'Diabetes Care: A1c Testing', '', '', '', '')
,(16, '', 'Diabetes Care: Kidney Screening', '', '', '', '')
,(17, '', 'Asthma Medication Management', '', '', '', '')
,(18, '', 'Percent Homeless', '', '', '', '')
,(19, '', 'Antidepressant Medication Management', '', '', '', '')
,(20, '', 'High-dose Chronic Opioid Therapy', '', '', '', '')
,(21, '', 'Concurrent Opioids and Sedatives Prescriptions', '', '', '', '')
,(22, '', 'Statin Therapy for Heart Disease', '', '', '', '')
GO
CREATE NONCLUSTERED INDEX idx_nc_ref_perf_measure_measure_name ON [ref].[perf_measure]([measure_name]);
GO

/*
IF OBJECT_ID('[dbo].[ref_p4p_measure]') IS NOT NULL
DROP TABLE [dbo].[ref_p4p_measure];
CREATE TABLE [dbo].[ref_p4p_measure]
([measure_id] INT NOT NULL
,[measure_short_name] VARCHAR(200)
,[measure_name] VARCHAR(200)
,[age_group] VARCHAR(200)
,[age_group_desc] VARCHAR(200)
,[mcaid_enrolled] VARCHAR(200)
,[expressed_as] VARCHAR(200)
,CONSTRAINT [PK_ref_p4p_measure] PRIMARY KEY CLUSTERED ([measure_id])
);
GO
INSERT INTO [dbo].[ref_p4p_measure]([measure_id], [measure_short_name], [measure_name], [age_group], [age_group_desc], [mcaid_enrolled], [expressed_as])
VALUES
 (1, 'ED', 'All-Cause ED Visits', 'age_grp_2', 'Age 0-17, Age 18-64, Age 65+', '7+ months Medicaid enrolled in measurement period', 'Per 1,000 member months')
,(2, 'AH', 'Acute Hospital Utilization', 'age_grp_1', 'Age 18+', '11+ months Medicaid enrolled in measurement period', 'Per 1,000 members')
,(3, 'FUA_7', 'Follow-up ED visit for Alcohol/Drug Abuse: 7 days', 'age_grp_3', 'Age 13+', '30+ days Medicaid enrolled following event', 'Proportion of index events')
,(4, 'FUA_30', 'Follow-up ED visit for Alcohol/Drug Abuse: 30 days', 'age_grp_3', 'Age 13+', '30+ days Medicaid enrolled following event', 'Proportion of index events')
,(5, 'FUM_7', 'Follow-up ED visit for Mental Illness: 7 days', 'age_grp_4', 'Age 6+', '30+ days Medicaid enrolled following event', 'Proportion of index events')
,(6, 'FUM_30', 'Follow-up ED visit for Mental Illness: 30 days', 'age_grp_4', 'Age 6+', '30+ days Medicaid enrolled following event', 'Proportion of index events')
,(7, 'FUH_7', 'Follow-up Hospitalization for Mental Illness: 7 days', 'age_grp_4', 'Age 6+', '30+ days Medicaid enrolled following event', 'Proportion of index events')
,(8, 'FUH_30', 'Follow-up Hospitalization for Mental Illness: 30 days', 'age_grp_4', 'Age 6+', '30+ days Medicaid enrolled following event', 'Proportion of index events')
,(9, 'TPM', 'Mental Health Treatment Penetration', 'age_grp_5', 'Age 6-17, Age 18-64, Age 65+', '11+ months Medicaid enrolled in measurement period', 'Proportion of members')
,(10, 'TPS', 'SUD Treatment Penetration', 'age_grp_6', 'Age 12-17, Age 18-64, Age 65+', '11+ months Medicaid enrolled in measurement period', 'Proportion of members')
,(11, 'TPO', 'SUD Treatment Penetration (Opioid)', 'age_grp_7', 'Age 18-64, Age 65+', '11+ months Medicaid enrolled in measurement period', 'Proportion of members')
,(12, 'PCR', 'Plan All-Cause Readmissions (30 days)', 'age_grp_8', 'Age 18-64', '11+ months Medicaid enrolled prior to discharge, 30+ days following discharge', 'Proportion of index events')
,(13, 'CAP', 'Child and Adolescent Access to Primary Care', 'age_grp_9', 'Age 12-24 months, 25 months-6 years, 7-11, 12-19', '11+ months Medicaid enrolled in measurement period, if applicable: 11+ months Medicaid enrolled in year prior to measurement period', '')
,(14, '', 'Diabetes Care: Eye Exam', '', '', '', '')
,(15, '', 'Diabetes Care: A1c Testing', '', '', '', '')
,(16, '', 'Diabetes Care: Kidney Screening', '', '', '', '')
,(17, '', 'Asthma Medication Management', '', '', '', '')
,(18, '', 'Percent Homeless', '', '', '', '')
,(19, '', 'Antidepressant Medication Management', '', '', '', '')
,(20, '', 'High-dose Chronic Opioid Therapy', '', '', '', '')
,(21, '', 'Concurrent Opioids and Sedatives Prescriptions', '', '', '', '')
,(22, '', 'Statin Therapy for Heart Disease', '', '', '', '')
GO
CREATE NONCLUSTERED INDEX idx_nc_ref_p4p_measure_measure_name ON [dbo].[ref_p4p_measure]([measure_name]);
GO
*/