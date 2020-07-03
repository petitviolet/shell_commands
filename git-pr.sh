#!/usr/bin/env sh -e

function git_pr() {
  gh pr view -w
}

git_pr
