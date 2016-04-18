#!/bin/bash
# Refreshes link to distributed version of LT.
# languagetool link need to be present

STDALONE_SNAPSHOT=`basename languagetool/languagetool-standalone/target/LanguageTool-*`
WIKICHK_SNAPSHOT=`basename languagetool/languagetool-wikipedia/target/LanguageTool-*`
BASE_PWD=`pwd`

ln -sf languagetool/languagetool-standalone/target/$STDALONE_SNAPSHOT/$STDALONE_SNAPSHOT dist
ln -sf languagetool/languagetool-tools/target/languagetool-tools-*-with-dependencies.jar languagetool-tools.jar

# Link target XML rule files to LanguageTool source directory so the XXE internal link works

cd languagetool/languagetool-language-modules/es/src/main/resources/org/languagetool/rules/es
ln -sf ../../../../../../../../../languagetool-standalone/target/$STDALONE_SNAPSHOT/$STDALONE_SNAPSHOT/org/languagetool/rules/es/grammar.xml grammar.xml.target~
cd ../../resource/es
ln -sf ../../../../../../../../../languagetool-standalone/target/$STDALONE_SNAPSHOT/$STDALONE_SNAPSHOT/org/languagetool/resource/es/disambiguation.xml disambiguation.xml.target~

cd $BASE_PWD

# Link resources at Wikipedia to distribution

ln -sf languagetool/languagetool-wikipedia/target/$WIKICHK_SNAPSHOT/$WIKICHK_SNAPSHOT/languagetool-wikipedia.jar

cd languagetool/languagetool-wikipedia/target/$WIKICHK_SNAPSHOT/$WIKICHK_SNAPSHOT/org/languagetool/rules
rm -rf es
ln -sf ../../../../../../../languagetool-standalone/target/$STDALONE_SNAPSHOT/$STDALONE_SNAPSHOT/org/languagetool/rules/es
cd ../resource
rm -rf es
ln -sf ../../../../../../../languagetool-standalone/target/$STDALONE_SNAPSHOT/$STDALONE_SNAPSHOT/org/languagetool/resource/es
