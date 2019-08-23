
USE PHClaims;
GO

/* Table Definition */
IF OBJECT_ID('[ref].[pharm_rx_strength_xwalk]', 'U') IS NOT NULL
DROP TABLE [ref].[pharm_rx_strength_xwalk]
CREATE TABLE [ref].[pharm_rx_strength_xwalk]
([drug_label_name] VARCHAR(255) NOT NULL
,[drug_generic_short_name] VARCHAR(255) NOT NULL
,[drug_route_desc] VARCHAR(255) NOT NULL
,[drug_name_1] VARCHAR(255) NULL
,[drug_strength_1] NUMERIC(18,3) NULL
,[measure_unit_1] VARCHAR(20) NULL
,[drug_name_2] VARCHAR(255) NULL
,[drug_strength_2] NUMERIC(18,3) NULL
,[measure_unit_2] VARCHAR(20) NULL
,CONSTRAINT [PK_pharm_rx_strength_xwalk] PRIMARY KEY CLUSTERED([drug_label_name], [drug_generic_short_name], [drug_route_desc]))
ON [PRIMARY];
GO

WITH CTE AS
(
SELECT DISTINCT 
 [drug_label_name]
,[drug_generic_short_name]
,[drug_route_desc]
,CASE
WHEN [drug_generic_short_name] = 'HYDROCODONE/ACETAMINOPHEN' THEN 'HYDROCODONE/ACETAMINOPHEN'
END AS [drug_name]
,CASE 
WHEN [drug_label_name] LIKE '% 10 MG-300 MG/15 ML%' THEN '10|MG|300|MG'
WHEN [drug_label_name] LIKE '% 10-300%' THEN '10|MG|300|MG'
WHEN [drug_label_name] LIKE '% 10-300 MG%' THEN '10|MG|300|MG'
WHEN [drug_label_name] LIKE '% 10-325%' THEN '10|MG|325|MG'
WHEN [drug_label_name] LIKE '% 10-325 MG%' THEN '10|MG|325|MG'
WHEN [drug_label_name] LIKE '% 10-325 MG/15 ML%' THEN '10|MG|325|MG'
WHEN [drug_label_name] LIKE '% 10-325/15%' THEN '10|MG|325|MG'
WHEN [drug_label_name] LIKE '% 2.5-108/5%' THEN '2.5|MG|108|MG'
WHEN [drug_label_name] LIKE '% 2.5-167/5%' THEN '2.5|MG|167|MG'
WHEN [drug_label_name] LIKE '% 2.5-325%' THEN '2.5|MG|325|MG'
WHEN [drug_label_name] LIKE '% 2.5-325 MG%' THEN '2.5|MG|325|MG'
WHEN [drug_label_name] LIKE '% 5-163/7.5%' THEN '5|MG|163|MG'
WHEN [drug_label_name] LIKE '% 5-217/10%' THEN '5|MG|217|MG'
WHEN [drug_label_name] LIKE '% 5-300%' THEN '5|MG|300|MG'
WHEN [drug_label_name] LIKE '% 5-300 MG%' THEN '5|MG|300|MG'
WHEN [drug_label_name] LIKE '% 5-325%' THEN '5|MG|325|MG'
WHEN [drug_label_name] LIKE '% 5-325 MG%' THEN '5|MG|325|MG'
WHEN [drug_label_name] LIKE '% 7.5-300%' THEN '7.5|MG|300|MG'
WHEN [drug_label_name] LIKE '% 7.5-300 MG%' THEN '7.5|MG|300|MG'
WHEN [drug_label_name] LIKE '% 7.5-325%' THEN '7.5|MG|325|MG'
WHEN [drug_label_name] LIKE '% 7.5-325 MG%' THEN '7.5|MG|325|MG'
WHEN [drug_label_name] LIKE '% 7.5-325/15%' THEN '7.5|MG|325|MG'
/*
WHEN [drug_label_name] LIKE '% 10-200%' THEN '10|MG|200|MG'
WHEN [drug_label_name] LIKE '% 5-200 MG%' THEN '5|MG|200|MG'
WHEN [drug_label_name] LIKE '% 7.5-200%' THEN '7.5|MG|200|MG'
WHEN [drug_label_name] LIKE '% 1 MG/ML%' THEN '1|MG'
WHEN [drug_label_name] LIKE '% 2 MG%' THEN '2|MG'
WHEN [drug_label_name] LIKE '% 3 MG%' THEN '3|MG'
WHEN [drug_label_name] LIKE '% 4 MG%' THEN '4|MG'
WHEN [drug_label_name] LIKE '% 5 MG/5 ML%' THEN '5|MG'
WHEN [drug_label_name] LIKE '% 8 MG%' THEN '8|MG'
WHEN [drug_label_name] LIKE '% 12 MG%' THEN '12|MG'
*/
END AS [drug_strength_measure_unit]
FROM [ref].[bree_value_set]
WHERE [drug_generic_short_name] = 'HYDROCODONE/ACETAMINOPHEN'
--WHERE [drug_label_name] = 'HYDROCODON-ACETAMIN 7.5-325/15'
--ORDER BY [drug_generic_short_name]
),

[ref_drug_name] AS
(
SELECT
 [drug_name]
,[drug_name_1]
,[drug_name_2]
FROM
(VALUES
 ('HYDROCODONE/ACETAMINOPHEN', 'HYDROCODONE', 'ACETAMINOPHEN')) AS a
([drug_name]
,[drug_name_1]
,[drug_name_2])
),

