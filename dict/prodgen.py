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


def production(conv, morph):


    gen_pos = conv[0]
    prod_pos = conv[1]
    suffixes = []
    for sfx in morph:
        suffixes.append([sfx[0][1:], sfx[1][1:]])

    src_cursor = src_conn.cursor()
    cmp_cursor = src_conn.cursor()
    src_cursor.execute("CREATE TEMPORARY TABLE tmp_prod AS SELECT word, lemma FROM tags WHERE pos LIKE ?", [gen_pos])
    src_conn.commit()
    src_query = "SELECT word, lemma FROM tmp_prod"
    for sfx in suffixes:
        start = time.time()
        gen_sfx = sfx[0]
        prod_sfx = sfx[1]
        if gen_sfx == "":
            src_cursor.execute(src_query, gen_pos)
        else:
            src_cursor.execute(src_query + " WHERE word LIKE ?", ["%" + gen_sfx])

        for row in src_cursor:
            lemma = row[0]
            word = row[0][:len(row[0]) - 2] + prod_sfx
            spell = cmp_cursor.execute("SELECT count(word)FROM spell WHERE word = ?",
                                       [word]).fetchone()[0]
            lt = cmp_cursor.execute("SELECT count(word)FROM tags WHERE word = ?",
                                    [word]).fetchone()[0]
            cmp_cursor.execute("SELECT pedia, source, quote, news, books, versity, voyage FROM wikicatalog where word = ?", [word])
            if cmp_cursor.rowcount > 0:
                if cmp_cursor.rowcount > 1:
                    print("Doble")
                with cmp_cursor.fetchone() as comparison:
                    pedia = comparison[0]
                    source = comparison[1]
                    quote = comparison[2]
                    news = comparison[3]
                    books = comparison[4]
                    versity = comparison[5]
                    voyage = comparison[6]
            else:
                pedia = 0
                source = 0
                quote = 0
                news = 0
                books = 0
                versity = 0
                voyage = 0

            if pedia + source + quote + news + books + versity + voyage +lt + spell:
                dst_conn.execute("INSERT INTO synth values(?,?,?,?,?,?,?,?,?,?,?,?)",
                                [word, lemma, gen_pos, spell, lt, pedia, source, quote, news, books, versity, voyage])
                print("+", word)
            else:
                print("·", word)

        elapsed_time = time.time() - start

        print(sfx, int(elapsed_time) / 60, int(elapsed_time) % 60)
        dst_conn.commit()

    print(gen_pos, "-->",  prod_pos)
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
            else:
                tpl = line.strip('\n').split(' ')
                if len(tpl) == 2:
                    morphemes.append(tpl)
                elif line == "...":
                    production(conversion, morphemes)
                print(tpl)
                # cursor.execute("INSERT INTO tags (word, lemma, pos) VALUES (?,?,?)", tpl)
                # progress += 1
                # if progress % 10000 == 0:
                #     pb.draw_progress_bar(progress / linecount, t)
gen.close()

print("EOF")
