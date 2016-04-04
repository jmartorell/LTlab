#!/bin/bash
# Refreshes link to distributed version of LT.
# languagetool link need to be present

ln -sf languagetool/languagetool-standalone/target/LanguageTool-*/* dist
ln -sf languagetool/languagetool-wikipedia/target/LanguageTool*/LanguageTool*/languagetool-wikipedia.jar

cd languagetool/languagetool-wikipedia/target/LanguageTool*/LanguageTool*/org/languagetool/rules
rm -rf es
ln -sf ../../../../../../../languagetool-standalone/target/LanguageTool*/LanguageTool*/org/languagetool/rules/es
cd ../resource
rm -rf es
ln -sf ../../../../../../../languagetool-standalone/target/LanguageTool*/LanguageTool*/org/languagetool/resource/es
