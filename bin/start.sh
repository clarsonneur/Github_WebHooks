#!/bin/bash

if [[ "$1" = "" ]]
then
    echo "Usage is $0 <path to EF installation>"
    exit 1
fi
EF_PATH="$1"

if [[ ! -d "$EF_PATH"/bin/ectool ]]
then
    echo "Unable to find out a valid ectool command in $EF_PATH. Please fix it and restart."
    exit 1
fi


docker run -t -d -p 5000:5000 -v $EF_PATH:/opt/electriccloud/electriccommander ef-github-webhook:RC1
