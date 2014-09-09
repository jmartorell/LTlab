#!/usr/bin/gawk -f
# countnullmatches.awk
# LanguageTool dictionary match checker
# Copyright (C) 2014 Juan Martorell
#

BEGIN {
	i=0;
	regex = "\\[[A-Za-z0-9áéíóúÁÉÍÓÚüÜñÑ]+/null,\\]";
}
{	
	after = $0;
	while (match (after, regex) ) {
		#print after
		#print RSTART, RLENGTH;
		print substr(after, RSTART +1 , RLENGTH - 8);
		after = substr(after, RSTART + RLENGTH);
		i++;
	} 
}
END {
	#print i " found with " regex
}

