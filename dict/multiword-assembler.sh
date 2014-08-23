#!/bin/bash
# multiword-assembler.sh
# LanguageTool multiword assembler bash command
# Copyright (C) 2014 Juan Martorell

export LC_COLLATE=C
cat ortografia\ española\ EAGLE/lista\ ??-*.txt | awk -f multiword.awk \
| sort -o multiwords.txt

