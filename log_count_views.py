#!/usr/bin/env python3
# Counts occurances of a post url and counts them up.
# Also excludes bad user agents

import re
import sys
from multiprocessing import Pool, cpu_count
from collections import Counter
from collections import namedtuple
from functools import reduce
import time

LogKey = namedtuple('LogKey', ['url', 'date'])

def to_date(date):
    return time.strftime('%Y/%m/%d', date)

def get_time(timestr):
    datestr = timestr.split()[0]
    return to_date(time.strptime(datestr, "%d/%b/%Y:%H:%M:%S"))

def get_status_code(code):
    try:
        return int(code)
    except ValueError:
        return -1

def do_log_file(filename):
    url_counter = Counter()
    bad_ua = re.compile('[Bb]ot|[Ss]pider|[Ss]lurp|[Cc]rawler')
    logfile = open(filename)
    for line in logfile.readlines():
        if len(line) > 500:
            continue
        match = list((map(''.join,
                          re.findall(r'\"(.*?)\"|\[(.*?)\]|(\S+)', line))))
        if not bad_ua.match(match[-1]):
            req_str_index = len(match) - 9 + 4
            if len(match) == 10:
                req_str_index = 4
            req = match[req_str_index].split()

            # Client Errors or Non Gets Are Excluded From Counts
            status_code = get_status_code(match[req_str_index + 1])
            url = req[1]

            if req[0].upper() != 'GET' and \
                    not 200 <= status_code < 400 or \
                    not url.startswith('/20'):
                continue

            date = get_time(match[3])
            url_counter[LogKey(url, date)] += 1
    logfile.close()
    return url_counter

def main():
    with Pool(cpu_count()) as pool:
        url_counts = pool.map(do_log_file, sys.argv[1:])
    totals = reduce(lambda accum, x: accum + x, url_counts, Counter())
    for (url, date), count in totals.items():
        if url.startswith('/20') and url.endswith('.html'):
            print('{},{},{}'.format(url, date, count))

if __name__ == '__main__':
    main()
