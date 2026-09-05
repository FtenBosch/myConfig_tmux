#!/usr/bin/env bash
set -euo pipefail
fileResurrect="${1:-}"
pathTmuxResurrect="${2:-}"

# Basic checks
if [[ -z "${fileResurrect}" ]]; then
  tmux display-message "No name provided"; exit 0
fi

if [[ ! "${fileResurrect}" =~ ^[[:alnum:]_.-]+$ ]]; then
  tmux display-message "Invalid snapshot name: ${fileResurrect}"
  exit 1
fi

if [[ "${fileResurrect}" == "last" ]]; then
  tmux display-message "Snapshot name 'last' is reserved"
  exit 1
fi
if [[ -z "${pathTmuxResurrect}" ]]; then
  pathTmuxResurrect="$HOME/.tmux/resurrect"
fi

# Expand ~ if present (defensive, though #{home} avoids it)
pathTmuxResurrect="${pathTmuxResurrect/#\~/$HOME}"

if [[ ! -d "${pathTmuxResurrect}" ]]; then
  tmux display-message "Resurrect directory not found, so will be creating it: ${pathTmuxResurrect}"; 
  mkdir -p "${pathTmuxResurrect}"
fi

# Save snapshot via tmux-resurrect, then copy 'last' to the chosen fileResurrect
~/.tmux/plugins/tmux-resurrect/scripts/save.sh >/dev/null || {
  tmux display-message "resurrect save failed!";
  exit 1;
}

# Save snapshot
if cp -f "${pathTmuxResurrect}/last" "${pathTmuxResurrect}/${fileResurrect}"; then
  tmux display-message "Saved snapshot as: ${fileResurrect}"
else
  tmux display-message "Saving snapshot failed!"
  exit 1
fi
