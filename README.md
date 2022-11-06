# log-analysis

A set of scripts to analyze the most popular posts on my
[blog](https://www.henryschmale.org).

I assume that posts urls are formatted like
`/{YEAR}/{MONTH_NUM}/{MONTH_DAY_NUM}/{post_title}`. It assumes that the
log files are standard apache logs. Especially those produced by
NearlyFreeSpeech.net.

## Overview

I use python to process multiple log files in parallel then reduce the
results together and write out a csv.

Here's just one of the many types of plots it generates.

[box and whisker grouped by quarter of total daily hits](bw.png)

## How To Use

Edit the `SSHLocation` in retrievelogs.sh to be where you get your logs
from. I use an ssh alias for mine.

You also need a json file named posttags.json formatted as below. It's
an object where the keys are your posts, and have an array of strings
associated with them. It was originally included to make some kind of
visualization involving popular tags, but as of now it just names the
live posts on my blog.

    {
        "POST LOCATION": [
            "some tag",
            "some tag 2",
            "another tag"
            ],
        "POST LOCATION 2": [
            "some tag"
            ]
    }

Then you can run from the current directory:

    ./retrievelogs.sh && ./run.sh && $YOUR_PDF_VIEWER Rplots.pdf

# How Views Are Counted

As of right now, views are counted once per ip, post and date. The
results are placed in articleViews.csv file. The fields are as follows
in the same order:

path
:   The path to the post. We can derive the publication date of the post
from this. You might not be able to if you don't use jekyll and the same
naming structure.

date
:   when the posts were hit

hits
:   The number of hits for that date.
