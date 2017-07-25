#!/bin/bash
# spelldict.sh
# LanguageTool spell dictionary manager
# Copyright (C) 2017 Juan Martorell
#

_help()
{
  echo "$0 {command}"
  echo
  echo '  where {command} is'
  echo '       export: Dumps the hunspell dictionary to text file spelldict.dump'
  echo '       build: creates a LT dict file based on the text dump'
  echo '       all: performs both actions'
  echo ' '
  echo '  This script relies on soft links from the upper and current directory.'
  echo '  Ensure relink.sh was ran.'
  exit
}

function dict_export {
	unmunch losc/es_ANY.dic losc/es_ANY.aff | grep -v "^#" > spelldict.dump
	#| hunspell -d es_ES -G -l > dict.dump
}

# usage: org.languagetool.tools.SpellDictionaryBuilder
#  -freq <arg>   optional .xml file with a frequency wordlist, see
# 			   http://wiki.languagetool.org/developing-a-tagger-dictionary
#  -i <arg>      plain text dictionary file, e.g. created from a Hunspell
# 			   dictionary by 'unmunch'
#  -info <arg>   *.info properties file, see
# 			   http://wiki.languagetool.org/developing-a-tagger-dictionary
#  -o <arg>      output file
function dict_build {
java -cp ../languagetool-tools.jar org.languagetool.tools.SpellDictionaryBuilder \
  -i spelldict.dump \
  -info ../dist/org/languagetool/resource/es/hunspell/es_ES.info \
  -o es_ES.dict
}

if [ -z "$1" ]; then
  _help
  dict_export
  dict_build
elif [ "$1" == "export" ]; then
  dict_export
elif [ "$1" == "build" ]; then
  dict_build
elif [ "$1" == "all" ]; then
  dict_export
  dict_build
elif [ "$1" == "--help" ]; then
  _help
else
  echo "** $1 is not a valid option."
  echo
  _help
fi
exit
