use phclaims
go
select s.Name AS schema_name, t.NAME AS table_name, 
	max(p.rows) AS row_count, --I'm taking max here because an index that is not on all rows creates two entries in this summary table
    max(p.rows)/1000000 as row_count_million,
	count(c.COLUMN_NAME) as col_count,
    cast(round(((sum(a.used_pages) * 8) / 1024.00), 2) as numeric(36, 2)) as used_space_mb, 
	    cast(round(((sum(a.used_pages) * 8) / 1024.00 / 1024.00), 2) as numeric(36, 2)) as used_space_gb
from sys.tables t
inner join sys.indexes i on t.OBJECT_ID = i.object_id
inner join sys.partitions p on i.object_id = p.OBJECT_ID and i.index_id = p.index_id
inner join sys.allocation_units a on p.partition_id = a.container_id
left outer join sys.schemas s on t.schema_id = s.schema_id
left join information_schema.columns c on t.name = c.TABLE_NAME and s.name = c.TABLE_SCHEMA
where t.NAME NOT LIKE 'dt%' and t.is_ms_shipped = 0 and i.OBJECT_ID > 255
	and left(t.name, 4) = 'apcd' and s.name = 'load_raw'
group by s.Name, t.Name
order by table_name;