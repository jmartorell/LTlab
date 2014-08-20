#!/bin/bash
# Refreshes link to distributed version of LT.
# languagetool link need to be present
rm dist
ln -s languagetool/languagetool-standalone/target/LanguageTool-*/* dist
