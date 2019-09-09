#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

this_file=`which $0`
if ! echo "$this_file" | grep -E '^/'>/dev/null ; then
  this_file="$(pwd)/${this_file}"
fi
this_dir=$(dirname "$this_file")

source_dir="$this_dir"

target_bindir=~/bin
if [ ! -e "$target_bindir" ] ; then
  mkdir -p "$target_bindir"
fi

ignore_list=
for ff in $(ls "$source_dir") ; do
  target_file=${target_bindir}/$ff
  source_file=${source_dir}/$ff
  if [ -f "$target_file" ] || [ -h "$target_file" ] ; then
    ignore_list="$ignore_list"$'\n'"$source_file"
    continue
  fi
  ln -s "$source_file" "$target_file"
done

if [ -n "$ignore_list" ] ; then
  echo "The following scripts are not installed \
 because file with same name exist: $ignore_list"
fi
