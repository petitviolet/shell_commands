#!/usr/bin/env sh -e

function git_browse() {
  local remote=$(git remote -v | grep fetch | awk '{ print $2 }' | sed 's;^ssh://;https://;' | sed 's;^git@\(.*\):\(.*\);https://\1\/\2;' | sed 's;^https://\(.*\)@\(.*\);https://\2;' | sed 's/.git$//g')
  local branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
  local target=$(git rev-parse --show-prefix)$1
  local url=
  if [ -e "$target" ]; then # if file exists
    url=$remote/tree/$branch/$target
  else
    if [ -n "$1" ]; then
      # consider $1 a branch name
      url=$remote/tree/$1
    else
      url=$remote/tree/$branch
    fi
  fi
  open $url
}

git_browse $*
