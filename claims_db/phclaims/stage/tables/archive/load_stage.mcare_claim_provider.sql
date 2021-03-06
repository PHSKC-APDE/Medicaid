--Code to load data to stage.mcare_claim_provider table
--Provider information as submitted reshaped to long
--Eli Kern (PHSKC-APDE)
--2020-01
--Run time: XX min

------------------
--STEP 1: Select and union desired columns from multi-year claim tables on stage schema
--Exclude all denied claims using proposed approach per ResDAC 01-2020 consult
--Unpivot and insert into table shell
-------------------
insert into PHClaims.stage.mcare_claim_provider with (tablock)

select z.id_mcare,
	claim_header_id,
	first_service_date,
	last_service_date,
	provider_npi,
    provider_type,
	provider_type_nch,
	provider_tin,
	case
		when provider_type = 'rendering' then provider_zip_rendering
		when provider_type = 'billing' then provider_zip_billing
	end as provider_zip,
	case
		when provider_type = 'attending' then provider_specialty_attending
		when provider_type = 'operating' then provider_specialty_operating
		when provider_type = 'other' then provider_specialty_other
		when provider_type = 'referring' then provider_specialty_referring
		when provider_type = 'rendering' then provider_specialty_rendering
	end as provider_specialty,
	filetype_mcare,
	getdate() as last_run

