#!/usr/bin/env sh -e

function git_update() {
  local current_branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1 /')
  echo "updating $current_branch..."
  git pull origin $current_branch --rebase --autostash
}

git_update