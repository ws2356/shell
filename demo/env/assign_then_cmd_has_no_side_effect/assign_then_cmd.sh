#!/usr/bin/env bash
x=1
./subshell.sh 1

# this does not change x in current shell
x=2 ./subshell.sh 2

echo "[parent shell] x: $x"

export x
./subshell.sh 3
