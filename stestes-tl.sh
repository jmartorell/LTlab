#!/bin/bash
# testes-tl.sh
# Long test for Spanish grammar
# Copyright (C) 2010 Juan Martorell
#

_help()
{
  echo "$0 {level}"
  echo
  echo '  where {level} is one of'
  echo '       1: Test level 1 corpus: files prefixed with lt-1-'
  echo '       2: Test level 2 corpus: files prefixed with lt-2-'
  echo '       all: Test all levels'
  echo '       cmp [t]: Compare current and previous logs [including timing]'
  exit
}

function process {
for file in $FILELIST
	{
		echo "Processing $file"
		java -jar ./dist/languagetool-commandline.jar --language es \
		--disable HUNSPELL_RULE,WHITESPACE_RULE,UNPAIRED_BRACKETS,COMMA_PARENTHESIS_WHITESPACE,DOUBLE_PUNCTUATION \
		 $file | tee logs/${file:6}.log | gawk -f stats.awk >logs-new/${file:6}.s.log	
	}
}

function compare {
for file in $FILELIST
	{
		echo "Processing $file ------------------"
        if [ "$1" == "t" ];then
			diff -u logs-old/${file:6}.log logs-new/${file:6}.log
		else
			diff -uI sentences/sec logs-old/${file:6}.log logs-new/${file:6}.log
		fi
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
elif [ "$1" == "--help" ]; then
  _help
else
  echo "** $1 is not a valid option."
  echo
  _help
fi
exit
