
/*
This code creates table ([stage].[mcaid_claim_line]) to hold DISTINCT 
line-level claim information

Created by: Eli Kern, APDE, PHSKC, 2018-03-21
Modified by: Philip Sylling, 2019-06-07

Data Pull Run time: 00:10:25
Create Index Run Time: 00:05:32

Table 'mcaid_claim'. Scan count 3, logical reads 8955218, physical reads 0, read-ahead reads 8926013, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 621302, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

Returns
[stage].[mcaid_claim_line]
 [id_mcaid]
,[claim_header_id]
,[claim_line_id]
,[rev_code]
,[rac_code_line]
*/

use PHClaims;
go

--set statistics io on;
--set statistics time on;

if object_id('[stage].[mcaid_claim_line]', 'U') IS NOT NULL 
drop table [stage].[mcaid_claim_line];
--if object_id('tempdb..#mcaid_claim_line', 'U') IS NOT NULL 
--drop table #mcaid_claim_line;

select 
distinct 
 cast(MEDICAID_RECIPIENT_ID as varchar(200)) as id_mcaid
,cast(TCN as bigint) as claim_header_id
,cast(CLM_LINE_TCN as bigint) as claim_line_id
,cast(REVENUE_CODE as varchar(200)) as rev_code
,cast(RAC_CODE_L as varchar(200)) as rac_code_line

into [stage].[mcaid_claim_line]
--into #mcaid_claim_line

from [stage].[mcaid_claim]


CREATE CLUSTERED INDEX [idx_cl_stage_mcaid_claim_line_claim_header_id] ON [stage].[mcaid_claim_line]([claim_header_id]);
GO
CREATE NONCLUSTERED INDEX [idx_nc_stage_mcaid_claim_line_rev_code] ON [stage].[mcaid_claim_line]([rev_code]);
GO

/*
CREATE CLUSTERED INDEX [idx_cl_#mcaid_claim_line_claim_header_id] ON #mcaid_claim_line([claim_header_id]);
GO
CREATE NONCLUSTERED INDEX [idx_nc_#mcaid_claim_line_rev_code] ON #mcaid_claim_line([rev_code]);
GO
*/