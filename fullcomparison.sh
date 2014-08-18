#!/bin/bash
./testes-tc.sh all 
./testes-tc.sh cmp > /tmp/tmp.diff 
./testes-tl.sh all
./testes-tl.sh cmp >> /tmp/tmp.diff
