#!/usr/bin/gawk -f
# multiword.awk
# LanguageTool multiword assembler
# Copyright (C) 2014 Juan Martorell
#
BEGIN {
	print "# Spanish multiwords file used for chunking"
}

{
	if (match ($1, ".+_.+")) {
		# Concilio Vaticano II
		gsub(/ii/,"II",$1);
		gsub(/_/," ",$1);
		rest = substr($1,2)  "\tL_"  $2;
		#print $1 "\tL_" $2;
		print substr($1,1,1) rest;
		print toupper(substr($1,1,1)) rest;
	}
}
	
