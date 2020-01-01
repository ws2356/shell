#!/usr/bin/env bash


if ! declare -F shellpack_lru_session >/dev/null ; then
  shellpack_lru_session() {
    local edit_prompt='Edit new entry:'
    local select_prompt='Select session:'
    local session_file=
    local is_edit=false
    while [ "$#" -gt 0 ] ; do
      key="$1"
      case $key in
          --edit-prompt)
          edit_prompt="$2"
          shift ; shift
          ;;
          --select-prompt)
          select_prompt="$2"
          shift ; shift
          ;;
          --session-file)
          session_file="$2"
          shift ; shift
          ;;
          --edit)
          is_edit=true
          shift
          ;;
          *)
          shift
          ;;
      esac
    done

    if [ -z "$session_file" ] ; then
      return 1
    fi

    local ttyname
    ttyname=/dev/$(ps -p "$$" -o tty | sed -n '$p' | sed 's/[[:space:]]\{1,\}$//')

    if $is_edit ; then
      0<"$ttyname" 1>"$ttyname" vim -f "$session_file"
      return 0
    fi

    # session file format
    # 1. entry
    # ============
    # what ever so long as no including  aka $'\E', which is used as delimer
    # ------------
    # 2. delimer
    # 
    # ============

    load_history() {
      cat "$session_file" 2>/dev/null || true
    }

    trim_entry() {
      sed 's/^[[:space:]]\{1,\}//' | sed 's/[[:space:]]\{1,\}$//' | sed '/^[[:space:]]*#/ d' | sed '/^$/ d'
    }

    edit_new_entry() {
      local tmp_file
      tmp_file=$(mktemp)
      >"$tmp_file" echo -e "#${edit_prompt}"

      0<"$ttyname" 1>"$ttyname" vim -f "$tmp_file"
      <"$tmp_file" trim_entry
      rm "$tmp_file"
    }

    local edit_entry="Or, $edit_prompt"
    local no_entry='Or, select none'
    local is_new_entry=false
    local is_no_entry=false
    local loaded_entry=
    local selected_entry=

    loaded_entry=$(load_history)

    declare -a entries=()
    if [ -n "$loaded_entry" ] ; then
      {
        while read -r -d '' line ; do
          if [ -z "$line" ] ; then
            continue
          fi
          entries+=("$line")
        done
      } <<<"$loaded_entry"
    fi

    if [ "${#entries[@]}" -gt 0 ] ; then
      1>&2 echo "$select_prompt"
    fi

    entries+=("$edit_entry" "$no_entry")

    declare -a displayed_entries=()
    for item in "${entries[@]}" ; do
      displayed_item=$(printf '%s' "$item" | sed -e ':a' -e '$!N;s/\n/\//;ta')
      displayed_entries+=("$displayed_item")
    done

    local selected_index
    local choice
    {
      select choice in "${displayed_entries[@]}" ; do
        if [ -z "$choice" ] ; then
          continue
        fi
        selected_index=$(echo "$REPLY" | sed 's/[[:space:]]//g')
        choice="${entries[selected_index-1]}"
        if [ "$choice" = "$edit_entry" ] ; then
          selected_entry=$(edit_new_entry)
          is_new_entry=true
        elif [ "$choice" = "$no_entry" ] ; then
          selected_entry=''
          is_no_entry=true
        else
          selected_entry="$choice"
        fi
        break
      done
    } 1>&2 <"${ttyname}"

    if $is_new_entry ; then
      echo "${selected_entry}" >>"$session_file"
    fi

    printf '%s' "${selected_entry}"
  }
else
  echo "Duplicated func definition, ignoring: shellpack_simget @${BASH_SOURCE[0]}:${LINENO}"
fi
