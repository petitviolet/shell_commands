#!/usr/bin/env sh -e

function git_update() {
  local current_branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1 /' | tr -d '[:blank:]')
  local target_branch=$current_branch
  # echo $target_branch
  if [ $# -eq 1 ]; then
    # echo "arg: $1"
    target_branch=$1
  fi
  echo "updating $current_branch with $target_branch..."
  git fetch
  git rebase -i origin/$target_branch --autostash --rebase-merges
}

git_update $*
