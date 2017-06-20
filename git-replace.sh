#!/usr/bin/env sh -e

function git_replace() {
  before=$1
  after=$2
  git grep -l $before | xargs sed -i "" -e "s/$before/$after/g" 2>&1
}

git_replace $*
