#! /bin/sh

echo "get-own-path.sh:"
echo "BASH_SOURCE: ${BASH_SOURCE[*]}"
echo "FUNCNAME: ${FUNCNAME[*]}"

function own_path() {
  echo "own_path: "
  echo "BASH_SOURCE: ${BASH_SOURCE[*]}"
  echo "FUNCNAME: ${FUNCNAME[*]}"
  own_path2
}

function own_path2() {
  echo "own_path2: "
  echo "BASH_SOURCE: ${BASH_SOURCE[*]}"
  echo "FUNCNAME: ${FUNCNAME[*]}"
  own_path3
}

function own_path3() {
  echo "own_path3: "
  echo "BASH_SOURCE: ${BASH_SOURCE[*]}"
  echo "FUNCNAME: ${FUNCNAME[*]}"
  own_path4
}

function own_path4() {
  echo "own_path4: "
  echo "BASH_SOURCE: ${BASH_SOURCE[*]}"
  echo "FUNCNAME: ${FUNCNAME[*]}"
}

