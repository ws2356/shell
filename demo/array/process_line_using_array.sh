#! /usr/bin/env bash

IFS=$'\n' 
lines=($(echo -e "hello world 123 !\nthat's rich 456"))
unset IFS
for line in "${lines[@]}"; do
  echo "line: $line"
done

