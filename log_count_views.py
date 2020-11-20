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

# The maximum length of a line before we bail out on processing it. This
# is set to deal with lines meant to attack my blog, but they can't
# because it's static.
MAX_LINE_LENGTH = 900

SetKey = namedtuple('LogKey', ['url', 'date', 'ip'])
LogKey = namedtuple('LogKey', ['url', 'date'])

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

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

def do_log_file(logfile):
    views = set()
    bad_ua = re.compile(
        '[Bb]ot|[Ss]pider|[Ss]lurp|[Cc]rawler|[Ss]em[Rr]ush'
    )
    logline_re = re.compile(r'\"(.*?)\"|\[(.*?)\]|(\S+)')
    for line in logfile.readlines():
        if len(line) > MAX_LINE_LENGTH:
            continue
        match = list(map(''.join, logline_re.findall(line)))
        if not bad_ua.search(match[-1]):
            req_str_index = len(match) - 9 + 4
            if len(match) == 10:
                req_str_index = 4
            req = match[req_str_index].split()

            # Client Errors or Non Gets Are Excluded From Counts
            status_code = get_status_code(match[req_str_index + 1])
            try:
                url = req[1]
            except IndexError:
                continue

            if req[0].upper() != 'GET' and \
                    not 200 <= status_code < 400 or \
                    not url.startswith('/20'):
                continue

            date = get_time(match[3])
            ip = match[0]
            views.add(SetKey(url, date, ip)) 
    return Counter(LogKey(url, date) for url,date,ip in views)

def do_filename(filename):
    with open(filename) as f:
        return do_log_file(f)

def do_many_files(filenames): 
    with Pool(cpu_count()) as pool: 
        return pool.map(do_filename, filenames)


def main():
    if len(sys.argv) > 1:
        url_counts = do_many_files(sys.argv[1:])
        totals = reduce(lambda accum, x: accum + x,
                        url_counts, Counter())
    else:
        totals = do_log_file(sys.stdin)

    for (url, date), count in totals.items():
        if url.startswith('/20') and url.endswith('.html'):
            print(','.join([url, date, str(count)]))

if __name__ == '__main__':
    main()
