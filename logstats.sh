#!/bin/bash
# logstats.sh
# Statistics analyzer for Spanish grammar
# Copyright (C) 2011 Juan Martorell
#

function process {
for file in $FILELIST
	{
		echo $file
		echo `tail -1 $file`
	}
}

FILELIST=`ls -S logs/*.log`
process
exit
