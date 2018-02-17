# Copyright (C) 2017 Juan Martorell
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301
# USA

"""
Prodgen -- production generator
Generates productions starting from gen.synth

Every line, not comment (#) has:

<POS> <removal suffix> <addition suffix> <resulting POS>

"""

source_query = """ SELECT """

import sqlite3
import codecs
import time
import sys
import os
import re

# source_cursor = conn.cursor()
cmp_query ="""SELECT DISTINCT
				t.word, t.lemma, t.pos,
				c.crea, c.dfl,
				c.wikipedia, c.wikisource, c.wikiquote, c.wikinews, c.wikibooks, c.wikiversity, c.wikivoyage,
				c.tatoeba,
                s.word AS spell, tags.word AS tags
        FROM tmp_synth t LEFT JOIN catalog c USING(word)
        LEFT JOIN spell s USING(word)
        LEFT JOIN tags USING (word)"""

re_vowel = re.compile("[aeiouáéíóúü]")
re_vowel_flat = re.compile("[aeiouü]")
re_vowel_accent = re.compile(".*[áéíóú].*")


def is_weak_vowel(vowel):

    return vowel in ("e", "i", "é", "í")


def acute(vowel):
    if vowel == "a":
        return "á"
    elif vowel == "e":
        return "é"
    elif vowel == "i":
        return "í"
    elif vowel == "o":
        return "ó"
    elif vowel == "u":
        return "ú"
    else:
        return "not vowel"


def insert_acute(word, position):
    if position == 0:
        return acute(word[0]) + word[1:]
    elif position == len(word) - 1:
        return word[0:position] + acute(word[position])
    else:
        return word[0:position] + acute(word[position]) + word[position + 1:]


def forthtonic(word, extras):
    length = len(word)
    count = int(extras)
    # with an accented vowel, return untouched
    if re_vowel_accent.match(word):
        return word

    serie = []
    previous = False
    total_vowels = 0
    vowels = []
    for i in range(0, length):
        if re_vowel_flat.match(word[i]):
            if previous and word[i] == "u":
                serie.append(0)
            else:
                serie.append(1)
                vowels.append(i)
                total_vowels += 1
        else:
            serie.append(0)
            previous = word[i] in ("q", "g")

    vowels.reverse()
    if total_vowels == 1:
        if count == 1:
            return word
        elif count == 2:
            return insert_acute(word, vowels[0])
    elif total_vowels > 1:
        return insert_acute(word, vowels[1])


