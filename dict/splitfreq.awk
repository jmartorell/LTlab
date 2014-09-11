#!/usr/bin/gawk -f
# splitfreq.awk
# Extract unrecognized word frequency category from freq.log file
# Copyright (C) 2014 Juan Martorell
#

BEGIN {
	n_mente = 0;
	n_prope = 0;
	n_roman = 0;
}

{
	if ( $2 ~ /.+mente/) {
		adv_mente[n_mente++] = $0;
		tot_adv_mente += $1;

	} else if ( $2 ~ /\<[IVXLCQM]+\>/) {
		numero_romano[n_roman++] = $0;
		tot_numero_romano += $1;
		print $0		

	} else if ( $2 ~ /[A-ZÁÉÍÓÚÜÑ].+/) {
		nombre_propio[n_prope++] = $0;
		tot_nombre_propio += $1;		
	}
	
}

END {
	
print "Adverbs in -mente suffix";
print "========================";
print "";
for ( i=0; i<= n_mente ; i++) {
	print adv_mente[i];
}

print "\n" tot_adv_mente " total";

print "Roman numbers";
print "=============";
print "";
for ( i=0; i<= n_roman ; i++) {
	print numero_romano[i];
}

print "\n" tot_numero_romano " total";

print "Proper nouns";
print "============";
print "";
for ( i=0; i<= n_prope ; i++) {
	print nombre_propio[i];
}

print "\n" tot_nombre_propio " total";
}
