#!/usr/bin/env bash

called() {
  echo "called FUNCNAME: ${FUNCNAME[*]}"
  echo "called BASH_SOURCE: ${BASH_SOURCE[*]}"
}
