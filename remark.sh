#!/bin/bash

REMARK_ROOT=/var/tmp

function remark() {
  local PID_FILE="$REMARK_ROOT/remark.pid"
  if [ $# -ne 1 ]; then
    exit 1
  fi
  if [ -e $PID_FILE ]; then
    kill $(cat $PID_FILE) 2>/dev/null
    rm $PID_FILE
  fi
  # markdown filr symbolic link to $REMARK_ROOT
  ln -s $1 $REMARK_ROOT/ &>/dev/null
  local FILE_NAME=$(__split_file_name $1)
  echo $FILE_NAME
  __create_remark_html $FILE_NAME

  local ORIGIN=$PWD
  \cd $REMARK_ROOT/
  set +m
  if [[ $(python --version 2>&1) == *"Python 3"* ]];then
    python -m http.server 9999 &> /dev/null &
  else
    python -m SimpleHTTPServer 9999 &> /dev/null &
  fi
  set -m
  echo $! > $REMARK_ROOT/remark.pid
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

function __check_remark_js_file() {
  local TARGET=$REMARK_ROOT/remark-latest.min.js
  if [ -e $TARGET ]; then
    :
  else
    wget "http://gnab.github.io/remark/downloads/remark-latest.min.js" -O
  fi
}

function __create_remark_html() {
  __check_remark_js_file
  cat << EOS | sed -e "s;{{FILE_NAME}};$1;g" > "$REMARK_ROOT/$(__remark_html_file_name $1)"
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
        .remark-inline-code {
          background-color: #f4f4f4;
          color: #dd1144;
          padding: 0.1em 0.25em 0.1em 0.25em;
        }
      </style>
    </body>
  </html>
EOS
}

remark $*

