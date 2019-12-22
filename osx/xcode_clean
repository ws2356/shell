#!/usr/bin/env bash
set -e

if pgrep -i xcode >/dev/null ; then
  echo "Xcode is working, not doing it."
  exit 0
fi

declare -a clean_list=( \
  ~/Library/Developer/Xcode/DerivedData/* \
  ~/Library/Developer/Xcode/Archives/* \
  ~/Library/Developer/Xcode/iOS\ Device\ Logs/* \
  )

check_path() {
  local pref=~/Library/Developer/Xcode/
  if ! echo "$1" | grep -E "^$pref" >/dev/null ; then
    return 1
  fi
  return 0
}

for ff in "${clean_list[@]}" ; do
  if [ ! -e "$ff" ] ; then
    continue
  fi
  if ! check_path "$ff" ; then
    echo "Path($ff) is not safe to rm -rf"
    continue
  fi
  set -x
  rm -rf "$ff"
  set +x
done
