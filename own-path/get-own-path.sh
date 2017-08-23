#! /bin/sh

function own_path() {
  SCRIPT="$(which $0)"
  if [ "x$(echo $SCRIPT | grep '^\/')" = "x" ] ; then
    SCRIPT="$PWD/$SCRIPT"
  fi
  echo $SCRIPT
}

