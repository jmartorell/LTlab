#!/bin/bash
# testes-tc.sh
# Short test for Spanish grammar
# Copyright (C) 2011 Juan Martorell
#

_help()
{
  echo "$0 {set}"
  echo
  echo '  where {set} is one file of text/ or'
  echo '       all: Test all sets'
  echo '       cmp [timing]: Compare current and previous logs [including timing]'
  exit
}

function process {
for file in $FILELIST
	{
		echo "Processing $file"
		java -jar ./dist/languagetool-commandline.jar --language es \
		--disable HUNSPELL_RULE,WHITESPACE_RULE,UNPAIRED_BRACKETS,COMMA_PARENTHESIS_WHITESPACE,DOUBLE_PUNCTUATION \
		 $file >$file.log	
	}
}

function process_falsefriends {
for file in $FILELIST_FF
	{
		echo "Processing falsefriends $file"
		java -jar ./dist/languagetool-commandline.jar --language ${file:22:2} --mothertongue ${file:25:2} \
		--disable HUNSPELL_RULE,WHITESPACE_RULE,UNPAIRED_BRACKETS,COMMA_PARENTHESIS_WHITESPACE,DOUBLE_PUNCTUATION \
		 $file >$file.log	
	}
}

function process_segmentation {
for file in $FILELIST_SEG
	{
		echo "Processing segmentation $file"
		java -jar ./dist/languagetool-commandline.jar --language es \
                --disable HUNSPELL_RULE \
        $file >$file.log	
	}
}

function process_dual {
for file in $FILELIST_DUAL
	{
		echo "Processing dual   $file"
		java -jar ./dist/languagetool-commandline.jar --language es \
		--disable HUNSPELL_RULE,WHITESPACE_RULE,UNPAIRED_BRACKETS,COMMA_PARENTHESIS_WHITESPACE,DOUBLE_PUNCTUATION \
		 $file >$file.log	
	}
}

function process_single {
for file in $FILELIST_SINGLE
	{
		echo "Processing single $file"
		java -jar ./dist/languagetool-commandline.jar --language es \
		--disable HUNSPELL_RULE,WHITESPACE_RULE,UNPAIRED_BRACKETS,COMMA_PARENTHESIS_WHITESPACE,DOUBLE_PUNCTUATION \
		 $file >$file.log	
	}
}

function compare {
for file in $FILELIST
	{
		echo "Processing $file ------------------"
        if [ "$1" == "timing" ];then
			diff -uN "logs/`echo $file | sed 's:texts/::'`".log $file.log
		else
			diff -uNI sentences/sec "logs/`echo $file | sed 's:texts/::'`".log $file.log
		fi
	}
}

if [ -z "$1" ]; then
  _help
elif [ "$1" == "falsosamigos" ]; then
  FILELIST_FF=`ls -rS texts/tc-falsosamigos-??-??.txt`
  process_falsefriends
elif [ "$1" == "segmentation" ]; then
  FILELIST_SEG=`ls -rS texts/tc-segmentation.txt`
  process_segmentation
elif [ -f texts/tc-$1-ok.txt ]; then
  FILELIST_DUAL=`ls -rS texts/tc-$1-??.txt`
  process_dual
elif [ -f texts/tc-$1.txt ]; then
  FILELIST_SINGLE=`ls -rS texts/tc-$1.txt`
  process_single
elif [ "$1" == "all" ]; then
  FILELIST_FF=`ls texts/tc-falsosamigos.txt`
  FILELIST_SEG=`ls texts/tc-segmentation.txt`
  FILELIST_DUAL=`ls texts/tc-*-??.txt`
  #pat="ls texts/tc-!(falsosamigos|segmentation|*-??).txt"
  FILELIST_SINGLE=`ls texts/tc-*.txt | grep -v "ok\|ko\|falsosamigos\|segmentation"`
  #echo $FILELIST_SINGLE
  process_falsefriends
  process_segmentation
  process_dual
  process_single
elif [ "$1" == "cmp" ]; then
  FILELIST=`ls -rS texts/tc-*.txt`
  compare $2
elif [ "$1" == "--help" ]; then
  _help
else
  echo "** $1 is not a valid option."
  echo
  _help
fi
exit
