#!/bin/bash

export x=7
echo "0 x: $x"

if ( echo 'some th not important' >/dev/null ; ./subsh.sh 1 ) ; then
  echo "1 x: $x"
else
  echo "2 x: $x"
fi

if ( echo 'some th not important' >/dev/null ; ./subsh.sh 0 ) ; then
  echo "3 x: $x"
else
  echo "4 x: $x"
fi

./subsh.sh 0
echo "5 x: $x"

. subsh.sh 0
echo "6 x: $x"
