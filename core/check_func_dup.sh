#!/usr/bin/env bash

# 尝试写一个用于检测一个文件里的函数是否已经在当前环境定义过，发现不好实现
# 因为bash不支持数组、词典的export，哪怕在导出的函数里访问，也访问不到
# 看来需要定义函数的时候自己用declare -F 检测一下
# 其他takeaway：
# declare -n的使用；
# export -f导出函数；
# declare -f 查看函数定义（可以用于检测函数是否已定义）；
# declare -A dict声明一个词典；
# 检测一个变量是否有定义且不为空：if [ "$x" ] ; then ...

# 检查文件里包含的（函数）是否和当前shell环境已有的重名
# 返回第一个重名的函数
function ws_can_safe_source() {
  local xx=123
  export xx
  export -f ws_build_function_name_cache
  check_dup() {
    local -A existing_funcs
    ws_build_function_name_cache existing_funcs
    echo "xx: $xx"
    echo "${#existing_funcs[@]}"
    if [ -n "${existing_funcs[$1]}" ] ; then
      return 1
    else
      return 0
    fi
  }
  export -f check_dup

  source_code=$(cat "$1")
  {
    bash --noprofile --norc -s
  } <<EOF
  $source_code
  declare -F
  declare -F | while read _ __ name ; do
    if ! check_dup "\$name" ; then
      echo "duplicate function detected: \$name"
      exit
    fi
  done
EOF
}

function ws_build_function_name_cache() {
  local _
  local __
  declare -n nameref=$1
  {
    while read _ __ func_name ; do
      nameref[$func_name]=1
    done
  } < <(declare -F)
}
