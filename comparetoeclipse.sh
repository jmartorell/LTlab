#!/bin/bash
# Diff for grammar.xml and disambiguation.xml in both dist and dev dirs
SRC=./dist/org/languagetool
DST=./languagetool/languagetool-language-modules/es/src/main/resources/org/languagetool

diff $1 $2 $DST/rules/es/grammar.xml $SRC/rules/es/grammar.xml
diff $1 $2 $DST/resource/es/disambiguation.xml $SRC/resource/es/disambiguation.xml
