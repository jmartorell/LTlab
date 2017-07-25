#!/bin/bash
# Runs the database dump for a list of wikimedia exports. Remove from
# the from line the unnecesary documents but keep the commented list to
# replace when needed.

# wikiquote wikibooks wikinews wikiversity wikivoyage wikisource wikipedia
for file in wikiquote wikibooks wikinews wikiversity wikivoyage wikisource wikipedia
do
    echo $file
    python3 mediawiki-catalog.py $file
done
