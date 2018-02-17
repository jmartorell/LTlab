--
-- File generated with SQLiteStudio v3.1.1 on Sat Feb 17 13:51:21 2018
--
-- Text encoding used: UTF-8
--
PRAGMA foreign_keys = off;
BEGIN TRANSACTION;

-- Table: synth
CREATE TABLE synth (
    word    STRING,
    lemma   STRING,
    pos     STRING,
    spell   BOOLEAN,
    lt      BOOLEAN,
    crea    INTEGER,
    dfl     INTEGER,
    pedia   INTEGER,
    source  INTEGER,
    quote   INTEGER,
    news    INTEGER,
    books   INTEGER,
    versity INTEGER,
    voyage  INTEGER,
    tatoeba INTEGER
);


COMMIT TRANSACTION;
PRAGMA foreign_keys = on;
