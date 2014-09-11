#!/usr/bin/gawk -f
# nullmatchesfreq.awk
# Extract unrecognized word frequency from nullcount.log file
# Copyright (C) 2014 Juan Martorell
#

{
words[$0]++;
}

END {

print "unmatched word frequency in descending order";
print "============================================";
print "";

z = asorti(words, word_text);
n = asort(words, word_cnt);

	for (i = z; i >= 1; i--) {
		for (j = 1; j <= z; j++) {
			if (words[word_text[j]] == word_cnt[i] \
			    && printed[word_text[j]] != "ok") {
						printed[word_text[j]] = "ok";
						print words[word_text[j]] " " word_text[j];
				}
		}
	}

}
