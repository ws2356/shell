#! /usr/bin/env bash

cmd=$0

all_args="$*"
if [ -z "$all_args" ] ; then
  exit 0
fi


for i in "$@" ; do
  echo "arg: -${i}-"
done

echo

shift
all_args=`echo "$*" | tr -d ' '`
if [ -n "$all_args" ] ; then
  sleep 1
  ${cmd} "$@"
else
  echo "done"
fi



