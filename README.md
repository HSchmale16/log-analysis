# log-analysis

A set of scripts to analyze the most popular posts on my blog.

I assume that posts urls are formatted like `/{YEAR}/{MONTH_NUM}/{MONTH_DAY_NUM}/{post_title}`. It assumes that the log files are standard apache logs. Especially those produced by NearlyFreeSpeech.net.

## Overview
I use python to process multiple log files in parallel then reduce the results together and write out a csv.

## How To Use
Edit the `SSHLocation` in retrievelogs.sh to be where you get your logs from. I use an ssh alias for mine.

Then you can run from the current directory:

    ./retrievelogs.sh && ./run.sh && $YOUR_PDF_VIEWER Rplots.pdf
