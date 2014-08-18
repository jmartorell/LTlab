#!/bin/bash
# meld program required.
# Opens meld with preconfigured comparisons
meld -L LanguageTool \
--diff languagetool/languagetool-language-modules/es/src/main/resources/org/languagetool/rules/es dist/org/languagetool/rules/es \
--diff logs texts \
