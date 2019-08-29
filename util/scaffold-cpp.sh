#! /usr/bin/env bash

set -e

git_repo='https://github.com/bestofsong/cmake-project-template'
name=$1

git clone "$git_repo" "$name"
cd "$name"
git submodule update --init --recursive
git remote remove origin
script/updatetags.sh
