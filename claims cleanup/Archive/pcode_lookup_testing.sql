select z.category_broad, count(y.pcode) as 'pcode_cnt'

	from (
	select tcn, from_date
	from PHClaims.dbo.mcaid_claim_header
	where year(from_date) = 2016
	) as x

	left join (
	select * from [PHClaims].[dbo].[mcaid_claim_proc] 
	) as y
	on x.tcn = y.tcn

	left join (
	select *
	from PHClaims.dbo.ref_pcode
	) as z
	on y.pcode = z.pcode

group by z.category_broad

--explore pcodes that don't match to ccs lookup
select y.pcode, count(y.pcode)

	from (
	select tcn, from_date
	from PHClaims.dbo.mcaid_claim_header
	where year(from_date) = 2016
	) as x

	left join (
	select * from [PHClaims].[dbo].[mcaid_claim_proc] 
	) as y
	on x.tcn = y.tcn

	left join (
	select *
	from PHClaims.dbo.ref_pcode
	) as z
	on y.pcode = z.pcode

where z.category_broad is null
group by y.pcode
order by y.pcode