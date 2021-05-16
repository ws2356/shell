#!/usr/bin/env bash

if ! declare -F lru_entry >/dev/null ; then
  lru_entry() {
    local LRU_MAX=10
    # [Optional] Default: entry. You may want to use your own concept by passing: --name <name of whatever you want lru_entry to manage for you>.
    local name=
    # [Optional] The prompt text when displaying bash select menu for use to choose from.
    local select_prompt=
    # [Optional] Text of the special select menu: supposed to be chosen when use want to edit new entry.
    local edit_prompt=
    # [Optional] When user is editing new entry, a example entry to ease editing.
    local example_entry=
    # [Required] In which file history entries are stored.
    local session_file=
    # [Optional] Supposed to be passed when user want to edit history entries. If passed, this script will just open it & return.
    local is_edit=false
    local is_verbose=false
    while [ "$#" -gt 0 ] ; do
      key="$1"
      case $key in
          --verbose)
          is_verbose=true
          shift
          ;;
          --name)
          name="$2"
          shift ; shift
          ;;
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
          --example-entry)
          example_entry="$2"
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

    name=${name:-entry}

    if [ -z "$select_prompt" ] ; then
      select_prompt="Select history ${name}"
    fi
    if [ -z "$edit_prompt" ] ; then
      edit_prompt="Edit new ${name}"
    fi
    if [ -z "$example_entry" ] ; then
      example_entry="# ${edit_prompt}"
    fi
    example_entry+=$'\n'"# Lines whose first non whitespace character is # are ignored."

    local ttyname
    ttyname=/dev/$(ps -p "$$" -o tty | sed -n '$p' | sed 's/[[:space:]]\{1,\}$//')

    if $is_edit ; then
      0<"$ttyname" 1>"$ttyname" vim -f "$session_file"
      return 2
    fi

    # session file format
    # 1. entry
    # ============
    # what ever so long as no including (typing: c-v x1b) aka $'\E', which is used as delimer
    # ------------
    # 2. delimer
    # 
    # ============

    load_history() {
      cat "$session_file" 2>/dev/null || true
    }

    trim_entry() {
      sed 's/^[[:space:]]\{1,\}//' | \
        sed 's/[[:space:]]\{1,\}$//' | \
        sed '/^[[:space:]]*#/ d' | \
        sed '/^$/ d'
    }

    local -a real_entries=()

    edit_new_entry() {
      local -r DEMO=5
      local tmp_file
      tmp_file=$(mktemp)
      >"$tmp_file" echo -e "${example_entry}"

      local concated=
      local count=0
      for ent in "${real_entries[@]:0:DEMO}" ; do
        ((++count))
        if [ -n "$concated" ] ; then
          concated+=$'\n'
        fi
        concated+=$'\n'"${count}: $ent"
      done
      if [ "$count" -gt 0 ] ; then
        >>"$tmp_file" echo -e "\n# Also, you can refer to most recently ${count} entries"
        >>"$tmp_file" sed 's/^/# /' <<<"$concated"
      fi

      0<"$ttyname" 1>"$ttyname" vim -f "$tmp_file"
      <"$tmp_file" trim_entry
      rm "$tmp_file"
    }

    local edit_entry="Or, $edit_prompt"
    local no_entry='Or, select nothing'
    local is_new_entry=false
    local is_no_entry=false
    local loaded_entry=
    local selected_entry=

    loaded_entry=$(load_history)

    if [ -n "$loaded_entry" ] ; then
      {
        while read -r -d '' line ; do # TODO: wansong, last line!
          if [[ "$line" =~ ^[[:space:]]*$ ]] ; then
            continue
          fi
          real_entries+=("$line")
        done
      } <<<"$loaded_entry"
    fi

    1>&2 echo "$select_prompt"

    local -a entries=("${real_entries[@]:0}")
    entries+=("$edit_entry" "$no_entry")

    # Transform entry to one liner
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
          is_no_entry=true
        else
          selected_entry="$choice"
        fi
        break
      done || is_no_entry=true
    } 1>&2 <"${ttyname}"

    local len=${#entries[@]}
    if [ -n "$selected_entry" ] ; then
      local file_content="$selected_entry"
      local count=1
      for old_entry in "${real_entries[@]}" ; do
        if [ "$old_entry" = "$selected_entry" ] ; then
          continue
        fi
        file_content+=''$'\n'"$old_entry"
        ((++count))
        if [ $count -ge $LRU_MAX ] ; then
          break
        fi
      done
      file_content+=
      echo "$file_content" >"$session_file"
    fi

    printf '%s' "${selected_entry}"
  }
  export -f lru_entry
else
  echo "Duplicated func definition, ignoring: lru_entry @${BASH_SOURCE[0]}:${LINENO}"
fi
