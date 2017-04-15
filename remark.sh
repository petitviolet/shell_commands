#!/bin/bash

function remark() {
  local PID_FILE="/var/tmp/remark.pid"
  if [ $# -ne 1 ]; then
    exit 1
  fi
  if [ -f $PID_FILE ]; then
    kill $(cat $PID_FILE) 2>/dev/null
    rm $PID_FILE
  fi
  ln -s $1 /var/tmp/ &>/dev/null
  local FILE_NAME=$(__split_file_name $1)
  echo $FILE_NAME
  __create_remark_html $FILE_NAME

  local ORIGIN=$PWD
  \cd /var/tmp/
  set +m
  if [[ $(python --version 2>&1) == *"Python 3"* ]];then
    python -m http.server 9999 &> /dev/null &
  else
    python -m SimpleHTTPServer 9999 &> /dev/null &
  fi
  set -m
  echo $! > /var/tmp/remark.pid
  \cd $ORIGIN
  open -a "Google Chrome" "http://localhost:9999/$(__remark_html_file_name $FILE_NAME)"
}

function __split_file_name() {
  echo $1 | awk -F/ '{ print $NF }'
}

function __remark_html_file_name() {
  local OUT=$(__split_file_name $1)
  echo  "$OUT.html"
}

function __create_remark_html() {
  cat << EOS | sed -e "s;{{FILE_NAME}};$1;g" > "/var/tmp/$(__remark_html_file_name $1)"
  <DOCTYPE html>
  <html>
    <head>
      <title>Presentation</title>
    </head>
    <body>
      <script src="http://gnab.github.io/remark/downloads/remark-latest.min.js" type="text/javascript"></script>
      <script type="text/javascript">
        var slideshow = remark.create({
          sourceUrl: "{{FILE_NAME}}",
          navigation: {
            scroll: false
          },
          highlightStyle: "github",
          highlightLines: true
        });
      </script>
      <style type="text/css">
        blockquote > p {
          background-color: #EEE;
          padding: 0.5em;
        }
        .remark-slide {
          position: relative !important;
        }
        .remark-slide-scaler {
          overflow: auto;
        }
      </style>
    </body>
  </html>
EOS
}

remark $*

