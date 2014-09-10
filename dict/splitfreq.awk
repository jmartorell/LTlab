#!/usr/bin/gawk -f
# splitfreq.awk
# Extract unrecognized word frequency category from freq.log file
# Copyright (C) 2014 Juan Martorell
#

BEGIN {
	i=0;
	adv_mente[0]="";
}

/^[0-9]+ .+ticamente/ {
	adv_mente[$2] = $0;
	tot_adv_mente += $1;
	print $0, tot_adv_mente
	
}

END {
	
print "Adverbs in -mente suffix";
print "========================";
print "";
for (adv in adv_mente) {
	print adv_mente[adv];
}

print "\n" tot_adv_mente " total";

}
