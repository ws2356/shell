#!/usr/bin/env bash

# 通过不同的方法把str里的单词放置到数组里，研究IFS的赋值在对应情况下的影响范围
str='a/brow/fox/quickly/jump/over/a/lazy/cat'
declare -a a1
declare -a a2
declare -a a2_2
declare -a a3
declare -a a4
declare -a a4_2

describe_array() {
  declare -n arr="$1"
  local ii=0
  echo "About: $1"
  while [ "$ii" -lt "${#arr[@]}" ] ; do
    echo "[$ii]: ${arr[ii]}"
    ((++ii))
  done
}

# case 1 内置命令
IFS='/' read -r -a a1 <<<"$str"
echo "[After a1] IFS: -${IFS}-"
describe_array a1

# echo以及后面a2的值，说明read内置命令也和普通的命令一样，环境变量的赋值不影响当前shell
read -r -a a2 <<<"$str"
describe_array a2
a2_2=($str)
describe_array a2_2

# case 2 赋值语句不一样咯
IFS='/' a3=($str)
echo "[After a3] IFS: -${IFS}-"
describe_array a3

# 上面的a3赋值语句接受IFS环境变量的同时，IFS的新值一直保留在当前shell
read -r -a a4 <<<"$str"
describe_array a4

a4_2=($str)
describe_array a4_2
