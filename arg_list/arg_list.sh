#! /usr/bin/env bash

echo "\$*"
./echo_args.sh $*
echo
echo

echo "\$@"
./echo_args.sh $@
echo
echo

echo "\"\$@\""
./echo_args.sh "$@"
echo
echo

echo "\"\$*\""
./echo_args.sh "$*"

