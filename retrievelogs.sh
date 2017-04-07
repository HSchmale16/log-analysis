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
