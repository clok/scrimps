#!/bin/bash
git fetch --prune
for branch in `git branch -vv | grep ': gone]' | awk '{print $1}'`; do
  git branch -D $branch;
done
git fetch --tags
