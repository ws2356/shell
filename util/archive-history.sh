#! /usr/bin/env bash

pref=${1:-}

while [[ "$pref" = */ ]] && [ ${#pref} -gt 1 ] ; do
  pref=${pref%%/}
done

if [ -z "$pref" ] ; then
  pref=.
fi

save_to=${pref}/history-archive-$(date '+%Y-%m-%d').txt

echo "${save_to}"

awk '{ $1 = ""; print $0 }' |\
  grep -vE '\s*(vim|history|which|tbnpm|cat|cd|cnpm|ls|pwd|echo|man|mv|node|rm|open|scp|ssh|help|mkdir|chmod|ping)' |\
  grep -vE '\s*\w+=' |\
  grep -vE '\s*git\s+(add|clean|clone|commit|remote|reset|checkout|push|pull|merge|rebase|fetch|ll|init|rm)' |\grep -vE '\s*-\s+curl\s+http' |\
  grep -vE '\s*npm (run|install|view)' |\
  grep -vE '^\s*(brew install.+)?$' |\
  grep -vE '\s*\.'  |\
  sort |\
  uniq \
  >"$save_to"
