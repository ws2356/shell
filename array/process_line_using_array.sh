#! /usr/bin/env bash

IFSBackup=$IFS
IFS=$'\n' 
lines=($(echo -e "hello world 123 !\nthat's rich 456"))
IFS=$FSBackup
for line in "${lines[@]}"; do
  echo "line: $line"
done

