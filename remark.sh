#!/bin/bash

REMARK_ROOT=/var/tmp
REMARK_PORT=9999
REMARK_JS_FILE=remark-latest.min.js

function remark() {
  # provide a file path to show as a presentation
  if [ $# -ne 1 ]; then
    exit 1
  fi

  # kill web server if already launched
  local PID_FILE="$REMARK_ROOT/remark.pid"
  if [ -e $PID_FILE ]; then
    kill $(cat $PID_FILE) 2>/dev/null
    rm $PID_FILE
  fi

  # markdown filr symbolic link to $REMARK_ROOT
  ln -s $1 $REMARK_ROOT/ &>/dev/null
  # create a html file for remark.js
  local FILE_NAME=$(__split_file_name $1)
  __create_remark_html $FILE_NAME

  # change directory to $REMARK_ROOT temporaly
  local ORIGIN=$PWD
  \cd $REMARK_ROOT/

  # launch web server
  set +m
  if [[ $(python --version 2>&1) == *"Python 3"* ]];then
    python -m http.server $REMARK_PORT &> /dev/null &
  else
    python -m SimpleHTTPServer $REMARK_PORT &> /dev/null &
  fi
  set -m
  echo $! > $REMARK_ROOT/remark.pid
  \cd $ORIGIN

  # open the presentation on Chrome
  sleep 0.5
  open -a "Google Chrome" "http://localhost:$REMARK_PORT/$(__remark_html_file_name $FILE_NAME)"
}

function __split_file_name() {
  # extract only file name from provided file path even if it's absolute
  echo $1 | awk -F/ '{ print $NF }'
}

function __remark_html_file_name() {
  # file name with .html ext
  local OUT=$(__split_file_name $1)
  echo  "$OUT.html"
}

function __check_remark_js_file() {
  # check remark.js file exists or download
  local TARGET=$REMARK_ROOT/$REMARK_JS_FILE
  if [ -e $TARGET ]; then
    :
  else
    wget "http://gnab.github.io/remark/downloads/remark-latest.min.js" -O $TARGET
  fi
}

function __create_remark_html() {
  # create html file
  __check_remark_js_file
  cat << EOS | sed -e "s;{{FILE_NAME}};$1;g" > "$REMARK_ROOT/$(__remark_html_file_name $1)"
  <DOCTYPE html>
  <html>
    <head>
      <title>Presentation</title>
    </head>
    <body>
      <script src="./$REMARK_JS_FILE" type="text/javascript"></script>
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
        @page {
          size: 908px 681px;
          margin: 0;
        }

        @media print {
          .remark-slide-scaler {
            width: 100% !important;
            height: 100% !important;
            transform: scale(1) !important;
            top: 0 !important;
            left: 0 !important;
          }
        }

        blockquote > p {
          background-color: #EEE;
          padding: 0.5em;
        }
        .remark-slide {
          position: relative !important;
        }
        .remark-slide-content > p, .remark-slide-content li {
          font-size: 28px;
        }
        .remark-slide-scaler {
          overflow: auto;
        }
        .remark-inline-code {
          background-color: #f4f4f4;
          color: #dd1144;
          padding: 0.1em 0.25em 0.1em 0.25em;
        }
        table, td, th {
          border: 1px #999 solid;
          border-collapse: collapse;
        }
        td, th {
          padding: 4px;
        }
        .footnote {
          font-size: 14px;
        }
      </style>
    </body>
  </html>
EOS
}

# execution
remark $*

