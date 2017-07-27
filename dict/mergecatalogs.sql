-- mergecatalogs.sql
-- 
-- Merges catalog tables and dictionary
-- Needs SQLitestudio to work. Alternatively, modify to use ATTACH
-- Default database "dictionary". All catalog wiki databases need to be open.
-- Execute step by step all temporary tables and create table at the end.


-- Holds the data from wikiversity and wikivoyage, mimicking a FULL join

CREATE TEMPORARY TABLE versityvoyage AS SELECT *
                                          FROM ( -- Words in both databases
                                                   SELECT catalogwikiversity.productions.word,
                                                          catalogwikiversity.productions.ocurrences AS versity,
                                                          catalogwikivoyage.productions.ocurrences AS voyage
                                                     FROM catalogwikiversity.productions
                                                          INNER JOIN
                                                          catalogwikivoyage.productions USING (
                                                              word
                                                          )
                                                   UNION -- Words only in the first database
                                                   SELECT catalogwikiversity.productions.word,
                                                          catalogwikiversity.productions.ocurrences AS versity,
                                                          0 AS voyage
                                                     FROM catalogwikiversity.productions
                                                    WHERE catalogwikiversity.productions.word NOT IN (
                                                              SELECT word
                                                                FROM catalogwikivoyage.productions
                                                          )
                                                   UNION -- Words only in the second database
                                                   SELECT catalogwikivoyage.productions.word,
                                                          0 AS versity,
                                                          catalogwikivoyage.productions.ocurrences AS voyage
                                                     FROM catalogwikivoyage.productions
                                                    WHERE catalogwikivoyage.productions.word NOT IN (
                                                              SELECT word
                                                                FROM catalogwikiversity.productions
                                                          )
                                               );

select * from versityvoyage;
drop table versityvoyage;

-- Holds the data from wikiversity, wikivoyage and wikisource,
-- mimicking a FULL join between versityvoyage temporary table and wikisource table
CREATE TEMPORARY TABLE versityvoyagesource AS SELECT *
                                          FROM ( -- Words in both databases
                                                   SELECT versityvoyage.word,
                                                          versityvoyage.versity,
                                                          versityvoyage.voyage,
                                                          catalogwikisource.productions.ocurrences AS source
                                                     FROM versityvoyage
                                                          INNER JOIN
                                                          catalogwikisource.productions USING (
                                                              word
                                                          )
                                                   UNION -- Words only in the first database
                                                   SELECT versityvoyage.word,
                                                          versityvoyage.versity,
                                                          versityvoyage.voyage,
                                                          0 AS source
                                                     FROM versityvoyage
                                                    WHERE versityvoyage.word NOT IN (
                                                              SELECT word
                                                                FROM catalogwikisource.productions
                                                          )
                                                   UNION -- Words only in the second database
                                                   SELECT catalogwikisource.productions.word,
                                                          0 AS versity,
                                                          0 AS voyage,
                                                          catalogwikisource.productions.ocurrences as source
                                                     FROM catalogwikisource.productions
                                                    WHERE catalogwikisource.productions.word NOT IN (
                                                              SELECT word
                                                                FROM versityvoyage
                                                          )
                                               );

select * from versityvoyagesource;
drop table versityvoyagesource;

