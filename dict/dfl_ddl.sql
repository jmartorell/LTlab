-- dfl_ddl.sql
-- creates the table and prepares the input
DROP TABLE IF EXISTS dfl;

CREATE TABLE dfl (word TEXT PRIMARY KEY, ocurrences INTEGER); 
.separator "\t" 
.import /dev/stdin dfl
