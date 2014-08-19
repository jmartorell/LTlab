#!/bin/bash
# testes-da.sh
# Long test for Spanish disambiguator
# Copyright (C) 2014 Juan Martorell
#

_help()
{
  echo "$0 {level}"
  echo
  echo '  where {level} is one of'
  echo '       1: Test level 1 corpus: files prefixed with lt-1-'
  echo '       2: Test level 2 corpus: files prefixed with lt-2-'
  echo '       all: Test all levels'
  echo '       cmp: Compare current and previous logs'
  echo '       sta: Counts rule application'
  exit
}

function process {
for file in $FILELIST
	{
		echo "Processing $file"
		java -jar ./dist/languagetool-commandline.jar --language es -v \
		--enable EN_BASE_A \
		 $file >/dev/null 2>$file.da.log	
	}
}

function compare {
for file in $FILELIST
	{
		echo "Processing $file ------------------"
		diff -u "logs/`echo $file | sed 's:texts/::'`".da.log $file.da.log
	}
}

function count {
RULELIST=(D_R_N DNA DAN NSN ANA D_AN P_V D_N)
for rule in ${RULELIST[@]}
	{
		echo -n "Rule ${rule}: "
		cat texts/*.da.log | grep ${rule} | wc -l
	}
}

if [ -z "$1" ]; then
  _help
elif [ "$1" == "1" ]; then
  FILELIST=`ls -rS texts/tl-1-*.txt`
  process
elif [ "$1" == "2" ]; then
  FILELIST=`ls -rS texts/tl-2-*.txt`
  process
elif [ "$1" == "all" ]; then
  FILELIST=`ls -rS texts/tl-?-*.txt`
  process
elif [ "$1" == "cmp" ]; then
  FILELIST=`ls -rS texts/tl-?-*.txt`
  compare $2
elif [ "$1" == "sta" ]; then
  FILELIST=`ls -rS texts/tl-?-*.txt`
  count
elif [ "$1" == "--help" ]; then
  _help
else
  echo "** $1 is not a valid option."
  echo
  _help
fi
exit
