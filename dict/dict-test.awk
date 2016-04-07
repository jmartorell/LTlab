#!/usr/bin/gawk -f
# dict-test.awk
# LanguageTool's Morfologik dictionary integrity test
# Copyright (C) 2016 Marcin Milkowsky & Juan Martorell
#

BEGIN {FS="\t"}
{line_number++
if (NF!=3)
	{print "Bad number of fields: " NF " in the line " line_number ": " $0
	 exit_code =1
	}
}
END {exit (exit_code)}
