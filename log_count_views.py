#!/usr/bin/env python3
# Counts occurances of a post url and counts them up.
# Also excludes bad user agents 

import sys
import re
from collections import Counter
from functools import reduce


"""
Loads the url_path in all log files
"""
def do_log_file(x):
    url_counter = Counter()
    bad_ua = re.compile('[Bb]ot|[Ss]pider|[Ss]lurp|[Cc]rawler')
    with open(x) as f:
        for line in f.readlines():
            match = list((map(''.join,
                re.findall(r'\"(.*?)\"|\[(.*?)\]|(\S+)', line))))
            if not bad_ua.match(match[-1]):
                index = len(match) - 9 + 4
                if len(match) == 10:
                    index = 4
                req = match[index].split()
                try:
                    if req[0].upper() != 'GET' or int(match[index + 1]) >= 400:
                        continue
                except:
                    continue
                url_counter[match[index].split()[1]] += 1
    return url_counter

def main():
    url_counts = [do_log_file(x) for x in sys.argv[1:]]
    totals = reduce(lambda accum,x: accum + x, url_counts, Counter())
    for url,count in totals.items():
        if url.startswith('/20') and url.endswith('.html'):
            print('{},{}'.format(url, count))

if __name__ == '__main__':
    main()
