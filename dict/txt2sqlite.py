# Copyright (C) 2016 Juan Martorell
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

import sqlite3
import codecs
import time
import subprocess
import progressbar as pb


def file_len(fname):
    p = subprocess.Popen(['wc', '-l', fname], stdout=subprocess.PIPE,
                                              stderr=subprocess.PIPE)
    result, err = p.communicate()
    if p.returncode != 0:
        raise IOError(err)
    return int(result.strip().split()[0])

print("Accessing database")
conn = sqlite3.connect("dictionary.sqlite")

print("Checking integrity")
cursor = conn.cursor()

cursor.execute("SELECT COUNT(name) FROM sqlite_master WHERE type='table' AND name='tags'")
if cursor.fetchone()[0] > 0:
    cursor.execute("SELECT COUNT(*) FROM tags")
    print("Database already exists with %i entries. Delete it before regenerating." % cursor.fetchone())
else:
    t = time.time()

    print("Estimating file size")
    linecount = file_len("dictionary.dump")

    # Create table
    cursor.execute("CREATE TABLE tags (word text, lemma text, pos text)")

    print("Dumping file into database...")
    progress = 1
    with codecs.open("dictionary.dump", "r", "ISO-8859-1") as ins:
        for line in ins:
            tpl = line.strip('\n').split('\t')
            cursor.execute("INSERT INTO tags (word, lemma, pos) VALUES (?,?,?)", tpl)
            progress += 1
            if progress % 10000 == 0:
                 pb.draw_progress_bar( progress /linecount, t )
        ins.close()
    conn.commit()
    pb.draw_progress_bar( 1, t )
    print("Loaded database in: %.3f sec" % (time.time()-t))
    cursor.execute("SELECT COUNT(*) FROM tags")
    print("loaded %i records" % cursor.fetchone())
    conn.close()
