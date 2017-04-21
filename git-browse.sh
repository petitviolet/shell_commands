#!/usr/bin/env sh -e

function git_browse() {
  local remote=$(git remote -v | ag fetch | awk '{ print $2 }' | sed 's/:/\//g' | sed 's/git@/http:\/\//g' | sed 's/.git$//g')
  local branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
  local current=$(git rev-parse --show-prefix)
  local url=$(echo $remote/tree/$branch/$current)
  # echo $url
  open $url
}

git_browse
