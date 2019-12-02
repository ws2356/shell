#!/bin/bash

f1() {
  echo "f1 sources: ${BASH_SOURCE[*]}"
  echo "f1 funcname: ${FUNCNAME[*]}"
  f2
}

f2() {
  echo "f2: ${BASH_SOURCE[*]}"
  echo "f2 funcname: ${FUNCNAME[*]}"
  f3
}

f3() {
  echo "f3: ${BASH_SOURCE[*]}"
  echo "f3 funcname: ${FUNCNAME[*]}"
}

echo "before: ${BASH_SOURCE[*]}"
f1

echo "\$0: $0 v.s. BASH_SOURCE: $BASH_SOURCE"
