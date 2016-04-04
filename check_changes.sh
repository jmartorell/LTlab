#!/bin/bash
# Checks for changes in rule files so it is easier to compare files and copy working rules to official LT ruleset.
# Working copy ruleset location
SRC=./dist/org/languagetool
# Official ruleset location
DST=./languagetool/languagetool-language-modules/es/src/main/resources/org/languagetool

diff $1 $2 $DST/rules/es/grammar.xml $SRC/rules/es/grammar.xml
diff $1 $2 $DST/resource/es/disambiguation.xml $SRC/resource/es/disambiguation.xml
diff $1 $2 $DST/resource/es/confusion_sets.txt $SRC/resource/es/confusion_sets.txt
diff $1 $2 $DST/resource/es/multiwords.txt $SRC/resource/es/multiwords.txt

