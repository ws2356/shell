#!/usr/bin/env bash

if ! declare -F flutter_select >/dev/null ; then
  flutter_select() {
    # 约定大于配置，把flutter解压到~/flutter/<ver>/
    select ver in $(ls "${HOME}/flutter") ; do
      if [ -z "$ver" ] ; then
        continue
      fi
      local flutter_bindir="${HOME}/flutter/${ver}/bin"
      local dart_bindir="${flutter_bindir}/cache/dart-sdk/bin"
      export PATH="${flutter_bindir}:${dart_bindir}:${PATH}"
      break
    done
  }
  export -f flutter_select
else
  echo "Duplicated func definition, ignoring: flutter_select @${BASH_SOURCE[0]}:${LINENO}"
fi
