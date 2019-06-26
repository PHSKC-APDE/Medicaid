--Code to create archive.apcd_cmsdrg_output_multi_ver
--Eli Kern (PHSKC-APDE)
--2019-6-26

if object_id('PHClaims.archive.apcd_cmsdrg_output_multi_ver', 'U') is not null drop table PHClaims.archive.apcd_cmsdrg_output_multi_ver;
create table PHClaims.archive.apcd_cmsdrg_output_multi_ver (
[inpatient_discharge_id] [bigint] NULL,
	[internal_member_id] [bigint] NULL,
	[userkey1] [varchar](15) NULL,
	[userkey2] [varchar](15) NULL,
	[condition_code1] [varchar](2) NULL,
	[condition_code2] [varchar](2) NULL,
	[condition_code3] [varchar](2) NULL,
	[condition_code4] [varchar](2) NULL,
	[condition_code5] [varchar](2) NULL,
	[condition_code6] [varchar](2) NULL,
	[condition_code7] [varchar](2) NULL,
	[condition_code8] [varchar](2) NULL,
	[condition_code9] [varchar](2) NULL,
	[condition_code10] [varchar](2) NULL,
	[condition_code11] [varchar](2) NULL,
	[icd_version_ind] [varchar](2) NULL,
	[dmv_days_after_admit] [int] NULL,
	[length_of_stay] [int] NULL,
	[discharge_days_after_admit] [int] NULL,
	[grouper_type_version] [int] NULL,
	[drg] [varchar](3) NULL,
	[mdc] [int] NULL,
	[return_code_clinical] [int] NULL,
	[severity_of_illness] [int] NULL,
	[dx_soi_level1] [varchar](1) NULL,
	[dx_soi_level2] [varchar](1) NULL,
	[dx_soi_level3] [varchar](1) NULL,
	[dx_soi_level4] [varchar](1) NULL,
	[dx_soi_level5] [varchar](1) NULL,
	[dx_soi_level6] [varchar](1) NULL,
	[dx_soi_level7] [varchar](1) NULL,
	[dx_soi_level8] [varchar](1) NULL,
	[dx_soi_level9] [varchar](1) NULL,
	[dx_soi_level10] [varchar](1) NULL,
	[dx_soi_level11] [varchar](1) NULL,
	[dx_soi_level12] [varchar](1) NULL,
	[dx_soi_level13] [varchar](1) NULL,
	[dx_soi_level14] [varchar](1) NULL,
	[dx_soi_level15] [varchar](1) NULL,
	[dx_soi_level16] [varchar](1) NULL,
	[dx_soi_level17] [varchar](1) NULL,
	[dx_soi_level18] [varchar](1) NULL,
	[dx_soi_level19] [varchar](1) NULL,
	[dx_soi_level20] [varchar](1) NULL,
	[dx_soi_level21] [varchar](1) NULL,
	[dx_soi_level22] [varchar](1) NULL,
	[dx_soi_level23] [varchar](1) NULL,
	[dx_soi_level24] [varchar](1) NULL,
	[dx_soi_level25] [varchar](1) NULL,
	[dx_soi_level26] [varchar](1) NULL,
	[dx_soi_level27] [varchar](1) NULL,
	[dx_soi_level28] [varchar](1) NULL,
	[dx_soi_level29] [varchar](1) NULL,
	[dx_soi_level30] [varchar](1) NULL,
	[dx_soi_level31] [varchar](1) NULL,
	[dx_soi_level32] [varchar](1) NULL,
	[dx_soi_level33] [varchar](1) NULL,
	[dx_soi_level34] [varchar](1) NULL,
	[dx_soi_level35] [varchar](1) NULL,
	[dx_soi_level36] [varchar](1) NULL,
	[dx_soi_level37] [varchar](1) NULL,
	[dx_soi_level38] [varchar](1) NULL,
	[dx_soi_level39] [varchar](1) NULL,
	[dx_soi_level40] [varchar](1) NULL,
	[dx_soi_level41] [varchar](1) NULL,
	[dx_soi_level42] [varchar](1) NULL,
	[dx_soi_level43] [varchar](1) NULL,
	[dx_soi_level44] [varchar](1) NULL,
	[dx_soi_level45] [varchar](1) NULL,
	[dx_soi_level46] [varchar](1) NULL,
	[dx_soi_level47] [varchar](1) NULL,
	[dx_soi_level48] [varchar](1) NULL,
	[dx_soi_level49] [varchar](1) NULL,
	[dx_soi_level50] [varchar](1) NULL,
	[risk_of_mortality] [int] NULL,
	[dx_rom_level1] [varchar](1) NULL,
	[dx_rom_level2] [varchar](1) NULL,
	[dx_rom_level3] [varchar](1) NULL,
	[dx_rom_level4] [varchar](1) NULL,
	[dx_rom_level5] [varchar](1) NULL,
	[dx_rom_level6] [varchar](1) NULL,
	[dx_rom_level7] [varchar](1) NULL,
	[dx_rom_level8] [varchar](1) NULL,
	[dx_rom_level9] [varchar](1) NULL,
	[dx_rom_level10] [varchar](1) NULL,
	[dx_rom_level11] [varchar](1) NULL,
	[dx_rom_level12] [varchar](1) NULL,
	[dx_rom_level13] [varchar](1) NULL,
	[dx_rom_level14] [varchar](1) NULL,
	[dx_rom_level15] [varchar](1) NULL,
	[dx_rom_level16] [varchar](1) NULL,
	[dx_rom_level17] [varchar](1) NULL,
	[dx_rom_level18] [varchar](1) NULL,
	[dx_rom_level19] [varchar](1) NULL,
	[dx_rom_level20] [varchar](1) NULL,
	[dx_rom_level21] [varchar](1) NULL,
	[dx_rom_level22] [varchar](1) NULL,
	[dx_rom_level23] [varchar](1) NULL,
	[dx_rom_level24] [varchar](1) NULL,
	[dx_rom_level25] [varchar](1) NULL,
	[dx_rom_level26] [varchar](1) NULL,
	[dx_rom_level27] [varchar](1) NULL,
	[dx_rom_level28] [varchar](1) NULL,
	[dx_rom_level29] [varchar](1) NULL,
	[dx_rom_level30] [varchar](1) NULL,
	[dx_rom_level31] [varchar](1) NULL,
	[dx_rom_level32] [varchar](1) NULL,
	[dx_rom_level33] [varchar](1) NULL,
	[dx_rom_level34] [varchar](1) NULL,
	[dx_rom_level35] [varchar](1) NULL,
	[dx_rom_level36] [varchar](1) NULL,
	[dx_rom_level37] [varchar](1) NULL,
	[dx_rom_level38] [varchar](1) NULL,
	[dx_rom_level39] [varchar](1) NULL,
	[dx_rom_level40] [varchar](1) NULL,
	[dx_rom_level41] [varchar](1) NULL,
	[dx_rom_level42] [varchar](1) NULL,
	[dx_rom_level43] [varchar](1) NULL,
	[dx_rom_level44] [varchar](1) NULL,
	[dx_rom_level45] [varchar](1) NULL,
	[dx_rom_level46] [varchar](1) NULL,
	[dx_rom_level47] [varchar](1) NULL,
	[dx_rom_level48] [varchar](1) NULL,
	[dx_rom_level49] [varchar](1) NULL,
	[dx_rom_level50] [varchar](1) NULL,
	[principal_dx_edits_inpatient] [int] NULL,
	[secondary_dx_edits_inpatient1] [int] NULL,
	[secondary_dx_edits_inpatient2] [int] NULL,
	[secondary_dx_edits_inpatient3] [int] NULL,
	[secondary_dx_edits_inpatient4] [int] NULL,
	[secondary_dx_edits_inpatient5] [int] NULL,
	[secondary_dx_edits_inpatient6] [int] NULL,
	[secondary_dx_edits_inpatient7] [int] NULL,
	[secondary_dx_edits_inpatient8] [int] NULL,
	[secondary_dx_edits_inpatient9] [int] NULL,
	[secondary_dx_edits_inpatient10] [int] NULL,
	[secondary_dx_edits_inpatient11] [int] NULL,
	[secondary_dx_edits_inpatient12] [int] NULL,
	[secondary_dx_edits_inpatient13] [int] NULL,
	[secondary_dx_edits_inpatient14] [int] NULL,
	[secondary_dx_edits_inpatient15] [int] NULL,
	[secondary_dx_edits_inpatient16] [int] NULL,
	[secondary_dx_edits_inpatient17] [int] NULL,
	[secondary_dx_edits_inpatient18] [int] NULL,
	[secondary_dx_edits_inpatient19] [int] NULL,
	[secondary_dx_edits_inpatient20] [int] NULL,
	[secondary_dx_edits_inpatient21] [int] NULL,
	[secondary_dx_edits_inpatient22] [int] NULL,
	[secondary_dx_edits_inpatient23] [int] NULL,
	[secondary_dx_edits_inpatient24] [int] NULL,
	[secondary_dx_edits_inpatient25] [int] NULL,
	[secondary_dx_edits_inpatient26] [int] NULL,
	[secondary_dx_edits_inpatient27] [int] NULL,
	[secondary_dx_edits_inpatient28] [int] NULL,
	[secondary_dx_edits_inpatient29] [int] NULL,
	[secondary_dx_edits_inpatient30] [int] NULL,
	[secondary_dx_edits_inpatient31] [int] NULL,
	[secondary_dx_edits_inpatient32] [int] NULL,
	[secondary_dx_edits_inpatient33] [int] NULL,
	[secondary_dx_edits_inpatient34] [int] NULL,
	[secondary_dx_edits_inpatient35] [int] NULL,
	[secondary_dx_edits_inpatient36] [int] NULL,
	[secondary_dx_edits_inpatient37] [int] NULL,
	[secondary_dx_edits_inpatient38] [int] NULL,
	[secondary_dx_edits_inpatient39] [int] NULL,
	[secondary_dx_edits_inpatient40] [int] NULL,
	[secondary_dx_edits_inpatient41] [int] NULL,
	[secondary_dx_edits_inpatient42] [int] NULL,
	[secondary_dx_edits_inpatient43] [int] NULL,
	[secondary_dx_edits_inpatient44] [int] NULL,
	[secondary_dx_edits_inpatient45] [int] NULL,
	[secondary_dx_edits_inpatient46] [int] NULL,
	[secondary_dx_edits_inpatient47] [int] NULL,
	[secondary_dx_edits_inpatient48] [int] NULL,
	[secondary_dx_edits_inpatient49] [int] NULL,
	[procedure_edits1] [int] NULL,
	[procedure_edits2] [int] NULL,
	[procedure_edits3] [int] NULL,
	[procedure_edits4] [int] NULL,
	[procedure_edits5] [int] NULL,
	[procedure_edits6] [int] NULL,
	[procedure_edits7] [int] NULL,
	[procedure_edits8] [int] NULL,
	[procedure_edits9] [int] NULL,
	[procedure_edits10] [int] NULL,
	[procedure_edits11] [int] NULL,
	[procedure_edits12] [int] NULL,
	[procedure_edits13] [int] NULL,
	[procedure_edits14] [int] NULL,
	[procedure_edits15] [int] NULL,
	[procedure_edits16] [int] NULL,
	[procedure_edits17] [int] NULL,
	[procedure_edits18] [int] NULL,
	[procedure_edits19] [int] NULL,
	[procedure_edits20] [int] NULL,
	[procedure_edits21] [int] NULL,
	[procedure_edits22] [int] NULL,
	[procedure_edits23] [int] NULL,
	[procedure_edits24] [int] NULL,
	[procedure_edits25] [int] NULL,
	[procedure_edits26] [int] NULL,
	[procedure_edits27] [int] NULL,
	[procedure_edits28] [int] NULL,
	[procedure_edits29] [int] NULL,
	[procedure_edits30] [int] NULL,
	[procedure_edits31] [int] NULL,
	[procedure_edits32] [int] NULL,
	[procedure_edits33] [int] NULL,
	[procedure_edits34] [int] NULL,
	[procedure_edits35] [int] NULL,
	[procedure_edits36] [int] NULL,
	[procedure_edits37] [int] NULL,
	[procedure_edits38] [int] NULL,
	[procedure_edits39] [int] NULL,
	[procedure_edits40] [int] NULL,
	[procedure_edits41] [int] NULL,
	[procedure_edits42] [int] NULL,
	[procedure_edits43] [int] NULL,
	[procedure_edits44] [int] NULL,
	[procedure_edits45] [int] NULL,
	[procedure_edits46] [int] NULL,
	[procedure_edits47] [int] NULL,
	[procedure_edits48] [int] NULL,
	[procedure_edits49] [int] NULL,
	[procedure_edits50] [int] NULL,
	[procedure_edits51] [int] NULL,
	[mapping_indicator] [int] NULL,
	[mapping_dt] [date] NULL,
	[mapping_type] [int] NULL,
	[weight] [numeric](9, 4) NULL,
	[medical_surgical_flag] [int] NULL,
	[admit_dx_edits_inpatient] [int] NULL,
	[dx_affect_drg_flag1] [int] NULL,
	[dx_affect_drg_flag2] [int] NULL,
	[dx_affect_drg_flag3] [int] NULL,
	[dx_affect_drg_flag4] [int] NULL,
	[dx_affect_drg_flag5] [int] NULL,
	[dx_affect_drg_flag6] [int] NULL,
	[dx_affect_drg_flag7] [int] NULL,
	[dx_affect_drg_flag8] [int] NULL,
	[dx_affect_drg_flag9] [int] NULL,
	[dx_affect_drg_flag10] [int] NULL,
	[dx_affect_drg_flag11] [int] NULL,
	[dx_affect_drg_flag12] [int] NULL,
	[dx_affect_drg_flag13] [int] NULL,
	[dx_affect_drg_flag14] [int] NULL,
	[dx_affect_drg_flag15] [int] NULL,
	[dx_affect_drg_flag16] [int] NULL,
	[dx_affect_drg_flag17] [int] NULL,
	[dx_affect_drg_flag18] [int] NULL,
	[dx_affect_drg_flag19] [int] NULL,
	[dx_affect_drg_flag20] [int] NULL,
	[dx_affect_drg_flag21] [int] NULL,
	[dx_affect_drg_flag22] [int] NULL,
	[dx_affect_drg_flag23] [int] NULL,
	[dx_affect_drg_flag24] [int] NULL,
	[dx_affect_drg_flag25] [int] NULL,
	[dx_affect_drg_flag26] [int] NULL,
	[dx_affect_drg_flag27] [int] NULL,
	[dx_affect_drg_flag28] [int] NULL,
	[dx_affect_drg_flag29] [int] NULL,
	[dx_affect_drg_flag30] [int] NULL,
	[dx_affect_drg_flag31] [int] NULL,
	[dx_affect_drg_flag32] [int] NULL,
	[dx_affect_drg_flag33] [int] NULL,
	[dx_affect_drg_flag34] [int] NULL,
	[dx_affect_drg_flag35] [int] NULL,
	[dx_affect_drg_flag36] [int] NULL,
	[dx_affect_drg_flag37] [int] NULL,
	[dx_affect_drg_flag38] [int] NULL,
	[dx_affect_drg_flag39] [int] NULL,
	[dx_affect_drg_flag40] [int] NULL,
	[dx_affect_drg_flag41] [int] NULL,
	[dx_affect_drg_flag42] [int] NULL,
	[dx_affect_drg_flag43] [int] NULL,
	[dx_affect_drg_flag44] [int] NULL,
	[dx_affect_drg_flag45] [int] NULL,
	[dx_affect_drg_flag46] [int] NULL,
	[dx_affect_drg_flag47] [int] NULL,
	[dx_affect_drg_flag48] [int] NULL,
	[dx_affect_drg_flag49] [int] NULL,
	[dx_affect_drg_flag50] [int] NULL,
	[procedure_affect_drg_flag1] [int] NULL,
	[procedure_affect_drg_flag2] [int] NULL,
	[procedure_affect_drg_flag3] [int] NULL,
	[procedure_affect_drg_flag4] [int] NULL,
	[procedure_affect_drg_flag5] [int] NULL,
	[procedure_affect_drg_flag6] [int] NULL,
	[procedure_affect_drg_flag7] [int] NULL,
	[procedure_affect_drg_flag8] [int] NULL,
	[procedure_affect_drg_flag9] [int] NULL,
	[procedure_affect_drg_flag10] [int] NULL,
	[procedure_affect_drg_flag11] [int] NULL,
	[procedure_affect_drg_flag12] [int] NULL,
	[procedure_affect_drg_flag13] [int] NULL,
	[procedure_affect_drg_flag14] [int] NULL,
	[procedure_affect_drg_flag15] [int] NULL,
	[procedure_affect_drg_flag16] [int] NULL,
	[procedure_affect_drg_flag17] [int] NULL,
	[procedure_affect_drg_flag18] [int] NULL,
	[procedure_affect_drg_flag19] [int] NULL,
	[procedure_affect_drg_flag20] [int] NULL,
	[procedure_affect_drg_flag21] [int] NULL,
	[procedure_affect_drg_flag22] [int] NULL,
	[procedure_affect_drg_flag23] [int] NULL,
	[procedure_affect_drg_flag24] [int] NULL,
	[procedure_affect_drg_flag25] [int] NULL,
	[procedure_affect_drg_flag26] [int] NULL,
	[procedure_affect_drg_flag27] [int] NULL,
	[procedure_affect_drg_flag28] [int] NULL,
	[procedure_affect_drg_flag29] [int] NULL,
	[procedure_affect_drg_flag30] [int] NULL,
	[procedure_affect_drg_flag31] [int] NULL,
	[procedure_affect_drg_flag32] [int] NULL,
	[procedure_affect_drg_flag33] [int] NULL,
	[procedure_affect_drg_flag34] [int] NULL,
	[procedure_affect_drg_flag35] [int] NULL,
	[procedure_affect_drg_flag36] [int] NULL,
	[procedure_affect_drg_flag37] [int] NULL,
	[procedure_affect_drg_flag38] [int] NULL,
	[procedure_affect_drg_flag39] [int] NULL,
	[procedure_affect_drg_flag40] [int] NULL,
	[procedure_affect_drg_flag41] [int] NULL,
	[procedure_affect_drg_flag42] [int] NULL,
	[procedure_affect_drg_flag43] [int] NULL,
	[procedure_affect_drg_flag44] [int] NULL,
	[procedure_affect_drg_flag45] [int] NULL,
	[procedure_affect_drg_flag46] [int] NULL,
	[procedure_affect_drg_flag47] [int] NULL,
	[procedure_affect_drg_flag48] [int] NULL,
	[procedure_affect_drg_flag49] [int] NULL,
	[procedure_affect_drg_flag50] [int] NULL,
	[procedure_affect_drg_flag51] [int] NULL,
	[drg_label_id] [bigint] NULL,
	[extract_id] [bigint] NULL
);



