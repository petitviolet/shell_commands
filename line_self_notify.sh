#!/bin/env sh

LINE_TOKEN=`cat $HOME/.line_token`

function line {
    pipe=`cat -`
    message=`echo -e "$@\n$pipe"`
    echo -e "$message"
    curl -v -X POST -H "Authorization: Bearer $LINE_TOKEN" -F "message=$message" https://notify-api.line.me/api/notify
}
