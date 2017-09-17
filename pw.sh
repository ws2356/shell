#! /bin/bash
if [[ $# -ge 2 ]] ; then
  input=$1$2
elif [[ $# -ge 1 ]] ; then
  input=$1
else
  echo "no input"
  exit -1
fi
dgst=`echo $input | openssl dgst`
segs=($dgst)
len=${#segs[@]}
hex=${segs[$((len - 1))]}
echo $hex | xxd -r -p | base64 | tr / . | tr + _

