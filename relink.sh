#!/bin/bash
# Refreshes link to distributed version of LT.
# languagetool link need to be present
rm dist
rm languagetool-wikipedia.jar
ln -s languagetool/languagetool-standalone/target/LanguageTool-*/* dist
ln -s languagetool/languagetool-wikipedia/target/LanguageTool*/LanguageTool*/languagetool-wikipedia.jar
