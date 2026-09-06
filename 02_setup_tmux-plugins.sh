#!/usr/bin/env bash
set -euo pipefail

# Prerequisite check: git installation
if ! command -v git >/dev/null 2>&1; then
    echo "ERROR: git is not installed or not available in PATH."
    exit 1
fi

echo "###########################"
echo "2. Checking/installing TPM:"
echo "###########################"
echo

mkdir -v -p "$HOME/.tmux/plugins"

# Soft install "tpm" plugin
dirTpmPlugin="$HOME/.tmux/plugins/tpm"

if [[ -d "$dirTpmPlugin/.git" ]]; then
  # Make sure the installed git repo is actually "github.com/tmux-plugins/tpm" and not something else
  strGitRemote="$(git -C "$dirTpmPlugin" remote get-url origin 2>/dev/null || true)"
  if [[ "$strGitRemote" == "https://github.com/tmux-plugins/tpm" ||
        "$strGitRemote" == "https://github.com/tmux-plugins/tpm.git" ]]; then
      echo "TPM already installed: $dirTpmPlugin"
  else
      echo "WARNING: $dirTpmPlugin is a Git repository,"
      echo "but its origin is not tmux-plugins/tpm:"
      echo "  $strGitRemote"
      exit 1
  fi
elif [[ -d "$dirTpmPlugin" ]] && \
     [[ -n "$(find "$dirTpmPlugin" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
    echo "WARNING: TPM target directory exists and is not empty:"
    echo "  $dirTpmPlugin"
    echo "It does not contain a .git directory."
    echo "TPM will NOT be cloned."
    exit 1
elif [[ -e "$dirTpmPlugin" && ! -d "$dirTpmPlugin" ]]; then
    echo "WARNING: TPM target exists but is not a directory:"
    echo "  $dirTpmPlugin"
    echo "TPM will NOT be cloned."
    exit 1
else
    echo "Cloning tmux plugin manager TPM:"
    git clone https://github.com/tmux-plugins/tpm "$dirTpmPlugin"
fi

echo "--------------------------------------------"
echo "TPM Setup completed."
echo "--------------------------------------------"

