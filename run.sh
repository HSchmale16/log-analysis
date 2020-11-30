#!/bin/bash
# Log Analysis


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


# run the log analysis
BEFORE_VIEW_COUNT=$(countViewsFromCsv)
./log_count_views.py $PlaceLogs/* > $ArticleViewCsv
AFTER_VIEW_COUNT=$(countViewsFromCsv)

echo "Got $((AFTER_VIEW_COUNT - BEFORE_VIEW_COUNT)) new article views"

./make_plots.R