from (
	--bcarrier
	select id_mcare,
		claim_header_id,
		first_service_date,
		last_service_date,
		--original diagnosis code
		cast(providers as bigint) as 'provider_npi',
		--procedure code number/type
		cast(provider_type as varchar(200)) as 'provider_type',
		--other provider information
		provider_type_nch,
		provider_tin,
		--temporary provider zip and specialty columns for further processing
		provider_zip_rendering,
		provider_zip_billing,
		provider_specialty_attending,
		provider_specialty_operating,
		provider_specialty_other,
		provider_specialty_referring,
		provider_specialty_rendering,
		filetype_mcare,
		getdate() as last_run

	from (
		select
		top 100
		rtrim(a.id_mcare) as id_mcare,
		rtrim(a.claim_header_id) as claim_header_id,
		a.first_service_date,
		a.last_service_date,
		'carrier' as filetype_mcare,
		a.provider_billing_npi as billing,
		a.provider_referring_npi as referring,
		a.provider_cpo_npi as care_plan_oversight,
		a.provider_sos_npi as site_of_service,
		b.provider_rendering_npi as rendering,
		b.provider_org_npi as organization,
		b.provider_rendering_type as provider_type_nch,
		b.provider_rendering_tin as provider_tin,
		b.provider_rendering_zip as provider_zip_rendering,
		b.provider_billing_zip as provider_zip_billing,
		provider_specialty_attending = null,
		provider_specialty_operating = null,
		provider_specialty_other = null,
		provider_specialty_referring = null,
		b.provider_rendering_specialty as provider_specialty_rendering
		from PHClaims.stage.mcare_bcarrier_claims as a
		left join PHClaims.stage.mcare_bcarrier_line as b
		on a.claim_header_id = b.claim_header_id
		--exclude denined claims using carrier/dme claim method
		where a.denial_code in ('1','2','3','4','5','6','7','8','9')
	) as x1

	--reshape from wide to long
	unpivot(providers for provider_type in (
		billing,
		referring,
		care_plan_oversight,
		site_of_service,
		rendering,
		organization)
	) as providers
	where len(providers) = 10 and isnumeric(providers) = 1

	--dme
	union
	select id_mcare,
		claim_header_id,
		first_service_date,
		last_service_date,
		--original diagnosis code
		cast(providers as bigint) as 'provider_npi',
		--procedure code number/type
		cast(provider_type as varchar(200)) as 'provider_type',
		--other provider information
		provider_type_nch,
		provider_tin,
		--temporary provider zip and specialty columns for further processing
		provider_zip_rendering,
		provider_zip_billing,
		provider_specialty_attending,
		provider_specialty_operating,
		provider_specialty_other,
		provider_specialty_referring,
		provider_specialty_rendering,
		filetype_mcare,
		getdate() as last_run

	from(
		select
		top 100
		rtrim(a.id_mcare) as id_mcare,
		rtrim(a.claim_header_id) as claim_header_id,
		a.first_service_date,
		a.last_service_date,
		'dme' as filetype_mcare,
		b.provider_supplier_npi as billing,
		a.provider_referring_npi as referring,
		provider_type_nch = null,
		provider_tin = null,
		provider_zip_rendering = null,
		provider_zip_billing = null,
		provider_specialty_attending = null,
		provider_specialty_operating = null,
		provider_specialty_other = null,
		provider_specialty_referring = null,
		provider_specialty_rendering = null
		from PHClaims.stage.mcare_dme_claims as a
		left join PHClaims.stage.mcare_dme_line as b
		on a.claim_header_id = b.claim_header_id
		--exclude denined claims using carrier/dme claim method
		where a.denial_code in ('1','2','3','4','5','6','7','8','9')
	) as x2

	--reshape from wide to long
	unpivot(providers for provider_type in (
		billing,
		referring)
	) as providers
	where len(providers) = 10 and isnumeric(providers) = 1

	--hha
	union
		select id_mcare,
		claim_header_id,
		first_service_date,
		last_service_date,
		--original diagnosis code
		cast(providers as bigint) as 'provider_npi',
		--procedure code number/type
		cast(provider_type as varchar(200)) as 'provider_type',
		--other provider information
		provider_type_nch,
		provider_tin,
		--temporary provider zip and specialty columns for further processing
		provider_zip_rendering,
		provider_zip_billing,
		provider_specialty_attending,
		provider_specialty_operating,
		provider_specialty_other,
		provider_specialty_referring,
		provider_specialty_rendering,
		filetype_mcare,
		getdate() as last_run

	from (
		select
		top 100
		rtrim(a.id_mcare) as id_mcare,
		rtrim(a.claim_header_id) as claim_header_id,
		a.first_service_date,
		a.last_service_date,
		'hha' as filetype_mcare,
		a.provider_org_npi as billing,
		a.provider_referring_npi as referring,
		care_plan_oversight = null,
		a.provider_sos_npi as site_of_service,
		a.provider_rendering_npi as rendering,
		organization = null,
		a.provider_attending_npi as attending,
		a.provider_operating_npi as operating,
		a.provider_other_npi as other,
		provider_type_nch = null,
		provider_tin = null,
		a.provider_rendering_zip as provider_zip_rendering,
		provider_zip_billing = null,
		a.provider_attending_specialty as provider_specialty_attending,
		a.provider_operating_specialty as provider_specialty_operating,
		a.provider_other_specialty as provider_specialty_other,
		a.provider_referring_specialty as provider_specialty_referring,
		a.provider_rendering_specialty as provider_specialty_rendering
		from PHClaims.stage.mcare_hha_base_claims as a
		left join PHClaims.stage.mcare_hha_revenue_center as b
		on a.claim_header_id = b.claim_header_id
		--exclude denined claims using carrier/dme claim method
		where (a.denial_code_facility = '' or a.denial_code_facility is null)
	) as x3

	--reshape from wide to long
	unpivot(providers for provider_type in (
		billing,
		referring,
		site_of_service,
		rendering,
		attending,
		operating,
		other)
	) as providers
	where len(providers) = 10 and isnumeric(providers) = 1

	--hospice
	union
	select id_mcare,
		claim_header_id,
		first_service_date,
		last_service_date,
		--original diagnosis code
		cast(providers as bigint) as 'provider_npi',
		--procedure code number/type
		cast(provider_type as varchar(200)) as 'provider_type',
		--other provider information
		provider_type_nch,
		provider_tin,
		--temporary provider zip and specialty columns for further processing
		provider_zip_rendering,
		provider_zip_billing,
		provider_specialty_attending,
		provider_specialty_operating,
		provider_specialty_other,
		provider_specialty_referring,
		provider_specialty_rendering,
		filetype_mcare,
		getdate() as last_run

	from (
		select
		top 100
		rtrim(a.id_mcare) as id_mcare,
		rtrim(a.claim_header_id) as claim_header_id,
		a.first_service_date,
		a.last_service_date,
		'hospice' as filetype_mcare,
		a.provider_org_npi as billing,
		a.provider_referring_npi as referring,
		care_plan_oversight = null,
		a.provider_sos_npi as site_of_service,
		case when a.provider_rendering_npi is not null then a.provider_rendering_npi else b.provider_rendering_npi
			end as rendering,
		organization = null,
		a.provider_attending_npi as attending,
		a.provider_operating_npi as operating,
		a.provider_other_npi as other,
		provider_type_nch = null,
		provider_tin = null,
		provider_zip_rendering = null,
		provider_zip_billing = null,
		a.provider_attending_specialty as provider_specialty_attending,
		a.provider_operating_specialty as provider_specialty_operating,
		a.provider_other_specialty as provider_specialty_other,
		a.provider_referring_specialty as provider_specialty_referring,
		case when a.provider_rendering_npi is not null then a.provider_rendering_specialty else b.provider_rendering_specialty
			end as provider_specialty_rendering
		from PHClaims.stage.mcare_hospice_base_claims as a
		left join PHClaims.stage.mcare_hospice_revenue_center as b
		on a.claim_header_id = b.claim_header_id
		--exclude denined claims using carrier/dme claim method
		where (a.denial_code_facility = '' or a.denial_code_facility is null)
	) as x4

	--reshape from wide to long
	unpivot(providers for provider_type in (
		billing,
		referring,
		site_of_service,
		rendering,
		attending,
		operating,
		other)
	) as providers
	where len(providers) = 10 and isnumeric(providers) = 1

	--inpatient
	union
	select id_mcare,
		claim_header_id,
		first_service_date,
		last_service_date,
		--original diagnosis code
		cast(providers as bigint) as 'provider_npi',
		--procedure code number/type
		cast(provider_type as varchar(200)) as 'provider_type',
		--other provider information
		provider_type_nch,
		provider_tin,
		--temporary provider zip and specialty columns for further processing
		provider_zip_rendering,
		provider_zip_billing,
		provider_specialty_attending,
		provider_specialty_operating,
		provider_specialty_other,
		provider_specialty_referring,
		provider_specialty_rendering,
		filetype_mcare,
		getdate() as last_run

	from (
		select
		top 100
		rtrim(a.id_mcare) as id_mcare,
		rtrim(a.claim_header_id) as claim_header_id,
		a.first_service_date,
		a.last_service_date,
		'inpatient' as filetype_mcare,
		a.provider_org_npi as billing,
		referring = null,
		care_plan_oversight = null,
		site_of_service = null,
		a.provider_rendering_npi as rendering,
		organization = null,
		a.provider_attending_npi as attending,
		a.provider_operating_npi as operating,
		a.provider_other_npi as other,
		provider_type_nch = null,
		provider_tin = null,
		provider_zip_rendering = null,
		provider_zip_billing = null,
		a.provider_attending_specialty as provider_specialty_attending,
		a.provider_operating_specialty as provider_specialty_operating,
		a.provider_other_specialty as provider_specialty_other,
		provider_specialty_referring = null,
		a.provider_rendering_specialty as provider_specialty_rendering
		from PHClaims.stage.mcare_inpatient_base_claims as a
		left join PHClaims.stage.mcare_inpatient_revenue_center as b
		on a.claim_header_id = b.claim_header_id
		--exclude denined claims using carrier/dme claim method
		where (a.denial_code_facility = '' or a.denial_code_facility is null)
	) as x5

	--reshape from wide to long
	unpivot(providers for provider_type in (
		billing,
		rendering,
		attending,
		operating,
		other)
	) as providers
	where len(providers) = 10 and isnumeric(providers) = 1


	--outpatient
	union
	select id_mcare,
		claim_header_id,
		first_service_date,
		last_service_date,
		--original diagnosis code
		cast(providers as bigint) as 'provider_npi',
		--procedure code number/type
		cast(provider_type as varchar(200)) as 'provider_type',
		--other provider information
		provider_type_nch,
		provider_tin,
		--temporary provider zip and specialty columns for further processing
		provider_zip_rendering,
		provider_zip_billing,
		provider_specialty_attending,
		provider_specialty_operating,
		provider_specialty_other,
		provider_specialty_referring,
		provider_specialty_rendering,
		filetype_mcare,
		getdate() as last_run

	from (
		select
		top 100
		rtrim(a.id_mcare) as id_mcare,
		rtrim(a.claim_header_id) as claim_header_id,
		a.first_service_date,
		a.last_service_date,
		'outpatient' as filetype_mcare,
		a.provider_org_npi as billing,
		a.provider_referring_npi as referring,
		care_plan_oversight = null,
		a.provider_sos_npi as site_of_service,
		case
			when a.provider_rendering_npi is not null then a.provider_rendering_npi
			when len(b.provider_rendering_npi) = 10 then b.provider_rendering_npi
			else null
		end as rendering,
		organization = null,
		a.provider_attending_npi as attending,
		a.provider_operating_npi as operating,
		a.provider_other_npi as other,
		provider_type_nch = null,
		provider_tin = null,
		provider_zip_rendering = null,
		provider_zip_billing = null,
		a.provider_attending_specialty as provider_specialty_attending,
		a.provider_operating_specialty as provider_specialty_operating,
		a.provider_other_specialty as provider_specialty_other,
		a.provider_referring_specialty as provider_specialty_referring,
		case
			when a.provider_rendering_npi is not null then a.provider_rendering_specialty
			when len(b.provider_rendering_npi) = 10 then b.provider_rendering_specialty
			else null
		end as provider_specialty_rendering
		from PHClaims.stage.mcare_outpatient_base_claims as a
		left join PHClaims.stage.mcare_outpatient_revenue_center as b
		on a.claim_header_id = b.claim_header_id
		--exclude denined claims using carrier/dme claim method
		where (a.denial_code_facility = '' or a.denial_code_facility is null)
	) as x6

	--reshape from wide to long
	unpivot(providers for provider_type in (
		billing,
		referring,
		site_of_service,
		rendering,
		attending,
		operating,
		other)
	) as providers
	where len(providers) = 10 and isnumeric(providers) = 1


	--snf
	union
	select id_mcare,
		claim_header_id,
		first_service_date,
		last_service_date,
		--original diagnosis code
		cast(providers as bigint) as 'provider_npi',
		--procedure code number/type
		cast(provider_type as varchar(200)) as 'provider_type',
		--other provider information
		provider_type_nch,
		provider_tin,
		--temporary provider zip and specialty columns for further processing
		provider_zip_rendering,
		provider_zip_billing,
		provider_specialty_attending,
		provider_specialty_operating,
		provider_specialty_other,
		provider_specialty_referring,
		provider_specialty_rendering,
		filetype_mcare,
		getdate() as last_run

	from (
		select
		top 100
		rtrim(a.id_mcare) as id_mcare,
		rtrim(a.claim_header_id) as claim_header_id,
		a.first_service_date,
		a.last_service_date,
		'snf' as filetype_mcare,
		a.provider_org_npi as billing,
		referring = null,
		care_plan_oversight = null,
		site_of_service = null,
		a.provider_rendering_npi as rendering,
		organization = null,
		a.provider_attending_npi as attending,
		a.provider_operating_npi as operating,
		a.provider_other_npi as other,
		provider_type_nch = null,
		provider_tin = null,
		provider_zip_rendering = null,
		provider_zip_billing = null,
		a.provider_attending_specialty as provider_specialty_attending,
		a.provider_operating_specialty as provider_specialty_operating,
		a.provider_other_specialty as provider_specialty_other,
		provider_specialty_referring = null,
		a.provider_rendering_specialty as provider_specialty_rendering
		from PHClaims.stage.mcare_snf_base_claims as a
		left join PHClaims.stage.mcare_snf_revenue_center as b
		on a.claim_header_id = b.claim_header_id
		--exclude denined claims using carrier/dme claim method
		where (a.denial_code_facility = '' or a.denial_code_facility is null)
	) as x7
	
	--reshape from wide to long
	unpivot(providers for provider_type in (
		billing,
		rendering,
		attending,
		operating,
		other)
	) as providers
	where len(providers) = 10 and isnumeric(providers) = 1

) as z
--exclude claims among people who have no eligibility data
left join PHClaims.final.mcare_elig_demo as w
on z.id_mcare = w.id_mcare
where w.id_mcare is not null;