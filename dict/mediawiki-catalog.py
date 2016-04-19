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
"""
Script to create a sqlite database out of the words in the relevant pages of a Wikimedia backup dump.
The database has the following tables and fields:

catalogwiki{pedia|source}.sqlite
    productions: table with the words and their ocurrences
        word TEXT PRIMARY KEY: instance of the word retrieved by the parser.
        ocurrences INTEGER: consolidated counting of the the word appearing in pages
    counters: Table to keep track of progress for long operations
        counter: description for the pointer
        value: current value for the pointer

Ideas for parsing large xml files taken from http://boscoh.com/programming/reading-xml-serially.html
Ideas for updating word counters in the database taken from the accepted answer in
http://stackoverflow.com/questions/3647454/increment-counter-or-insert-row-in-one-statement-in-sqlite
"""
import xml.etree.ElementTree as Etree
import sqlite3
import re

import time
import sys

import progressbar as pb
import wikifile




nsmap = {}
localCatalog = {}

rePage = re.compile("(page$)")
reTitle = re.compile("(title$)")
reText = re.compile("(text$)")
reTitleDiscard = re.compile("^([\w]+iki|Plantilla|Categoría|Archivo|Wiki[\w]+):")
reTemplate = re.compile("{{[\s\S]+?}}")
reTable = re.compile("{\|[\s\S]+?\|}")
reMeta = re.compile("\[\[[\s\S]+?\]\]")
reMetaCategory = re.compile("\[\[Categor.+\]\]")
reLink = re.compile("\[http.+\]")
reTag = re.compile("<.+?>")
reWord = re.compile("[a-záéíóúüñ]+([\-][a-záéíóúüñ]+)?")

useful = True
pageNo = 0  # Counter/pointer of page under inspection
lastPageNo = 0  # Already processed pages -- stored in the database
# Estimated pages: 3260545 for Wikipedia, 176888 fro Wikisource

file_base = wikifile.file_base()

if type(file_base) is int:
    exit(file_base)

filename = '../texts/es' + file_base + '.xml'

estimatedPages = {'wikipedia': 3260545,
                  'wikisource': 176888,
                  'wikibooks': 16608,
                  'wikiversity': 4529,
                  'wikinews': 28679,
                  'wikivoyage': 5790,
                  'wikiquote': 19415}  # For progress and estimation
db_file = 'catalog' + file_base + '.sqlite'

estimated_pages = estimatedPages[file_base]

upsert = """INSERT OR REPLACE INTO productions
VALUES (:w,
  COALESCE(
    (SELECT ocurrences FROM productions
       WHERE word=:w),
    0) + :c);
"""


def save_catalog():
    """
    Dumps the temporary word catalog to the database. The less often this function is called,
    the more efficient it is.
    Uses the global conn variable and the draw_progress_bar function.
    :return: None
    """
    total = len(localCatalog)
    progress = 0
    start = time.time()
    cursor = conn.cursor()
    for w in localCatalog:
        progress += 1
        cursor.execute(upsert, {"w": w, "c": localCatalog[w]})
        if progress % 5000 == 0:
            pb.draw_progress_bar(progress/total, start)
    cursor.execute("UPDATE counters set value = ? WHERE counter = 'page'", (pageNo,))
    conn.commit()
    cursor.close()
    pb.draw_progress_bar(1, start)

    elapsedTime = time.time() - startTime
    try:
        estimatedRemaining = int((estimated_pages - pageNo) / ((pageNo - lastPageNo) / elapsedTime))
    except:
        estimatedRemaining = 0

    print("Processed %i pages out of %i in %im %02is -- ETA: %im%02is" %
          (pageNo, estimated_pages,
           int(elapsedTime) / 60, int(elapsedTime) % 60,
           estimatedRemaining / 60, estimatedRemaining % 60))

def prepare_database():
    """
    Ensures that the database catalog.sqlite exists and has at least a page counter
    :return: connection to the database
    """
    print("Checking integrity")
    connection = sqlite3.connect(db_file)
    cursor = connection.cursor()
    cursor.execute("SELECT COUNT(name) FROM sqlite_master WHERE type='table' AND name='productions'")
    global lastPageNo
    if cursor.fetchone()[0] > 0:
        cursor.execute("SELECT value FROM counters where counter ='page'")
        lastPageNo = cursor.fetchone()[0]
        print("Database already exists with %i pages processed." % lastPageNo)
    else:
        # Create table
        cursor.execute("CREATE TABLE productions (word text PRIMARY KEY, ocurrences integer)")
        cursor.execute("CREATE TABLE counters (counter text, value integer)")
        cursor.execute("INSERT INTO counters values ('page', 0)")
        connection.commit()
        print("Database created")
    cursor.close()
    return connection

conn = prepare_database()
startTime = time.time()

for event, elem in Etree.iterparse(filename, events=('start', 'end', 'start-ns', 'end-ns')):
    if event == 'start-ns':
        ns, url = elem
        nsmap[ns] = url
    elif event == "start":
        if rePage.search(elem.tag) is not None:
            pageNo += 1
            if pageNo < lastPageNo:
                if pageNo % 1000 == 0:
                    pb.draw_progress_bar(pageNo/lastPageNo, startTime)
            elif (pageNo - lastPageNo) % 20000 == 0:
                save_catalog()
                localCatalog.clear()

    elif event == 'end':
        if pageNo >= lastPageNo:
            if reTitle.search(elem.tag) is not None:
                useful = reTitleDiscard.match(elem.text) is None
                if (pageNo - lastPageNo) % 5000:
                    sys.stdout.write("\r%6i" % pageNo)
                    #sys.stdout.write("\r%6s %s" % (useful, elem.text[:50].ljust(50)))
            else:
                if reText.search(elem.tag):
                    if useful:
                        try:
                            content = reTemplate.sub("", elem.text)
                        except:
                            print("\nException at page %i \ntext: %s" % (pageNo, sys.exc_info()[0]))
                            content = ""
                        if reMetaCategory.search(content) is not None:
                            content = reMeta.sub("", content).lower()
                            content = reTag.sub("", content)
                            content = reLink.sub("", content)
                            for match in reWord.finditer(content):
                                word = match.group(0)
                                if word in localCatalog:
                                    localCatalog[word] += 1
                                else:
                                    localCatalog[word] = 1

        elem.clear()

save_catalog()
conn.close()
