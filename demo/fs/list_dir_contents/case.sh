#!/usr/bin/env bash

describe_array() {
  declare -n arr="$1"
  local ii=0
  echo "About: $1"
  while [ "$ii" -lt "${#arr[@]}" ] ; do
    echo "[$ii]: ${arr[ii]}"
    ((++ii))
  done
}

# 两种方式都可以
# IFS=$'\n' read -r -d '' -a pkgs < <(ls -d -1 dir/*.app)
declare -a pkgs
for file in dir/*.app ; do
  pkgs+=("$file")
done

echo "${#pkgs[@]}"
describe_array pkgs
