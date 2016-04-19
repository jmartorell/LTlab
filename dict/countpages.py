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
Script to count pages of a Wikimedia backup dump.

Accepts filename, without directory or extension as parameter.
Returns the total pagecount and a list of page title tags in the form "tag:title" an their occurrences.

Ideas for parsing large xml files taken from http://boscoh.com/programming/reading-xml-serially.html
"""
import xml.etree.ElementTree as etree
import re
import sys

import wikifile

file_base = wikifile.file_base()

if type(file_base) is int:
    exit(file_base)

filename = '../texts/es' + file_base + '.xml'

pages = 0
metaTags = {}
meta = None
tag = None
for event, elem in etree.iterparse(filename, events=('start', 'end', 'start-ns', 'end-ns')):
    if event == "start":
        if re.search("page$", elem.tag) is not None:
            pages += 1
            if pages % 100 == 0:
                sys.stderr.write("\r %i" % pages)
    elif event == "end":
        if re.search("title$", elem.tag) is not None:
            meta = re.match("^(\w+):.+", elem.text)
            if meta is not None:
                tag = meta.group(1)
                if tag in metaTags:
                    metaTags[tag] += 1
                else:
                    metaTags[tag] = 1
        elem.clear()
print ("\n\n Total pages for %s file: %i" % (sys.argv[1] + ".xml", pages))
for tag in metaTags:
    print (tag, metaTags[tag])