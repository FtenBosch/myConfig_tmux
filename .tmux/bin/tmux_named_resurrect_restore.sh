#!/usr/bin/env bash

# Target path for this script: 
# ~/.tmux/bin/tmux_named_resurrect_restore.sh
set -euo pipefail

pathTmuxResurrect="${1:-$HOME/.tmux/resurrect}"
pathTmuxResurrect="${pathTmuxResurrect/#\~/$HOME}"

# 1) prerequisites
if ! command -v fzf >/dev/null 2>&1; then
  echo "fzf not found (try: sudo dnf install fzf)"; read -n1 -s -r -p "Close"; echo; exit 0
fi
if [[ ! -d "${pathTmuxResurrect}" ]]; then
  echo "No resurrect directory at: ${pathTmuxResurrect}"; read -n1 -s -r -p "Close"; echo; exit 0
fi

# 2) choose *absolute* path (exclude the rolling 'last')
nameSelectedSnapshot="$(
  cd -- "${pathTmuxResurrect}"

  find . -maxdepth 1 -type f ! -name last -printf '%T@\t%f\n' \
    | sort -nr \
    | cut -f2- \
    | fzf \
        --prompt='Restore> ' \
        --reverse \
        --height=100% \
        --preview='sed -n 1,40p -- {}'
  )" || true
[[ -z "${nameSelectedSnapshot}" ]] && exit 0

# 3) point 'last' to the chosen file (this is what restore.sh reads)
ln -sfn -- "${nameSelectedSnapshot}" "${pathTmuxResurrect}/last"

# 4) restore (no args; restore.sh reads ${pathTmuxResurrect}/last internally)
echo "Restoring via symlink:"
ls -l -- "${pathTmuxResurrect}/last"

~/.tmux/plugins/tmux-resurrect/scripts/restore.sh

echo "Restored: ${nameSelectedSnapshot}"
sleep 0.4

