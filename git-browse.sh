#!/usr/bin/env sh -e

function git_browse() {
  local remote=$(git remote -v | grep fetch | awk '{ print $2 }' | sed 's;^git@\(.*\):\(.*\);http://\1\/\2;' | sed 's;^http://\(.*\)@\(.*\);http://\2;' | sed 's/.git$//g')
  local branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
  local target=$(git rev-parse --show-prefix)$1
  local url=$remote/tree/$branch/$target
  # echo $url
  open $url
}

git_browse $*
