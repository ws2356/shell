#! /bin/sh

function capitalize {
  word=$1
  initial=`echo $word | cut -c 1 | tr '[:lower:]' '[:upper:]'`
  echo "$initial`echo $word | cut -c 2-`"
}

str=$1
grep_hyphen="`echo $str | grep '-'`x"

if [ $grep_hyphen = "x" ] ; then
  delim='_'
else
  delim='-'
fi


space_delimed=`echo $str | tr $delim ' '`
ret=''
for word in $space_delimed ; do
  ret="${ret}`capitalize $word`"
done

echo $ret