-- Holds the data from wikiversity, wikivoyage, wikisource and wikiquote,
-- mimicking a FULL join between versityvoyagesource temporary table and wikiquote table
CREATE TEMPORARY TABLE versityvoyagesourcequote AS SELECT *
                                          FROM ( -- Words in both databases
                                                   SELECT versityvoyagesource.word,
                                                          versityvoyagesource.versity,
                                                          versityvoyagesource.voyage,
                                                          versityvoyagesource.source,
                                                          catalogwikiquote.productions.ocurrences AS quote
                                                     FROM versityvoyagesource
                                                          INNER JOIN
                                                          catalogwikiquote.productions USING (
                                                              word
                                                          )
                                                   UNION -- Words only in the first database
                                                   SELECT versityvoyagesource.word,
                                                          versityvoyagesource.versity,
                                                          versityvoyagesource.voyage,
                                                          versityvoyagesource.source,
                                                          0 AS quote
                                                     FROM versityvoyagesource
                                                    WHERE versityvoyagesource.word NOT IN (
                                                              SELECT word
                                                                FROM catalogwikiquote.productions
                                                          )
                                                   UNION -- Words only in the second database
                                                   SELECT catalogwikiquote.productions.word,
                                                          0 AS versity,
                                                          0 AS voyage,
                                                          0 AS source,
                                                          catalogwikiquote.productions.ocurrences as quote
                                                     FROM catalogwikiquote.productions
                                                    WHERE catalogwikiquote.productions.word NOT IN (
                                                              SELECT word
                                                                FROM versityvoyagesource
                                                          )
                                               );
                                               
select * from versityvoyagesourcequote;
drop table versityvoyagesourcequote;

-- Holds the data from wikiversity, wikivoyage, wikisource, wikiquote and wikinews,
-- mimicking a FULL join between versityvoyagesourcequote temporary table and wikinews table
CREATE TEMPORARY TABLE versityvoyagesourcequotenews AS SELECT *
                                          FROM ( -- Words in both databases
                                                   SELECT versityvoyagesourcequote.word,
                                                          versityvoyagesourcequote.versity,
                                                          versityvoyagesourcequote.voyage,
                                                          versityvoyagesourcequote.source,
                                                          versityvoyagesourcequote.quote,
                                                          catalogwikinews.productions.ocurrences AS news
                                                     FROM versityvoyagesourcequote
                                                          INNER JOIN
                                                          catalogwikinews.productions USING (
                                                              word
                                                          )
                                                   UNION -- Words only in the first database
                                                   SELECT versityvoyagesourcequote.word,
                                                          versityvoyagesourcequote.versity,
                                                          versityvoyagesourcequote.voyage,
                                                          versityvoyagesourcequote.source,
                                                          versityvoyagesourcequote.quote,
                                                          0 AS news
                                                     FROM versityvoyagesourcequote
                                                    WHERE versityvoyagesourcequote.word NOT IN (
                                                              SELECT word
                                                                FROM catalogwikinews.productions
                                                          )
                                                   UNION -- Words only in the second database
                                                   SELECT catalogwikinews.productions.word,
                                                          0 AS versity,
                                                          0 AS voyage,
                                                          0 AS source,
                                                          0 AS quote,
                                                          catalogwikinews.productions.ocurrences as news
                                                     FROM catalogwikinews.productions
                                                    WHERE catalogwikinews.productions.word NOT IN (
                                                              SELECT word
                                                                FROM versityvoyagesourcequote
                                                          )
                                               );
                                               
select * from versityvoyagesourcequotenews;
drop table versityvoyagesourcequotenews;

-- Holds the data from wikiversity, wikivoyage, wikisource, wikiquote, wikinews and wikibooks,
-- mimicking a FULL join between versityvoyagesourcequotenews temporary table and wikibooks table
CREATE TEMPORARY TABLE versityvoyagesourcequotenewsbooks AS SELECT *
                                          FROM ( -- Words in both databases
                                                   SELECT versityvoyagesourcequotenews.word,
                                                          versityvoyagesourcequotenews.versity,
                                                          versityvoyagesourcequotenews.voyage,
                                                          versityvoyagesourcequotenews.source,
                                                          versityvoyagesourcequotenews.quote,
                                                          versityvoyagesourcequotenews.news,
                                                          catalogwikibooks.productions.ocurrences AS books
                                                     FROM versityvoyagesourcequotenews
                                                          INNER JOIN
                                                          catalogwikibooks.productions USING (
                                                              word
                                                          )
                                                   UNION -- Words only in the first database
                                                   SELECT versityvoyagesourcequotenews.word,
                                                          versityvoyagesourcequotenews.versity,
                                                          versityvoyagesourcequotenews.voyage,
                                                          versityvoyagesourcequotenews.source,
                                                          versityvoyagesourcequotenews.quote,
                                                          versityvoyagesourcequotenews.news,
                                                          0 AS books
                                                     FROM versityvoyagesourcequotenews
                                                    WHERE versityvoyagesourcequotenews.word NOT IN (
                                                              SELECT word
                                                                FROM catalogwikibooks.productions
                                                          )
                                                   UNION -- Words only in the second database
                                                   SELECT catalogwikibooks.productions.word,
                                                          0 AS versity,
                                                          0 AS voyage,
                                                          0 AS source,
                                                          0 AS quote,
                                                          0 AS news,
                                                          catalogwikibooks.productions.ocurrences as books
                                                     FROM catalogwikibooks.productions
                                                    WHERE catalogwikibooks.productions.word NOT IN (
                                                              SELECT word
                                                                FROM versityvoyagesourcequotenews
                                                          )
                                               );
                                               
