#!/usr/bin/env python
# Counts occurances of a post url and counts them up.

import sys
import re
import apache_log_parser
from collections import Counter

line_parser = apache_log_parser.make_parser("%a - %u %t \"%m %U %H\" %s %B \"%{Referer}i\" \"%{User-Agent}i\"")
bad_ua = re.compile('([Bb]ot|[Ss]pider|[Cc]rawler)')

"""
Loads the url_path in all log files
"""
def handleLogFile(x):
    l = list()
    with open(x) as f:
        for x in f:
            try:
                z = line_parser(x.rstrip())
                if bad_ua.search(z['request_header_user_agent']) is not None:
                    l.append(z['url_path'])
            except:
                pass
    return l

urls = map(handleLogFile, sys.argv[1:])

c = Counter()
for x in urls:
    for y in x:
        if(y.startswith('/20') and y.endswith('html')):
            c[y] += 1
for x in c:
    print(x + ',' + str(c[x]).lower())
