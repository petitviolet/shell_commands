#!/bin/bash -e

post_message() {
  local MESSAGE=$*
  local URL="https://slack.com/api/chat.postMessage"
  curl -sS -XPOST -d "token=$SLACK_API_TOKEN" -d "channel=$CHANNEL" -d "text=$MESSAGE" -d "username=$NAME" -d "icon_emoji=$ICON" $URL | jq '.ok'
}

upload_file() {
  local FILE_NAME=$1
  local URL="https://slack.com/api/files.upload"
  local DATE=$(date +"%Y%m%d_%H:%M:%S")
  curl -sS -F token=$SLACK_API_TOKEN -F filename="batch_result_${DATE}.log" -F filetype=auto -F channels=$CHANNEL -F file=@$FILE_NAME $URL
}

usage() {
  echo "Usage: SLACK_API_TOKEN=xoxp-xxxxxxxxxxxxxxx SLACK_BOT_NAME=MYBOT SLACK_BOT_CHANNEL=#test SLACK_BOT_ICON=:smile: $0 [file <file_path>|message <message>]"
}

TYPE=${1:-help}

if [ $TYPE != 'help' ]; then
  if [ -z $SLACK_API_TOKEN ]; then
    echo 'you must set SLACK_API_TOKEN'
    TYPE=help
    # exit 1
  fi
  if [ -z $SLACK_BOT_CHANNEL ]; then
    echo 'you must set SLACK_BOT_CHANNEL'
    TYPE=help
    # exit 1
  fi

  CHANNEL=$SLACK_BOT_CHANNEL
  ICON=${SLACK_BOT_ICON:-':slack:'}
  NAME=${SLACK_BOT_NAME:-'SLACK BOT'}
fi


case $TYPE in
  file)
shift
    upload_file $*
    ;;
  message)
shift
    post_message $*
    ;;
  help)
    usage
    ;;
  *)
    echo "'$TYPE' Didn't match anything."
    usage
    exit 1
esac

