#!/bin/python3
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
Script to merge all tables in catalog database into a catalog table in dictionary database.
The table has the following fields:

dictionary.sqlite
    catalog: table with the words and their frequencies
        word TEXT PRIMARY KEY: word accounted.
        wikipedia INTEGER: accounted appearances in wikipedia table in catalog
        ...
        tatoeba INTEGER: accounted appearances in tatoeba table in catalog

The script will use all tables in catalog and will automatically assign names,
 so introducing a new corpus source will not demand update for this script.

"""
import sqlite3
import time
import progressbar as pb


local_catalog = {}
tables = []

db_source = 'catalog.sqlite'
db_destination = 'dictionary.sqlite'


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
    insert = "INSERT INTO catalog VALUES ("
    for table in tables:
        insert += "?, "
    insert += "?)"
    cursor = connections[1].cursor()
    for w in local_catalog:
        progress += 1
        # cursor.execute(upsert, {"w": w, "c": localCatalog[w]})
        cursor.execute(insert, [w] + local_catalog[w])
        if progress % 10000 == 0:
            pb.draw_progress_bar(progress/total, start)

    connections[1].commit()
    cursor.close()

    pb.draw_progress_bar(1, start)
    elapsed_time = time.time() - start
    print("Inserted table records in: %i min %02i sec" % (int(elapsed_time) / 60, int(elapsed_time) % 60))


def prepare_database():
    """
    Ensures that the database catalog.sqlite exists and has at least a page counter
    :return: connection to the database
    """
    print("Discovering source tables...")
    src_connection = sqlite3.connect(db_source)
    cursor = src_connection.cursor()
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
    for table in cursor.fetchall():
        tables.append(table[0])

    print("Checking integrity...")
    dst_connection = sqlite3.connect(db_destination)
    cursor = dst_connection.cursor()
    cursor.execute("SELECT COUNT(name) FROM sqlite_master WHERE type='table' AND name='catalog'")
    if cursor.fetchone()[0] > 0:
        cursor.execute("DROP TABLE catalog")
        print("Old table 'catalog' removed")

    # Create table
    ddl_query = "CREATE TABLE catalog  (word text PRIMARY KEY"
    for table in tables:
            ddl_query += ", " + table + " INTEGER"
    ddl_query += ")"
    cursor.execute(ddl_query)
    dst_connection.commit()
    print("Table 'catalog' created")
    cursor.close()
    return src_connection, dst_connection


connections = prepare_database()
t = time.time()

print("Estimating file size...")
table_count = len(tables)

print("Building dictionary...")
table_num = 0
cursor = connections[0].cursor()
for table in tables:

    print("Scanning table %s (%i of %i)" % (table, table_num + 1, table_count))
    t1 = time.time()
    tbl_progress = 1
    record_count = cursor.execute("SELECT count(word) FROM " + table).fetchone()[0]
    cursor.execute("SELECT word, ocurrences FROM " + table)

    for r in cursor.fetchall():
        if r[0] not in local_catalog:
            local_catalog[r[0]] = [0] * table_count
        local_catalog[r[0]][table_num] = r[1]
        tbl_progress += 1
        if tbl_progress % 10000 == 0:
            pb.draw_progress_bar(tbl_progress / record_count, t)

    pb.draw_progress_bar(1, t)
    print("Scanned table in: %.3f sec" % (time.time() - t1))
    table_num += 1

connections[0].close()
print("Saving data into 'catalog' table...")
save_catalog()
elapsed_time = time.time() - t
print("Operation completed in: %i min %02i sec" % (int(elapsed_time) / 60, int(elapsed_time) % 60))
