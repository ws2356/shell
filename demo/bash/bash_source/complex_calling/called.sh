#!/usr/bin/env bash

echo "called FUNCNAME: ${FUNCNAME[*]}"
echo "called BASH_SOURCE: ${BASH_SOURCE[*]}"

called() {
  echo "called[func] FUNCNAME: ${FUNCNAME[*]}"
  echo "called[func] BASH_SOURCE: ${BASH_SOURCE[*]}"
}
