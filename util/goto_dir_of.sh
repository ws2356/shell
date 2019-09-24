#!/usr/bin/env bash
# 暂时仅支持osx

goto_dir_of() {
  set -e

  if [ $# -lt 1 ] ; then
    echo "Usage: $0 <file>"
    exit 1
  fi
  file=$1

  if type "$file" >/dev/null 2>&1 ; then
    file=$(which "$file")
  fi

  while [ -h "$file" ] ; do
    file=$(readlink -n "$file")
  done

  dir=file
  if [ ! -d "$file" ] ; then
    dir=$(dirname "$file")
  fi

  cd "$dir"
}
