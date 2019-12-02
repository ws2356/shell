#!/bin/bash
echo "subsh.sh seeing x: $x"
export x=$(expr "${x:-0}" '+' 10)
if [ "$0" = "$BASH_SOURCE" ] ; then
  exit "$1"
fi
