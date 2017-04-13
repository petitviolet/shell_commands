#!/usr/bin/env zsh
# indicator for loading time

function loading() {
  local count=30
  if [ $# -eq 1 ]; then
    count=$1
  fi
  trap "echo -en '\r                      '; exit 0" INT

  for i in `seq 1 1 $count`
  do
    echo -en '|\b'  1>&2; sleep 0.05;
    echo -en '/\b'  1>&2; sleep 0.05;
    echo -en '-\b'  1>&2; sleep 0.05;
    echo -en '\\\b' 1>&2; sleep 0.05;
  done
  echo -en ' \b' 1>&2;
}

loading $@
