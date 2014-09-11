#!/usr/bin/gawk -f
# splitfreq.awk
# Extract unrecognized word frequency category from freq.log file
# Copyright (C) 2014 Juan Martorell
#

BEGIN {
	n_mente = 0;
	n_prope = 0;
}

/^[0-9]+ .+mente/ {
	adv_mente[n_mente++] = $0;
	tot_adv_mente += $1;
	#print $0, tot_adv_mente
}

/^[0-9]+ [A-ZÁÉÍÓÚÜÑ].+/ {
	nombre_propio[n_prope++] = $0;
	tot_nombre_propio += $1;
}

END {
	
print "Adverbs in -mente suffix";
print "========================";
print "";
for ( i=0; i<= n_mente ; i++) {
	print adv_mente[i];
}

print "\n" tot_adv_mente " total";

print "Proper nouns";
print "============";
print "";
for ( i=0; i<= n_prope ; i++) {
	print nombre_propio[i];
}

print "\n" tot_nombre_propio " total";
}
