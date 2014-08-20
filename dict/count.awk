#!/usr/bin/gawk -f
# count.awk
# LanguageTool word counter dump splitter
# Copyright (C) 2014 Juan Martorell
#

BEGIN {
	i=0
	initials="abcdefghijklmnopqrstuvwxyz"
	#count[""]=0
}
{
	initial=substr($1,1,1)
	#if (match(initial,"[a-z]")) {
		count[initial]++
	#} else {
	#	count["Z"]++
	#}
	#printf ("%s\r",i++);
}
END {
	for (initial in count) {
		print initial, count[initial];
	}
}

