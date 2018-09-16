#! /bin/sh

function normalize {
  local rc=0
  local ret

  if [ $# -gt 0 ] ; then
    # invalid
    if [ "x`echo $1 | grep -E '^/\.\.'`" != "x" ] ; then
      echo $1
      return -1
    fi

    # convert to absolute path
    if [ "x`echo $1 | grep -E '^\/'`" == "x" ] ; then
      normalize "`pwd`/$1"
      return $?
    fi

    ret=`echo $1 | sed 's;/\.\($\|/\);/;g' | sed 's;/[^/]*[^/.]\+[^/]*/\.\.\($\|/\);/;g'`
  else
    read line
    normalize "$line"
    return $?
  fi

  if [ "x`echo $ret | grep -E '/\.\.?(/|$)'`" != "x" ] ; then
    ret=`normalize "$ret"`
    rc=$?
  fi

  echo "$ret"
  return $rc
}

