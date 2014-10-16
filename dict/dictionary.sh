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
  exit
}

function dict_export {
  java -cp ../dist/languagetool.jar org.languagetool.dev.DictionaryExporter \
  ../languagetool/languagetool-language-modules/es/src/main/resources/org/languagetool/resource/es/spanish.dict >dictionary.dump
}

function dict_build {
  java -cp ../dist/languagetool.jar org.languagetool.dev.POSDictionaryBuilder \
  dictionary.dump ../dist/org/languagetool/resource/es/spanish.info
}

function synth_dict_build {
  java -cp ../dist/languagetool.jar org.languagetool.dev.SynthDictionaryBuilder \
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