[ref_drug_strength_measure_unit] AS
(
SELECT
 [drug_strength_measure_unit]
,[drug_strength_1]
,[measure_unit_1]
,[drug_strength_2]
,[measure_unit_2]
FROM
(VALUES
 ('10|MG|300|MG', 10, 'MG', 300, 'MG')
,('10|MG|300|MG', 10, 'MG', 300, 'MG')
,('10|MG|300|MG', 10, 'MG', 300, 'MG')
,('10|MG|325|MG', 10, 'MG', 325, 'MG')
,('10|MG|325|MG', 10, 'MG', 325, 'MG')
,('10|MG|325|MG', 10, 'MG', 325, 'MG')
,('10|MG|325|MG', 10, 'MG', 325, 'MG')
,('2.5|MG|108|MG', 2.5, 'MG', 108, 'MG')
,('2.5|MG|167|MG', 2.5, 'MG', 167, 'MG')
,('2.5|MG|325|MG', 2.5, 'MG', 325, 'MG')
,('2.5|MG|325|MG', 2.5, 'MG', 325, 'MG')
,('5|MG|163|MG', 5, 'MG', 163, 'MG')
,('5|MG|217|MG', 5, 'MG', 217, 'MG')
,('5|MG|300|MG', 5, 'MG', 300, 'MG')
,('5|MG|300|MG', 5, 'MG', 300, 'MG')
,('5|MG|325|MG', 5, 'MG', 325, 'MG')
,('5|MG|325|MG', 5, 'MG', 325, 'MG')
,('7.5|MG|300|MG', 7.5, 'MG', 300, 'MG')
,('7.5|MG|300|MG', 7.5, 'MG', 300, 'MG')
,('7.5|MG|325|MG', 7.5, 'MG', 325, 'MG')
,('7.5|MG|325|MG', 7.5, 'MG', 325, 'MG')
,('7.5|MG|325|MG', 7.5, 'MG', 325, 'MG')
,('10|MG|200|MG', 10, 'MG', 200, 'MG')
,('5|MG|200|MG', 5, 'MG', 200, 'MG')
,('7.5|MG|200|MG', 7.5, 'MG', 200, 'MG')
,('1|MG', 1, 'MG', NULL, 'NULL')
,('2|MG', 2, 'MG', NULL, 'NULL')
,('3|MG', 3, 'MG', NULL, 'NULL')
,('4|MG', 4, 'MG', NULL, 'NULL')
,('5|MG', 5, 'MG', NULL, 'NULL')
,('8|MG', 8, 'MG', NULL, 'NULL')
,('12|MG', 12, 'MG', NULL, 'NULL')) AS a
([drug_strength_measure_unit]
,[drug_strength_1]
,[measure_unit_1]
,[drug_strength_2]
,[measure_unit_2])
)

INSERT INTO [ref].[pharm_rx_strength_xwalk]
SELECT
 [drug_label_name]
,[drug_generic_short_name]
,[drug_route_desc]
,[drug_name_1]
,[drug_strength_1]
,[measure_unit_1]
,[drug_name_2]
,[drug_strength_2]
,[measure_unit_2]
FROM CTE AS a
LEFT JOIN [ref_drug_name] AS b
ON a.[drug_name] = b.[drug_name]
LEFT JOIN [ref_drug_strength_measure_unit] AS c
ON a.[drug_strength_measure_unit] = c.[drug_strength_measure_unit];

SELECT * FROM [ref].[pharm_rx_strength_xwalk];

SELECT * FROM [ref].[bree_value_set]
WHERE
 [drug_label_name] = 'ENDOCET 10-325 MG TABLET'
[drug_generic_short_name]'OXYCODONE HCL/ACETAMINOPHEN'
'ORAL'

/*
SELECT 
 a.[drug_label_name]
,a.[drug_generic_short_name]
,a.[drug_route_desc]
,SUM(CASE WHEN [drug_strength_1] IS NOT NULL THEN 1 ELSE 0 END) AS [num_value]
FROM [ref].[bree_value_set] AS a
LEFT JOIN [ref].[pharm_rx_strength_xwalk] AS b
ON a.[drug_label_name] = b.[drug_label_name]
AND a.[drug_generic_short_name] = b.[drug_generic_short_name]
AND a.[drug_route_desc] = b.[drug_route_desc]
WHERE [value_set_name] = 'Opioid-Include'
GROUP BY
 a.[drug_label_name]
,a.[drug_generic_short_name]
,a.[drug_route_desc]
ORDER BY [num_value] DESC;

SELECT DISTINCT
 a.[drug_label_name]
,a.[drug_generic_short_name]
,a.[drug_route_desc]
,[drug_name_1]
,[drug_strength_1]
,[measure_unit_1]
,[drug_name_2]
,[drug_strength_2]
,[measure_unit_2]
FROM [ref].[bree_value_set] AS a
LEFT JOIN [ref].[pharm_rx_strength_xwalk] AS b
ON a.[drug_label_name] = b.[drug_label_name]
AND a.[drug_generic_short_name] = b.[drug_generic_short_name]
AND a.[drug_route_desc] = b.[drug_route_desc]
WHERE [value_set_name] = 'Opioid-Include';
*/

