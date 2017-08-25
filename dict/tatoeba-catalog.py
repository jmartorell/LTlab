#!python3
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
Script to add to catalog database the words in the relevant language of a Tatoeba backup dump.
The table has the following fields:

catalog.sqlite
    tatoeba: table with the words and their ocurrences
        word TEXT PRIMARY KEY: instance of the word retrieved by the parser.
        ocurrences INTEGER: consolidated counting of the the word appearing in sentences

"""
import xml.etree.ElementTree as Etree
import sqlite3
import re

import time
import sys

import progressbar as pb
import codecs


local_catalog = {}

reWord = re.compile("[a-záéíóúüñ]+[\-]?[a-záéíóúüñ]*")

file_base = 'tatoeba'

filename = '../texts/sentences.csv'

db_file = 'catalog.sqlite'

insert = 'INSERT INTO ' + file_base + ' VALUES (:w, :c)'


def file_len(fname):
    import subprocess
    p = subprocess.Popen(['wc', '-l', fname],
                         stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE)
    result, err = p.communicate()
    if p.returncode != 0:
        raise IOError(err)
    return int(result.strip().split()[0])


def save_catalog():
    """
    Dumps the temporary word catalog to the database. The less often this function is called,
    the more efficient it is.
    Uses the global conn variable and the draw_progress_bar function.
    :return: None
    """
    total = len(local_catalog)
    progress = 0
    start = time.time()
    cursor = conn.cursor()
    for w in local_catalog:
        progress += 1
        # cursor.execute(upsert, {"w": w, "c": localCatalog[w]})
        cursor.execute(insert, {"w": w, "c": local_catalog[w]})
        if progress % 5000 == 0:
            pb.draw_progress_bar(progress/total, start)

    conn.commit()
    cursor.close()
    pb.draw_progress_bar(1, start)

    elapsed_time = time.time() - start

    pb.draw_progress_bar(1, start)
    print("Updated database in: %.3f sec" % elapsed_time)


def prepare_database():
    """
    Ensures that the database catalog.sqlite exists and has at least a page counter
    :return: connection to the database
    """
    print("Checking integrity")
    connection = sqlite3.connect(db_file)
    cursor = connection.cursor()
    cursor.execute("SELECT COUNT(name) FROM sqlite_master WHERE type='table' AND name=?", [file_base])

    if cursor.fetchone()[0] > 0:
        cursor.execute("DELETE FROM " + file_base)
        print("Table %s initialized" % file_base)
    else:
        # Create table
        cursor.execute("CREATE TABLE " + file_base + " (word text PRIMARY KEY, ocurrences integer)")
        connection.commit()
        print("Table %s created" % file_base)
    cursor.close()
    return connection


conn = prepare_database()
t = time.time()

print("Estimating file size...")
linecount = file_len(filename)

print("Building dictionary...")
progress = 1
with codecs.open(filename, "r", "UTF-8") as ins:
    for line in ins:
        tpl = line.strip('\n').split('\t')
        progress += 1
        if progress % 10000 == 0:
            pb.draw_progress_bar(progress / linecount, t)
        if tpl[1] == "spa":
            for word in reWord.findall(tpl[2].lower()):
                if word in local_catalog:
                    local_catalog[word] += 1
                else:
                    local_catalog[word] = 1
                    # print(word, local_catalog[word])
pb.draw_progress_bar(1, t)
print("Built dictionary in: %.3f sec" % (time.time() - t))

save_catalog()
print("Operation completed in: %.3f sec" % (time.time() - t))
conn.close()
