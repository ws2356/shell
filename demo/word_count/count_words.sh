#!/usr/bin/env bash

declare -A stats
{
  while read -r -a words ; do
    for wd in "${words[@]}" ; do
      stats[$wd]=$((${stats[$wd]:-0} + 1))
    done
  done
} < "$1" 

for wd in "${!stats[@]}" ; do
  echo "$wd ${stats[$wd]}"
done
