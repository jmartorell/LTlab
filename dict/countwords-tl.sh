#!/bin/bash
# countnullmatches-tl.sh
# Lists the words missed by the dictionary
# Copyright (C) 2014 Juan Martorell
#

function process {
	count = 0
for file in $FILELIST
	{
		#echo "Processing $file"
		wc -w $file	
	}
echo $count
}

FILELIST=`ls -rS ../texts/tl-*.txt`
process
exit
