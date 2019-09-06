#!/bin/bash

if [ $# -lt 9 ] ; then
  echo -e "Usage:\n$0 <team_id> <git_url> <git_branch> <app_identifier> <username> <type> <force> <verbose> <readonly>"
  echo "type '' for default value"
  exit 1
fi

team_id=${1:-'73GK7982HW'}
git_url=${2:-'git@code.smartstudy.com:wansong/mobile-cert.git'}
git_branch=${3:-'18518729823@163.com'}
app_identifier=${4:-'com.smartstudy.ysky'}
username=${5:-'wansong@innobuddy.com'}
type=${6:-'development'}
force=${7:-'false'}
verbose=${8:-'true'}
_readonly=${9:-'true'}

fastlane run match \
  git_branch:${git_branch} \
  type:${type} \
  git_url:${git_url} \
  app_identifier:${app_identifier} \
  username:${username} \
  team_id:${team_id} \
  readonly:${_readonly} \
  force:${force} \
  verbose:${verbose}
