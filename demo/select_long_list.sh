#!/usr/bin/env bash

N=200
declare -a choices
for ii in $(seq "$N") ; do
  choices+=("your choice: ${ii}"$'\n'"i have to do it"$'\n'"I have to go north")
done

select item in "${choices[@]}" ; do
  if [ -n "$item" ] ; then
    echo "$item"
    break
  fi
done

echo "good call you'v made: $item"
