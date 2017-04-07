#!/bin/bash
# Log Analysis

# ssh connection to sftp files from
SSHLocation=hjsblog
# Location to place downloaded logs
PlaceLogs=./logs

# Article View Count CSV
ArticleViewCsv=articleViews.csv

# Location and pattern of logs
GetLogs=../logs/access*


#######################################
#######################################

CWD=$(pwd)

# move to get location
mkdir -p $PlaceLogs
cd $PlaceLogs

# perform the get operation
sftp $SSHLocation << EOF
cd $(dirname $GetLogs)
get $(basename $GetLogs)
EOF

# uncompress files
bunzip2 *.bz2

# return to script dir
cd $CWD

# run the log analysis
./log_count_views.py $PlaceLogs/* > $ArticleViewCsv

