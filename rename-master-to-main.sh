#! /bin/bash
git branch -m master main
git fetch origin
git branch -u origin/main main
git fetch --prune
for branch in `git branch -vv | grep ': gone]' | awk '{print $1}'`; do
  git branch -D $branch;
done
git fetch --tags
