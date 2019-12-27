#!/usr/bin/env bash

if ! declare -F simget >/dev/null ; then
  simget() {
    local runtimes
    # cast to lowercase
    runtimes=$(xcrun simctl list -j | jq -r '.runtimes | .[] | (.version + "," + .identifier)')
    local -a runtime_versions
    local -A runtime_id_by_version
    local os_version
    local os_id
    for item in ${runtimes} ; do
      os_version=$(echo "$item" | sed 's/,..*//')
      os_id=$(echo "$item" | sed 's/[^,]\{1,\},//')
      runtime_id_by_version["$os_version"]=$os_id
      runtime_versions+=("$os_version")
    done
    if [ "${#runtime_id_by_version[@]}" -le 0 ] ; then
      return 1
    fi

    echo "选择系统版本：" 1>&2
    local selected_os_version=
    select item in "${runtime_versions[@]}" ; do
      if [ -z "$item" ] ; then
        continue
      fi
      selected_os_version=$item
      break
    done
    local selected_os_id=${runtime_id_by_version[$selected_os_version]}

    local simulators
    IFS_=$IFS
    IFS=$'\n' simulators=($(xcrun simctl list -j | jq -r '.devices["'"${selected_os_id}"'"] | .[] | (.name + "," + .udid)'))
    IFS=$IFS_
    local -a device_names
    local -A device_id_by_name
    local device_name
    local device_id
    for item in "${simulators[@]}" ; do
      device_name=$(echo "$item" | sed 's/,..*//')
      device_id=$(echo "$item" | sed 's/[^,]\{1,\},//')
      device_id_by_name["$device_name"]=$device_id
      device_names+=("$device_name")
    done

    echo "选择机型：" 1>&2
    local selected_device_name
    local selected_device_id
    select item in "${device_names[@]}" ; do
      if [ -z "$item" ] ; then
        continue
      fi
      selected_device_name=$item
      break;
    done
    selected_device_id=${device_id_by_name[$selected_device_name]}
    echo "$selected_device_id"
  }
  export -f simget
else
  echo "Duplicated func definition, ignoring: simget @${BASH_SOURCE[0]}:${LINENO}"
fi
