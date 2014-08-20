#!/usr/bin/gawk -f
# split.awk
# LanguageTool dictionary dump splitter
# Copyright (C) 2014 Juan Martorell
#

BEGIN {
	i=0
}
{	
	if (match ($1, "^[aá].*")) {
		print $0 >"a.dmp";
	} else if (match ($1, "^[bc].*")) {
		print $0 >"bc.dmp";
	} else if (match ($1, "^[d].*")) {
		print $0 >"d.dmp";
	} else if (match ($1, "^[e].*")) {
		print $0 >"e.dmp";
	} else if (match ($1, "^[fghijkl].*")) {
		print $0 >"fghijkl.dmp";	
	} else if (match ($1, "^[mnop].*")) {
		print $0 >"mnop.dmp";
	} else if (match ($1, "^[qrs].*")) {
		print $0 >"qrs.dmp";
	} else if (match ($1, "^[tuvwxyz].*")) {
		print $0 >"tuvwxyz.dmp";									
	} else {
		print $0 >"Z.dmp";
	}
	#printf ("%s\r",i++);
}
END {
	print "done"
}

