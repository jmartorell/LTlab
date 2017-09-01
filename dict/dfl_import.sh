#!/bin/bash
# Imports DFL dictionary into the catalog database
iconv -f ISO-8859-1 -t UTF-8 ../texts/DFL.DBF.txt | tail -n+2 | awk '{print $1"\t"$2}' | sqlite3 catalog.sqlite '.read dfl_ddl.sql'
