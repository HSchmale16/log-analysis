#!/bin/bash
# gets the logs

# Location to place downloaded logs
PlaceLogs=./logs
# ssh connection to sftp files from
SSHLocation=hjsblog
# Location and pattern of logs
GetLogs=../logs/access*


#######################################
#######################################

function getReqCount() {
    wc -l access_log* | tail -n 1 | awk '{print $1}' 
}

function calcViews() {
    [ -f 'articleViews.csv' ] && awk -F, '{s+=$3}END{print s}' articleViews.csv
}

CWD=$(pwd)

mkdir -p $PlaceLogs
pushd $PlaceLogs


# Only grab new ones
last_count=$(getReqCount)

# Recompress files because we need to uncomress to read them 
bzip2 access_log.20* 2>/dev/null
rsync --checksum -v -a $SSHLocation:$GetLogs . || exit -1


# uncompress files
bunzip2 *.bz2
new_count=$(getReqCount)
echo "Retrieved $(($new_count - $last_count)) new requests"
# return to script dir
popd