select * from versityvoyagesourcequotenewsbooks;
drop table versityvoyagesourcequotenewsbooks;

-- Holds the data from wikiversity, wikivoyage, wikisource, wikiquote, wikinews, wikibooks and wikipedia,
-- mimicking a FULL join between versityvoyagesourcequotenews temporary table and wikibooks table
CREATE TEMPORARY TABLE versityvoyagesourcequotenewsbookspedia AS SELECT *
                                          FROM ( -- Words in both databases
                                                   SELECT versityvoyagesourcequotenewsbooks.word,
                                                          versityvoyagesourcequotenewsbooks.versity,
                                                          versityvoyagesourcequotenewsbooks.voyage,
                                                          versityvoyagesourcequotenewsbooks.source,
                                                          versityvoyagesourcequotenewsbooks.quote,
                                                          versityvoyagesourcequotenewsbooks.news,
                                                          versityvoyagesourcequotenewsbooks.books,
                                                          catalogwikipedia.productions.ocurrences AS pedia
                                                     FROM versityvoyagesourcequotenewsbooks
                                                          INNER JOIN
                                                          catalogwikipedia.productions USING (
                                                              word
                                                          )
                                                   UNION -- Words only in the first database
                                                   SELECT versityvoyagesourcequotenewsbooks.word,
                                                          versityvoyagesourcequotenewsbooks.versity,
                                                          versityvoyagesourcequotenewsbooks.voyage,
                                                          versityvoyagesourcequotenewsbooks.source,
                                                          versityvoyagesourcequotenewsbooks.quote,
                                                          versityvoyagesourcequotenewsbooks.news,
                                                          versityvoyagesourcequotenewsbooks.books,
                                                          0 AS pedia
                                                     FROM versityvoyagesourcequotenewsbooks
                                                    WHERE versityvoyagesourcequotenewsbooks.word NOT IN (
                                                              SELECT word
                                                                FROM catalogwikipedia.productions
                                                          )
                                                   UNION -- Words only in the second database
                                                   SELECT catalogwikipedia.productions.word,
                                                          0 AS versity,
                                                          0 AS voyage,
                                                          0 AS source,
                                                          0 AS quote,
                                                          0 AS news,
                                                          0 AS books,
                                                          catalogwikipedia.productions.ocurrences as pedia
                                                     FROM catalogwikipedia.productions
                                                    WHERE catalogwikipedia.productions.word NOT IN (
                                                              SELECT word
                                                                FROM versityvoyagesourcequotenews
                                                          )
                                               );
                                               
select * from versityvoyagesourcequotenewsbookspedia;
drop table versityvoyagesourcequotenewsbookspedia;

-- Finally a table with the words and their frequencies is added to the dictionary database,
-- rendering dictionary as the only database needed.

CREATE TABLE wikicatalog AS SELECT word,
                                   pedia,
                                   source,
                                   quote,
                                   news,
                                   books,
                                   versity,
                                   voyage
                              FROM versityvoyagesourcequotenewsbookspedia;


