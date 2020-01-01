#!/usr/bin/env bash

x=123
export x
./subshell.sh 1
x='abc'
./subshell.sh 2
