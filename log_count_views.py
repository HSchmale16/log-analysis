#!/usr/bin/env python3
# Counts occurances of a post url and counts them up.
# Also excludes bad user agents

import re
import sys
import operator
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
    GOOD_STATUS_CODES = set([200, 302, 304, 301])
    views = set()
    # A series of user agents we don't care about because those are
    # bots, and I want real people. We don't do any tracking on this.
    #
    # Rules are as follows:
    # * If it contains bots, spider, crawler it covers most well-behaved
    #   bots, some people set their user agent to something useless
    #   like their domain name. We need to filter that out too.
    # * Also exclude semrush because they don't always name their bot
    #   right, but at least their UA says it's them.
    # * Some people don't label their bots properly. If
    #   are building a bot, give it a descriptive name in the
    #   user-agent. Include a url for details about it. Don't make me
    #   google it. Looking at you Panscient and Datanyze.
    bad_ua = re.compile(
        '[Bb]ot|[Ss]pider|[Ss]lurp|[Cc]rawler|[Ss]em[Rr]ush|lytics|[Pp]anscient'
        '|facebookexternalhit|Google-AMPHTML|Datanyze'
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

            # Skip a select series of requests
            # Such as non-get requests, and weird status codes
            if req[0].upper() != 'GET' or \
                    status_code not in GOOD_STATUS_CODES or \
                    not url.startswith('/20'):
                continue
           
            # Handle people adding query params to the url
            # Cause otherwise it won't be counted
            q_mark = url.find('?')
            if q_mark > 0:
                url = url[:q_mark]
                #if len(url[q_mark:]) > 1:
                #    eprint(url[q_mark:])

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

def do_many_files_seq(filenames):
    return map(do_filename, filenames)

def main():
    if len(sys.argv) > 1:
        # For some reason it's way slower in parallel. I'm going to assume that
        # the fork overhead is causing this. It also uses less memory by doing
        # it sequentially.
        url_counts = do_many_files_seq(sys.argv[1:])
        totals = reduce(operator.add, url_counts, Counter())
    else:
        totals = do_log_file(sys.stdin)

    for (url, date), count in totals.items():
        if url.startswith('/20') and url.endswith('.html'):
            print(','.join([url, date, str(count)]))

if __name__ == '__main__':
    main()
