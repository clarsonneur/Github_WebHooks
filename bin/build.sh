#!/bin/bash

if [[ "$HTTP_PROXY" != "" ]]
then
    PROXY="--build-arg HTTP_PROXY=$HTTP_PROXY --build-arg HTTPS_PROXY=$HTTPS_PROXY --build-arg NO_PROXY=$NO_PROXY"
fi

docker build $PROXY -t ef-github-webhook:RC1 .
