#!/bin/bash
# dictionary.sh
# LanguageTool dictionary manager
# Copyright (C) 2014 Juan Martorell
#

_help()
{
  echo "$0 {command}"
  echo
  echo '  where {command} is'
  echo '       export: Creates a dictionary in current location from the one in the workspace'
  echo '       build: creates a dict file based on the exported'
  echo '       synth: creates a synth dict file based on the exported'
  echo ' '
  echo '  This script relies on soft links from the upper directory. Ensure relink.sh was ran.'
  exit
}

# usage: org.languagetool.tools.DictionaryExporter
#  -i <arg>      binary Morfologik dictionary file (.dict)
#  -info <arg>   *.info properties file, see
#                http://wiki.languagetool.org/developing-a-tagger-dictionary
#  -o <arg>      output file
function dict_export {
  java -cp ../languagetool-tools.jar org.languagetool.tools.DictionaryExporter \
  -i ../languagetool/languagetool-language-modules/es/src/main/resources/org/languagetool/resource/es/spanish.dict \
  --info ../languagetool/languagetool-language-modules/es/src/main/resources/org/languagetool/resource/es/spanish.info \
  -o dictionary.dump
}

# usage: org.languagetool.tools.POSDictionaryBuilder
#  -freq <arg>   optional .xml file with a frequency wordlist, see
#                http://wiki.languagetool.org/developing-a-tagger-dictionary
# -i <arg>      tab-separated plain-text dictionary file with format:
#                wordform<tab>lemma<tab>postag
#  -info <arg>   *.info properties file, see
#                http://wiki.languagetool.org/developing-a-tagger-dictionary
#  -o <arg>      output file
function dict_build {
  java -cp ../languagetool-tools.jar org.languagetool.tools.POSDictionaryBuilder \
  -i dictionary.dump \
  --info ../dist/org/languagetool/resource/es/spanish.info \
  -o ../dist/org/languagetool/resource/es/spanish.dict
#  -freq freq.xml
}

# usage: org.languagetool.tools.SynthDictionaryBuilder
#  -i <arg>      tab-separated plain-text dictionary file with format:
#                wordform<tab>lemma<tab>postag
#  -info <arg>   *.info properties file, see
#                http://wiki.languagetool.org/developing-a-tagger-dictionary
#  -o <arg>      output file
function synth_dict_build {
  java -cp ../languagetool-tools.jar org.languagetool.tools.SynthDictionaryBuilder \
  -i dictionary.dump \
  --info ../dist/org/languagetool/resource/es/spanish_synth.info \
  -o ../dist/org/languagetool/resource/es/spanish_synth.dict
}


function dict_export_old {
  java -cp ../dist/languagetool.jar org.languagetool.dev.DictionaryExporter \
  ../languagetool/languagetool-language-modules/es/src/main/resources/org/languagetool/resource/es/spanish.dict >dictionary.dump
}

function dict_build_old {
  java -cp ../dist/languagetool.jar org.languagetool.tools.POSDictionaryBuilder \
  dictionary.dump ../dist/org/languagetool/resource/es/spanish.info
}

function synth_dict_build_old {
  java -cp ../dist/languagetool.jar org.languagetool.tools.SynthDictionaryBuilder \
  dictionary.dump ../dist/org/languagetool/resource/es/spanish_synth.info
}

if [ -z "$1" ]; then
  _help
elif [ "$1" == "export" ]; then
  dict_export
elif [ "$1" == "build" ]; then
  dict_build
elif [ "$1" == "synth" ]; then
  synth_dict_build  
elif [ "$1" == "--help" ]; then
  _help
else
  echo "** $1 is not a valid option."
  echo
  _help
fi
exit
