#!/usr/bin/env python
# Counts occurances of a post url and counts them up.

import apache_log_parser
from collections import Counter
from pprint import pprint
import sys

line_parser = apache_log_parser.make_parser("%a - %u %t \"%m %U %H\" %s %B \"%{Referer}i\" \"%{User-Agent}i\"")

def handleLogFile(x):
    l = list()
    with open(x) as f:
        for x in f:
            try:
                z = line_parser(x.rstrip())
                l.append(z['url_path'])
            except:
                pass
    return l

urls = map(handleLogFile, sys.argv[1:])

c = Counter()
for x in urls:
    for y in x:
        if(y.startswith('/2') and y.endswith('html')):
            c[y] += 1
for x in c:
    print(x + ',' + str(c[x]).lower())
