--Export results as dictionary dump ready for dictikonary.sh build and synth
select word, lemma, pos
from
    (select dictionary.tags.word, dictionary.tags.lemma, dictionary.tags.pos
        from dictionary.tags
            union
    select productions.synth.word, productions.synth.lemma, productions.synth.pos
        from productions.synth)
order by word asc, lemma asc, pos asc