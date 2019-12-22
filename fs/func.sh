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

if ! declare -F currentpath >/dev/null ; then
  currentpath() {
    bash_source=$1
    if type -f "$bash_source" >/dev/null 2>&1 ; then
      bash_source=$(type -p "$bash_source")
    else
      if [ ! -e "$bash_source" ] ; then
        return 1
      fi
    fi
    if expr "$bash_source" : '/..*' >/dev/null ; then
      p=$bash_source
    else
      p=$(pwd)/$bash_source
    fi
    echo "$p"
  }
  export -f currentpath
else
  echo "Duplicated func definition, ignoring: currentpath @${BASH_SOURCE[0]}:${LINENO}"
fi
