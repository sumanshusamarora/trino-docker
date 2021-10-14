# trino-docker
Trino Docker

```sql
Select * FROM
mongodblocal.testdb.user AS A
LEFT JOIN mlai_doc_app.schema.table B
On A.name = B.name
```
