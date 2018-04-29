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

CWD=$(pwd)

mkdir -p $PlaceLogs
pushd $PlaceLogs

# Recompress files because we need to uncomress to read them 
bzip2 access_log.20* 2>/dev/null

# Only grab new ones
rsync --checksum -v -a $SSHLocation:$GetLogs . 

# uncompress files
bunzip2 *.bz2

# return to script dir
popd
