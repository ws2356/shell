#!/usr/bin/env bash

use_cancelled=false
select item in "$@" ; do
  if [ -z "$item" ] ; then
    continue
  fi
  echo "Did select: $item"
  break
done || use_cancelled=true

echo "select return code: $?"
