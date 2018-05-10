-- Code to create an overall record of a person's Medicaid eligibility for each RAC code, and coverage group information as well
-- Alastair Matheson (PHSKC-APDE)
-- 2017-05
	--updated 2018-02-12 to account for sub-month coverage
	--updated 2018-05-10 by Eli to merge in coverage group code

-- Code collapses data from 1+ rows per person per month to a single row of contiguous coverage per person per RAC
-- Takes ~4m to run

--------------
--step 1: create RAC temp table - 1 row of contiguous coverage per person per RAC
--------------

-- Remove existing table
if object_id('tempdb..#mcaid_elig_rac') IS NOT NULL 
	drop table #mcaid_elig_rac

-- Collapse to single row again
SELECT h.id,
	h.rac_code,
	MIN(h.from_date) AS from_date,
	MAX(h.to_date) AS to_date,
	DATEDIFF(dd, MIN(h.from_date), MAX(h.to_date)) + 1 AS cov_time_day

INTO #mcaid_elig_rac

FROM (
	-- Set up groups where there is contiguous coverage
	SELECT g.id,
		g.rac_code,
		g.from_date,
		g.to_date,
		g.group_num,
		g.group_num2,
		SUM(CASE WHEN g.group_num2 IS NULL THEN 0 ELSE 1 END) OVER
			(ORDER BY g.temp_row ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS group_num3
	FROM (
		-- Set up flag for when there is a break in coverage
		SELECT f.id,
			f.rac_code,
			f.group_num,
			CASE 
				WHEN f.from_date - lag(f.to_date) OVER (PARTITION BY f.id, f.rac_code ORDER BY f.id, f.from_date) <= 1 THEN NULL
				ELSE ROW_NUMBER() OVER (PARTITION BY f.id, f.rac_code ORDER BY f.from_date)
				END AS group_num2,
			ROW_NUMBER() OVER (ORDER BY f.id, f.rac_code, f.from_date, f.to_date) AS temp_row,
			f.from_date,
			f.to_date			
		FROM (
			-- Use the from and to date info to find sub-month coverage
			SELECT e.id,
				e.rac_code,
				e.group_num,
				CASE 
					WHEN e.startdate >= e.fromdate THEN e.startdate
					WHEN e.startdate < e.fromdate THEN e.fromdate
					ELSE NULL
					END AS from_date,
				CASE 
					WHEN e.enddate <= e.todate THEN e.enddate
					WHEN e.enddate > e.todate THEN e.todate
					ELSE NULL
					END AS to_date
			FROM (
				-- Now take the max and min of each ID/contiguous date combo to collapse to one row
				SELECT d.id,
					d.rac_code,	
					MIN(calmonth) AS startdate,
					DATEADD(day, - 1, DATEADD(month, 1, MAX(calmonth))) AS enddate,
					d.group_num,
					d.fromdate,
					d.todate
				FROM (
					-- Keep just the variables formed in the select statement below
					SELECT DISTINCT c.id,
						c.rac_code,
						c.calmonth,
						c.group_num,
						c.fromdate,
						c.todate
					FROM
						-- This sets assigns a contiguous set of months to the same group number per id and RAC code
						(
						SELECT DISTINCT b.id,
							b.rac_code,
							b.calmonth,
							DATEDIFF(MONTH, 0, calmonth) - 
								ROW_NUMBER() OVER (PARTITION BY b.id, b.rac_code ORDER BY calmonth) AS group_num,
							b.fromdate,
							b.todate
						FROM
							-- Start here by pulling out the row per month data and converting the row per month field into a date
							(
							SELECT DISTINCT a.MEDICAID_RECIPIENT_ID AS id,
								a.RAC_CODE as rac_code,
								CONVERT(DATETIME, a.CLNDR_YEAR_MNTH + '01', 112) AS calmonth,
								a.FROM_DATE AS fromdate,
								a.TO_DATE AS todate
							FROM 
							(SELECT * FROM
							[PHClaims].[dbo].[NewEligibility]) a
							) b
						) c
					) d
				GROUP BY d.id, d.rac_code, d.group_num, d.fromdate, d.todate
				) e
			) f
		) g
	) h
GROUP BY h.id, h.rac_code, h.group_num3
ORDER BY h.id, from_date, h.rac_code

--------------
--step 2: create RAC temp table - 1 row of contiguous coverage per person per RAC
--------------

use PHClaims
go

if object_id('dbo.mcaid_elig_covgrp', 'U') IS NOT NULL 
  drop table dbo.mcaid_elig_covgrp;

--create coverage group vars per EDMA's code
select distinct cast(x.id as varchar(255)) as 'id', cast(x.rac_code as varchar(255)) as 'rac_code', cast(x.from_date as date) as 'from_date', cast(x.to_date as date) as 'to_date',

--new adults (medicaid cn expansion adults + aem expansion adults)
case when x.rac_code in (1201,1217,1178,1181,1210) then 1 else 0 end as 'new_adult',

--apple health for kids
case when x.rac_code in (1029,1030,1031,1032,1033,1039,1040,1138,1139,1140,1141,1142,1202,1203,
1204,1205,1206,1207,1211,1212,1213,1052,1056,1059,1060,1179,1034,1036,
1037,1040) then 1 else 0 end as 'apple_kids',

--older adults (elderly persons)
case when x.rac_code in (1000,1001,1006,1007,1010,1011,1041,1043,1046,1048,1050,1065,1066,1071,
1072,1073,1074,1077,1082,1083,1084,1085,1086,1089,1090,1188,1104,1108,
1109,1119,1124,1125,1146,1148,1149,1174,1154,1155,1158,1190,1191,1192,
1214,1218,1222,1223,1226,1230,1231,1232,1236,1240,1241,1248,1249,1250,
1251,1256,1257,1260,1264,1265,1266,1004,1068,1069,1106,1152,1220,1228,
1238,1246,1262) then 1 else 0 end as 'older_adults',

--family (TANF) medical
case when x.rac_code in (1024,1026,1027,1028,1038,1103,1035,1038,1122,1123) then 1 else 0 end as 'family_med',

--family planning
case when x.rac_code in (1097,1098,1099,1100) then 1 else 0 end as 'family_planning',

--former foster care adults
case when x.rac_code in(1196) then 1 else 0 end as 'former_foster',

--foster care
case when x.rac_code in (1014,1015,1016,1017,1018,1019,1020,1021,1022,1023) then 1 else 0 end as 'foster',

--medicaid cn caretaker adults
case when x.rac_code in (1208,1197,1198,1054,1055,1058,1063,1064,1181) then 1 else 0 end as 'caretaker_adults',

--partial duals
case when x.rac_code in (1112,1113,1114,1115,1116,1117,1118) then 1 else 0 end as 'partial_duals',

--disabled
case when x.rac_code in (1002,1003,1008,1009,1012,1013,1044,1047,1049,1067,1075,1076,1081,1184,
1082,1085,1086,1087,1187,1091,1092,1189,1105,1110,1111,1120,1121,1126,
1127,1134,1137,1147,1150,1151,1175,1091,1156,1157,1160,1161,1162,1163,
1164,1165,1166,1167,1168,1156,1193,1194,1195,1215,1219,1224,1225,1227,
1233,1234,1235,1237,1242,1245,1252,1253,1254,1255,1258,1259,1261,1267,
1268,1269,1229,3199,1132,1005,1051,1176,1070,1107,1153,1169,1221,1229,
1239,1247,1263,1005,1070,1042,1094,1136,1135,1145,1216,1128,1170,1130,
1172,1045,1129,1171,1131,1173,1133) then 1 else 0 end as 'disabled',

--pregnant women's coverage
case when x.rac_code in (1095,1096,1101,1102,1199,1200,1209,1061,1053,1057,1177,1062,1180) then 1 else 0 end as 'pregnancy'

into PHClaims.dbo.mcaid_elig_covgrp
from #mcaid_elig_rac as x