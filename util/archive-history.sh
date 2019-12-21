#! /usr/bin/env bash

pref=${1:-}

while [[ "$pref" = */ ]] && [ ${#pref} -gt 1 ] ; do
  pref=${pref%%/}
done

if [ -z "$pref" ] ; then
  pref=.
fi

save_to=${pref}/history-archive-`date '+%Y-%m-%d'`.txt

echo "${save_to}"

awk '{ $1 = "-"; $2 = ""; $3 = ""; print $0 }' | grep -vE '\s*-\s+(vim|history|which|tbnpm|cat|cd|cnpm|ls|pwd|echo|man|mv|node|rm|open|scp|ssh|help|mkdir|chmod|ping)' | grep -vE '\s*-\s+\w+=' | grep -vE '\s*-\s+git\s+(add|clean|clone|commit|remote|reset|checkout|push|pull|merge|rebase|fetch|ll|init|rm)' | grep -vE '\s*-\s+curl\s+http' | grep -vE '\s*-\s+npm (run|install|view)' |  grep -vE '^\s*-\s+(brew install.+)?$' | grep -vE '\s*-\s+\.'  | sort | uniq | awk '{ $1 = NR; print $0 }' >"$save_to"

