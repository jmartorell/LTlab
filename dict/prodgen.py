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

# source_cursor = conn.cursor()
cmp_query ="""SELECT t.word, t.lemma, w.pedia, w.source, w.quote, w.news, w.books, w.versity, w.voyage,
                             s.word AS spell, tags.word AS tags
        FROM tmp_synth t LEFT JOIN wikicatalog w USING(word)
        LEFT JOIN spell s USING(word)
        LEFT JOIN tags USING (word)"""


def is_weak_vowel(vowel):
    return vowel in ("e", "i", "é", "í")


def production(conv, morph, chk, ort):

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

    cmp_cursor.execute("CREATE TEMPORARY TABLE IF NOT EXISTS tmp_synth (word TEXT, lemma TEXT, pos TEXT)")
    src_cursor.executescript("DROP TABLE IF EXISTS tmp_tags;")
    src_cursor.execute("CREATE TEMPORARY TABLE tmp_tags AS SELECT word, lemma FROM tags WHERE pos LIKE ?", [gen_pos])
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
            lemma = row[0]
            for i in range(1, sfx_count):
                prod_pos = conv[i]
                prod_sfx = sfx[i]
                root = row[0][:len(row[0]) - len(gen_sfx)]

                if ort == "tonic":
                    root = root.replace("á", "a")\
                                .replace("é", "e")\
                                .replace("í", "i")\
                                .replace("ó", "o")\
                                .replace("ú", "u")

                if root.endswith("c") and is_weak_vowel(prod_sfx[0]):
                    root = root[:len(root) - 1] + "qu"
                if root.endswith("g") and is_weak_vowel(prod_sfx[0]):
                    root = root[:len(root) - 1] + "gu"

                word = root + prod_sfx
                cmp_cursor.execute("INSERT INTO tmp_synth VALUES (?,?,?)", [word, lemma, prod_pos])

        src_conn.commit()

        cmp_cursor.execute(cmp_query)

        for comparison in cmp_cursor:
            word = comparison[0]
            lemma = comparison[1]
            pedia = int(comparison[2] or 0)
            source = int(comparison[3] or 0)
            quote = int(comparison[4] or 0)
            news = int(comparison[5] or 0)
            books = int(comparison[6] or 0)
            versity = int(comparison[7] or 0)
            voyage = int(comparison[8] or 0)
            spell = int(0 if comparison[9] is None else 1)
            lt = int(0 if comparison[10] is None else 1)

            if not chk_corpus or (pedia + source + quote + news + books + versity + voyage +lt + spell > 1):
                dst_conn.execute("INSERT INTO synth values(?,?,?,?,?,?,?,?,?,?,?,?)",
                                 [word, lemma, prod_pos, spell, lt, pedia, source, quote, news, books, versity, voyage])

        # cmp_cursor.close()
        elapsed_time = time.time() - start

        print(sfx, int(elapsed_time) / 60, int(elapsed_time) % 60)
        dst_conn.commit()

    print(gen_pos, "-->",  conv)
    src_cursor.close()

src_conn = sqlite3.connect("dictionary.sqlite")
dst_conn = sqlite3.connect("productions.sqlite")

dst_conn.execute("DELETE from synth")
dst_conn.commit()

with codecs.open("gen.synth", "r", "UTF-8") as gen:
    conversion = []
    morphemes = []
    for line in gen:
        if not (line[0] == "#" or line[0] == "\n"):
            if not conversion:
                conversion = line.strip('\n').split(' --> ')
                print(conversion)
            else:
                tpl = line.strip('\n').split(' ')
                if tpl[0][0] == "-":
                    morphemes.append(tpl)
                    print(tpl)
                elif tpl[0] == "...":
                    check = tpl[1]
                    orto = tpl[2]
                    production(conversion, morphemes, check, orto)
                    conversion = []
                    morphemes = []
                # cursor.execute("INSERT INTO tags (word, lemma, pos) VALUES (?,?,?)", tpl)
                # progress += 1
                # if progress % 10000 == 0:
                #     pb.draw_progress_bar(progress / linecount, t)
gen.close()

print("EOF")
