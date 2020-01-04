#!/usr/bin/env bash

if ! declare -F gotodir >/dev/null ; then
  gotodir() {
    if [ $# -lt 1 ] ; then
      echo "Usage: $0 <file>"
      return 1
    fi

    local file
    file=$(type -p "$1")
    local realpath
    if ! realpath=$(resolvelink "$file") ; then
      return 1
    fi
    
    local dir
    dir=$(dirname "$realpath")
    cd "$dir" || return 1
  }
  export -f gotodir
else
  echo "Duplicated func definition, ignoring: gotodir @${BASH_SOURCE[0]}:${LINENO}"
fi

if ! declare -F resolvelink >/dev/null ; then
  resolvelink() {
    local file=$1
    local ls_res
    while [ -h "$file" ] ; do
      ls_res=$(ls -ld "$file")
      [[ "$ls_res" =~ ^.+-\>[[:space:]]+(.+)$ ]]
      link=${BASH_REMATCH[1]}
      if [ "${link##/*}" ] ; then
        file=$(dirname "$file")"/$link"
      else
        file="$link"
      fi
    done

    echo "$file"
    if [ -e "$file" ] ; then
      return 0
    else
      return 1
    fi
  }
  export -f resolvelink
else
  echo "Duplicated func definition, ignoring: resolvelink @${BASH_SOURCE[0]}:${LINENO}"
fi

if ! declare -F fullpath >/dev/null ; then
  fullpath() {
    local file_path=
    # 是否一个可执行程序
    if ! file_path=$(type -p "$1" 2>/dev/null) ; then
      # 是否存在，解析软连接
      if ! file_path=$(resolvelink "$1") ; then
        return 1
      fi
    fi
    if expr "$file_path" : '/..*' >/dev/null ; then
      p=$file_path
    else
      p=$(pwd)/$file_path
    fi
    echo "$p"
  }
  export -f fullpath
else
  echo "Duplicated func definition, ignoring: fullpath @${BASH_SOURCE[0]}:${LINENO}"
fi
