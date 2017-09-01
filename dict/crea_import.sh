#!/bin/bash
# Imports CREA dictionary into the catalog database
iconv -f ISO-8859-1 -t UTF-8 ../texts/CREA_total.TXT | tail -n+2 | awk '{gsub(",","",$3);print $2"\t"$3"\t"$4}' | sqlite3 catalog.sqlite '.read crea_ddl.sql'
