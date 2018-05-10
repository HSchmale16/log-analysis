#!/bin/bash
# Log Analysis


# Location to place downloaded logs
PlaceLogs=./logs
# Article View Count CSV
ArticleViewCsv=articleViews.csv
# Post Hit Count CSV
PostHitCountCsv=postHits.csv


# run the log analysis
./log_count_views.py $PlaceLogs/* | tr [:upper:] [:lower:] | sort > $ArticleViewCsv
./make_plots.R
