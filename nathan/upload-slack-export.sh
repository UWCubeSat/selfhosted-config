#!/bin/bash

if (( $# != 1 ))
then
    echo 'USAGE: ./upload-slack-export.sh path-to-export.zip'
    exit 1
fi

if [[ ! -r $1 ]]
then
    echo "Could not open \"$1\" for reading."
    exit 1
fi

echo
echo 'UPLOADING Slack Export History'
echo

source remotely.sh
remotely_go

ez_rsync_up "$1" /home/slack/latest-export.zip --no-relative
