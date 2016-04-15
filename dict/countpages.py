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

Accepts wikipedia or wikisource as parameter.
Returns the total pagecount and a list of page title tags in the form "tag:title" an their occurrences.

Ideas for parsing large xml files taken from http://boscoh.com/programming/reading-xml-serially.html
"""
import xml.etree.ElementTree as etree
import re
import sys

filename_wikipedia = '../texts/eswiki-latest-pages-articles.xml'
filename_wikisource = '../texts/eswikisource-20160305-pages-articles.xml'

if len(sys.argv) == 1:
    print ("Usage: %s wikipedia | wikisource ", sys.argv[0])
elif sys.argv[1] == "wikisource":
    filename = filename_wikisource
elif sys.argv[1] == "wikipedia":
    filename = filename_wikipedia
else:
    print("Usage: %s wikipedia | wikisource ", sys.argv[0])
    exit(12)


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
print ("\n\n Total pages for file: %i" % pages)
for tag in metaTags:
    print (tag, metaTags[tag])
