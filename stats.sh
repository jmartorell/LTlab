#!/bin/bash
# logstats.sh
# Statistics analyzer for Spanish grammar
# Copyright (C) 2011 Juan Martorell
#

_help()
{
  echo "$0 logs|texts"
  echo
  echo '  Shows the last line of every log file in given directory'
  exit
}
function process {
for file in $FILELIST
	{
		echo $file
		echo `tail -1 $file`
	}
}

if [ -z "$1" ]; then
  _help
elif [ "$1" == "texts" ]; then
  FILELIST=`ls -S texts/*.log`
  process
elif [ "$1" == "logs" ]; then
  FILELIST=`ls -S logs/*.log`
  process
elif [ "$1" == "--help" ]; then
  _help
else
  echo "** $1 is not a valid option."
  echo
  _help
fi
exit