def production(src_conn, dst_conn, conv, morph, chk, ort):

    chk_corpus = chk == "check"
    gen_pos = conv[0]  # conv[i] holds generated pos for i
    suffixes = []
    for trans in morph:
        sfx_tpl = []
        for sfx in trans:
            sfx_tpl.append(sfx[1:])
        suffixes.append(sfx_tpl)

    src_cursor = src_conn.cursor()
    cmp_cursor = src_conn.cursor()

    cmp_cursor.execute("CREATE TABLE IF NOT EXISTS tmp_synth (word TEXT, lemma TEXT, pos TEXT)")  # TEMPORARY
    src_cursor.executescript("DROP TABLE IF EXISTS tmp_tags;")
    src_cursor.execute("CREATE TABLE tmp_tags AS SELECT word, lemma FROM tags WHERE pos LIKE ?", [gen_pos])  # TEMPORARY
    src_conn.commit()
    src_query = "SELECT word, lemma FROM tmp_tags"
    for sfx in suffixes:
        start = time.time()
        gen_sfx = sfx[0]

        if gen_sfx == "":
            src_cursor.execute(src_query)
        else:
            src_cursor.execute(src_query + " WHERE word LIKE ?", ["%" + gen_sfx])

        cmp_cursor.executescript("DELETE FROM tmp_synth;")
        sfx_count = len(sfx)
        for row in src_cursor:
            lemma = row[1]
            root = row[0][:len(row[0]) - len(gen_sfx)]

            if ort == "tonic":
                root = root.replace("á", "a") \
                    .replace("é", "e") \
                    .replace("í", "i") \
                    .replace("ó", "o") \
                    .replace("ú", "u")
            elif ort[0:10] == "forthtonic":
                root = forthtonic(root, ort[11])

            for i in range(1, sfx_count):
                prod_pos = conv[i]
                prod_sfx = sfx[i]

                if root.endswith("c") and is_weak_vowel(prod_sfx[0]):
                    root = root[:len(root) - 1] + "qu"
                elif root.endswith("g") and is_weak_vowel(prod_sfx[0]):
                    root = root[:len(root) - 1] + "gu"
                elif root.endswith("z") and is_weak_vowel(prod_sfx[0]):
                    root = root[:len(root) - 1] + "c"

                word = root + prod_sfx
                cmp_cursor.execute("INSERT INTO tmp_synth VALUES (?,?,?)", [word, lemma, prod_pos])

        src_conn.commit()

        cmp_cursor.execute(cmp_query)

        for comparison in cmp_cursor:
            word = comparison[0]
            lemma = comparison[1]
            prod_pos = comparison[2]
            crea = int(comparison[3] or 0)
            dfl = int(comparison[4] or 0)
            pedia = int(comparison[5] or 0)
            source = int(comparison[6] or 0)
            quote = int(comparison[7] or 0)
            news = int(comparison[8] or 0)
            books = int(comparison[9] or 0)
            versity = int(comparison[10] or 0)
            voyage = int(comparison[11] or 0)
            tatoeba =  int(comparison[12] or 0)
            spell = int(0 if comparison[13] is None else 1)
            lt = int(0 if comparison[14] is None else 1)

            if not chk_corpus or (crea + dfl + pedia + source + quote + news + books + versity + voyage + tatoeba + lt + spell > 1):
                dst_conn.execute("INSERT INTO synth values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                                 [word, lemma, prod_pos, spell, lt, crea, dfl, pedia, source, quote, news, books, versity, voyage, tatoeba])

        # cmp_cursor.close()
        elapsed_time = time.time() - start

        print(sfx, int(elapsed_time) / 60, int(elapsed_time) % 60)
        dst_conn.commit()

    print(gen_pos, "-->",  conv)
    src_cursor.close()


def file_base():
    if len(sys.argv) == 1:
        print ("Using default gen.synth file")
        return "gen.synth"
    elif len(sys.argv) == 2:
        filename = sys.argv[1] + ".synth"
        if not os.path.isfile(filename):
            print("'%s': not found" % filename)
            return 1
        else:
            return filename
    else:
        print("Usage: %s <synth.file> " % sys.argv[0])
        return 12


def _main():
    src_conn = sqlite3.connect("dictionary.sqlite")
    dst_conn = sqlite3.connect("productions.sqlite")

    dst_conn.execute("DELETE from synth")
    dst_conn.commit()

    synthfile = file_base()
    if type(synthfile) is int:
        exit(synthfile)

    with codecs.open(synthfile, "r", "UTF-8") as gen:
        conversion = []
        morphemes = []
        for line in gen:
            line = re.sub('\s+', " ", line.strip(" \t\n\r"))
            if line != "" and not line[0] == "#":
                if not conversion:
                    conversion = line.split(' --> ')
                    print(conversion)
                else:
                    tpl = line.split(' ')
                    if tpl[0][0] == "-":
                        morphemes.append(tpl)
                        print(tpl)
                    elif tpl[0] == "...":
                        check = tpl[1]
                        orto = tpl[2]
                        production(src_conn, dst_conn, conversion, morphemes, check, orto)
                        conversion = []
                        morphemes = []
                    # cursor.execute("INSERT INTO tags (word, lemma, pos) VALUES (?,?,?)", tpl)
                    # progress += 1
                    # if progress % 10000 == 0:
                    #     pb.draw_progress_bar(progress / linecount, t)
        gen.close()

    print("EOF")

_main()
