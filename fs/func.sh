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


if ! declare -F install_file >/dev/null ; then
  install_file() {
    local from_file=$1
    if ! [[ "$from_file" =~ ^/ ]] ; then
      from_file="$(pwd)/$from_file"
    fi
    local to_file=$2
    mkdir -p "$(dirname "$to_file")"
    backup_file "$to_file"
    if ! ln -s "$from_file" "$to_file" ; then
      echo "Failed to create symbolic link from $from_file to ${to_file}: maybe parent dir not exist or no permission to do so"
    fi
  }
  export -f install_file
else
  echo "Duplicated func definition, ignoring: install_file @${BASH_SOURCE[0]}:${LINENO}"
fi


if ! declare -F backup_file >/dev/null ; then
  backup_file() {
    local ff=$1
    if ! [ -e "$ff" ] ; then
      return 0
    fi

    local backup_ff=${ff}.bak
    if ! [ -f "$backup_ff" ] ; then
      mv "$ff" "$backup_ff"
      return 0
    fi

    local suffix=1
    while [ -f "${backup_ff}.${suffix}" ] ; do
      ((suffix++))
    done

    mv "$ff" "${backup_ff}.${suffix}"
  }

  export -f backup_file
else
  echo "Duplicated func definition, ignoring: backup_file @${BASH_SOURCE[0]}:${LINENO}"
fi
