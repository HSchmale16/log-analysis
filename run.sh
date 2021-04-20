#!/bin/bash
# Apache Access Log Analysis: Do Most Everything Script
# 
# This script actually runs the log processing python script then uses R
# to create a set of PDFs as a report.
#
# Written by Henry J Schmale
#



# Location to place downloaded logs
PlaceLogs=./logs
# Article View Count CSV
ArticleViewCsv=articleViews.csv
# Post Hit Count CSV
PostHitCountCsv=postHits.csv

function countViewsFromCsv() {
    [[ -f "$ArticleViewCsv" ]] && \
        awk -F, '{s+=$3}END{print s}' $ArticleViewCsv || echo 0
}

# Calculate when this program was last run. Based on articleView file.
# Since I get views everyday we can use the most recent view from the
# report file.
if [[ -f "$ArticleViewCsv" ]]
then 
    lastRunOn=$(cut -f 2 -d , "$ArticleViewCsv" | sort -rn | head -n1)
    echo "LAST VIEW SAW BY SCRIPT: $lastRunOn"
fi

# run the log analysis
BEFORE_VIEW_COUNT=$(countViewsFromCsv)
./log_count_views.py $PlaceLogs/* > $ArticleViewCsv
AFTER_VIEW_COUNT=$(countViewsFromCsv)

echo "Got $((AFTER_VIEW_COUNT - BEFORE_VIEW_COUNT)) new article views"

./make_plots.R
