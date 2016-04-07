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

t = time.time()

conn = sqlite3.connect("dictionary.sqlite")

cursor = conn.cursor()

# cursor.execute("SELECT COUNT(*) FROM tags")
# print ("loaded %i records" % cursor.fetchone())

#cursor.execute("SELECT count(word) FROM tags WHERE pos=? AND form like ?", ("VMN0000", "%ir"))
cursor.execute("SELECT word FROM tags WHERE pos=? AND form like ?", ("VMN0000", "%r"))
for row in cursor:
    lemma = row[0]
    print (lemma  + "\t" + lemma + "se")
    #print ("%s" % row)

