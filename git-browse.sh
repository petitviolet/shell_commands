#!/usr/bin/env sh -e

function git_browse() {
  local remote=$(git remote -v | grep fetch | awk '{ print $2 }' | sed 's;^ssh://;https://;' | sed 's;^git@\(.*\):\(.*\);https://\1\/\2;' | sed 's;^https://\(.*\)@\(.*\);https://\2;' | sed 's/.git$//g')
  local target=$(git rev-parse --show-prefix)$1
  if [ -e $target ]; then
    local branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    local url=$remote/tree/$branch/$target
  else
    local url=$remote/tree/$1
  fi
  # echo $url
  open $url
}

git_browse $*
