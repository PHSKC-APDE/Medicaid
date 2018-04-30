--Code to create table to hold DISTINCT procedure codes in long format for Medicaid claims data -> dbo.mcaid_claim_proc
--Eli Kern
--APDE, PHSKC
--3/21/2018

use PHClaims
go

if object_id('dbo.mcaid_claim_proc', 'U') IS NOT NULL 
  drop table dbo.mcaid_claim_proc;

select distinct cast(id as varchar(200)) as 'id', cast(tcn as varchar(200)) as 'tcn',
	cast(pcode as varchar(200)) as 'pcode', cast(substring(proc_number, 6,4) as varchar(4)) as 'proc_number',
	cast(MDFR_CODE1 as varchar(200)) as 'pcode_mod_1', cast(MDFR_CODE2 as varchar(200)) as 'pcode_mod_2',
	cast(MDFR_CODE3 as varchar(200)) as 'pcode_mod_3', cast(MDFR_CODE4 as varchar(200)) as 'pcode_mod_4',

	--Procedure code type
	case
		--CPT
		when pcode between '01000' and '79999' then 'cpt'
		when left(pcode,4) between '0001' and '0011' and right(pcode,1) = 'M' then 'cpt'
		when pcode between '81490' and '81599' then 'cpt'
		when left(pcode,4) between '0001' and '0034' and right(pcode,1) = 'U' then 'cpt'
		when pcode between '80047' and '89398' then 'cpt'
		when pcode between '90281' and '99199' then 'cpt'
		when pcode between '99500' and '99607' then 'cpt'
		when pcode between '99201' and '99499' then 'cpt'
		when left(pcode,4) between '0001' and '9007' and right(pcode,1) = 'F' then 'cpt'
		when left(pcode,4) between '0042' and '0504' and right(pcode,1) = 'T' then 'cpt'
	else null end as 'pcode_type',

	--Procedure code, level 1

	--CPT
	case
		when pcode between '00100' and '01999' then 'Anesthesia'
		when pcode between '10021' and '69990' then 'Surgery'
		when pcode between '70010' and '79999' then 'Radiology'
		when pcode between '00100' and '01999' then 'Anesthesia'
		when left(pcode,4) between '0001' and '0011' and right(pcode,1) = 'M' then 'Pathology & laboratory'
		when pcode between '81490' and '81599' then 'Pathology & laboratory'
		when left(pcode,4) between '0001' and '0034' and right(pcode,1) = 'U' then 'Pathology & laboratory'
		when pcode between '80047' and '89398' then 'Pathology & laboratory'
		when pcode between '90281' and '99199' then 'Medicine'
		when pcode between '99500' and '99607' then 'Medicine'
		when pcode between '99201' and '99499' then 'Evaluation and management'
		when left(pcode,4) between '0001' and '9007' and right(pcode,1) = 'F' then 'Category II codes'
		when left(pcode,4) between '0042' and '0504' and right(pcode,1) = 'T' then 'Category III codes'
	else null end as 'pcode_level1',

	--Procedure code, level 2

	--CPT
	case
		when pcode between '00100' and '01999' then 'Anesthesia'
		when pcode between '10021' and '10022' then 'Surgery, general'
		when pcode between '10030' and '19499' then 'Surgery, skin'
		when pcode between '20005' and '29999' then 'Surgery, musculoskeletal'
		when pcode between '30000' and '32999' then 'Surgey, respiratory'
		when pcode between '33010' and '37799' then 'Surgery, cardiovascular'
		when pcode between '38100' and '38999' then 'Surgery, hemic and lymphatic'
		when pcode between '39000' and '39599' then 'Surgery, mediastinum and diaphragm'
		when pcode between '40490' and '49999' then 'Surgery, digestive'
		when pcode between '50010' and '53899' then 'Surgery, urinary'
		when pcode between '54000' and '55899' then 'Surgery, male genital'
		when pcode between '55920' and '55920' then 'Surgery, reproductive'
		when pcode between '55970' and '55980' then 'Surgery, intersex'
		when pcode between '56405' and '58999' then 'Surgery, female genital'
		when pcode between '59000' and '59899' then 'Surgery, maternity care and delivery'
		when pcode between '60000' and '60699' then 'Surgery, endocrine'
		when pcode between '61000' and '64999' then 'Surgery, nervous system'
		when pcode between '65091' and '68899' then 'Surgery, eye and ocular adnexa'
		when pcode between '69000' and '69979' then 'Surgery, auditory system'
		when pcode between '69990' and '69990' then 'Operating microscope procedures'
		when pcode between '70010' and '76499' then 'Diagnostic radiology'
		when pcode between '76506' and '76999' then 'Diagnostic ultrasound'
		when pcode between '77001' and '77022' then 'Radiologic guidance'
		when pcode between '77053' and '77067' then 'Breast, mammography'
		when pcode between '77071' and '77086' then 'Bone/joint studies'
		when pcode between '77261' and '77799' then 'Radiation oncology treatment'
		when pcode between '78012' and '79999' then 'Nuclear medicine'

		**********CONTINUE HERE***************


	else null end as 'pcode_level2'



into PHClaims.dbo.mcaid_claim_proc

from (
	select MEDICAID_RECIPIENT_ID AS 'id', TCN as 'tcn',
	PRCDR_CODE_1 AS 'proc_01', PRCDR_CODE_2 AS 'proc_02', PRCDR_CODE_3 AS 'proc_03', PRCDR_CODE_4 AS 'proc_04',
	PRCDR_CODE_5 AS 'proc_05', PRCDR_CODE_6 AS 'proc_06', PRCDR_CODE_7 AS 'proc_07', PRCDR_CODE_8 AS 'proc_08',
	PRCDR_CODE_9 AS 'proc_09', PRCDR_CODE_10 AS 'proc_10', PRCDR_CODE_11 AS 'proc_11',
	PRCDR_CODE_12 AS 'proc_12', LINE_PRCDR_CODE as 'proc_line', MDFR_CODE1, MDFR_CODE2, MDFR_CODE3, MDFR_CODE4
	from PHClaims.dbo.NewClaims
) a
unpivot(pcode for proc_number IN(proc_01,proc_02,proc_03,proc_04,proc_05,proc_06,proc_07,proc_08,proc_09,proc_10,proc_11,proc_12,proc_line)) as pcode
order by id, tcn, proc_number

--create indexes
create index [idx_proc] on PHClaims.dbo.mcaid_claim_proc (pcode)


