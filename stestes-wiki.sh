#!/bin/bash
# stestes-tl.sh
# Wikimedia contents test for Spanish grammar
# Copyright (C) 2016 Juan Martorell
#

_help()
{
  echo "$0 {set}"
  echo
  echo '  where {set} is one of'
  echo '       eswikipedia|eswikisource|eswikinews|...: Test downloaded corpus'
  echo '       all: Test all mediawiki dumped pages-articles data'
  echo '       cmp [t]: Compare current and previous logs [including timing]'
  exit
}

function checkwiki {
	echo "Processing $1.xml"
	java -jar languagetool-wikipedia.jar check-data \
	--rule-properties wikipediadisabledrules.properties \
	--file texts/$1.xml \
	--language es \
	  | tee logs/$1.xml.log | gawk -f stats.awk >logs/$1.xml.s.log
}

function compare {
for file in $FILELIST
	{
		echo "Processing $file ------------------"
        if [ "$1" == "t" ];then
			diff -u logs-old/$2.log logs-new/$2.log
		else
			diff -uI sentences/sec logs-old/$2.log logs-new/$2.log
		fi
	}
}

FILE_WIKIPEDIA=`basename texts/eswiki-*.xml .xml`
FILE_WIKISOURCE=`basename texts/eswikisource-*.xml .xml`

if [ -z "$1" ]; then
  _help
elif [ "$1" == "all" ]; then
  $FILES=`ls -b texts/eswiki*.xml`
  for filename in $FILES
  {
	  checkwiki `basename $filename`
  }
elif [ "$1" == "cmp" ]; then
  FILELIST=$2.xml
  compare $3
elif [ "$1" == "--help" ]; then
  _help
else
  FILE=texts/$1.xml
  if [ -e $FILE ]; then
    checkwiki $1
  else
    echo $FILE not found.
    _help
    exit 1
  fi
fi
exit
