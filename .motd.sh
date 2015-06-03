#!/usr/bin/env bash

WEATHER=""
DEGREES=""
STOCKS=""
QUOTES=""
MOTD_VERSION="0.01"

curl -fsH "Accept: text/plain" "https://motd.sh/?v=$MOTD_VERSION&weather=$WEATHER&degrees=$DEGREES&stocks=$STOCKS&quotes=$QUOTES" > ~/.motd.tmp
motd=`cat ~/.motd.tmp`
echo "$motd"
echo "$motd" > ~/.motd
rm ~/.motd.tmp
