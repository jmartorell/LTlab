-- crea_ddl.sql
-- creates the table and prepares the input
DROP TABLE IF EXISTS crea;

CREATE TABLE crea (word TEXT PRIMARY KEY, ocurrences INTEGER, frequency REAL); 
.separator "\t" 
.import /dev/stdin crea 
