#!/bin/bash

pattern=$1

function capture_panes() {
    local pane captured current_pane captured_line
    captured=""
    current_pane=$(tmux display -pt "${TMUX_PANE:?}" '#{pane_index}')

    for pane in $(tmux list-panes -F "#{pane_index}"); do
      if [[ $pane != $current_pane ]]; then
            captured+="$(tmux capture-pane -pJS - -t $pane)"
            captured+=$'\n'
      fi
    done

    echo "$captured" | rg -oi "[a-zA-Z0-9_\-~\/]+\.\d*[da-zA-Z][a-zA-Z0-9]+[\:]\d+(?:[\:]\d+)?"  | cut -d' ' -f1 | rg "$pattern"
}

capture_panes
