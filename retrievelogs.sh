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
    wc -l access_log | cut -d' ' -f1
}

CWD=$(pwd)

mkdir -p $PlaceLogs
pushd $PlaceLogs

# Recompress files because we need to uncomress to read them 
bzip2 access_log.20* 2>/dev/null

# Only grab new ones
last_count=$(getReqCount)
rsync --checksum -v -a $SSHLocation:$GetLogs . 
new_count=$(getReqCount)

echo "Retrieved $(($new_count - $last_count)) new requests"

# uncompress files
bunzip2 *.bz2

# return to script dir
popd
