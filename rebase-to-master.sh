#!/bin/bash

set +e

bold="\e[1m"
dim="\e[2m"
underline="\e[4m"
blink="\e[5m"
reset="\e[0m"
red="\e[31m"
green="\e[32m"
blue="\e[34m"

bold="\e[1m"
dim="\e[2m"
underline="\e[4m"
blink="\e[5m"
reset="\e[0m"
red="\e[31m"
green="\e[32m"
blue="\e[34m"

h1() {
  printf "\n${bold}${underline}%s${reset}" "$(echo "$@" | sed '/./,$!d')"
}

h2() {
  printf "\n${bold}%s${reset}" "$(echo "$@" | sed '/./,$!d')"
}

info() {
  printf "${dim}→ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}

note() {
  printf "\n${bold}${blue}Note: %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}

success() {
  printf "${green}✔ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}

warnError() {
  printf "${red}✖ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}

error() {
  printf "${red}${bold}✖ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}

if [[ "$1" == "" ]]; then
  error "please provide a branch as first argument"
  exit 1
fi

runCommand() {
  command="$1"
  info "$1"
  output="$(eval $command 2>&1)"
  ret_code=$?

  if [ $ret_code != 0 ]; then
    warnError "$output"
    if [ ! -z "$2" ]; then
      error "$2"
    fi
    exit $ret_code
  fi
  if [ ! -z "$3" ]; then
    success "$3"
  fi
  if [ ! -z "$4" ]; then
    eval "$4='$output'"
  fi
}

BRANCH="$1"

runCommand "git checkout master"
runCommand "git pull"
runCommand "git checkout $BRANCH"
runCommand "git rebase master"

success "$BRANCH has been rebased"
note "Run 'git push -u -f origin $BRANCH' to push to remote"
