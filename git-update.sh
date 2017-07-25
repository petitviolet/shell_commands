#!/usr/bin/env sh -e

function git_update() {
  local current_branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1 /')
  echo "updating $current_branch..."
  git fetch
  local r=$(git stash)
  local EMPTY="No local changes to save"
  git pull origin $current_branch --rebase
  echo $r
  if [ "$r" != "$EMPTY" ]; then
    git stash apply stash@{0}
  fi
}

git_update
