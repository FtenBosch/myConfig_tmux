#!/usr/bin/env bash
set -euo pipefail

echo "################################"
echo "3. Configure tmux Bash settings"
echo "################################"
echo

# Get Git repository directory independently from cwd.
vcRepoDir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

fileTmuxBashrcSource="$vcRepoDir/.tmux_bashrc_config"
fileTmuxBashrcTarget="$HOME/.tmux_bashrc_config"
fileBashrc="$HOME/.bashrc"

# Make sure the repository configuration file exists.
if [[ ! -f "$fileTmuxBashrcSource" ]]; then
    echo "ERROR: tmux Bash configuration not found:"
    echo "  $fileTmuxBashrcSource"
    exit 1
fi


# Link .tmux_bashrc_config into $HOME.
if [[ ! -e "$fileTmuxBashrcTarget" && ! -L "$fileTmuxBashrcTarget" ]]; then
    # Nothing exists.
    echo "Linking: $fileTmuxBashrcTarget -> $fileTmuxBashrcSource"
    ln -v -s "$fileTmuxBashrcSource" "$fileTmuxBashrcTarget"

elif [[ -L "$fileTmuxBashrcTarget" && ! -e "$fileTmuxBashrcTarget" ]]; then
    # Broken symlink.
    echo "Replacing broken symlink: $fileTmuxBashrcTarget"
    unlink "$fileTmuxBashrcTarget"
    ln -v -s "$fileTmuxBashrcSource" "$fileTmuxBashrcTarget"

elif [[ -L "$fileTmuxBashrcTarget" ]]; then
    # Valid symlink.
    if [[ "$(readlink -f "$fileTmuxBashrcTarget")" == "$(readlink -f "$fileTmuxBashrcSource")" ]]; then
        echo "Already correctly linked: $fileTmuxBashrcTarget"
    else
        echo "WARNING: $fileTmuxBashrcTarget points somewhere else:"
        echo "  current: $(readlink "$fileTmuxBashrcTarget")"
        echo "  wanted:  $fileTmuxBashrcSource"
    fi

elif [[ -f "$fileTmuxBashrcTarget" ]]; then
    echo "WARNING: $fileTmuxBashrcTarget exists as a regular file."
    echo "Not overwriting it."

else
    echo "WARNING: $fileTmuxBashrcTarget exists and is neither a regular file nor symlink."
    echo "Not touching it."
fi


# Make sure ~/.bashrc exists.
touch "$fileBashrc"

# Add source statement only if it is not already present.
if [[ -z "$(sed -n '\|^source "\$HOME/\.tmux_bashrc_config"$|p' "$fileBashrc")" ]]; then
    echo "Adding tmux configuration source to: $fileBashrc"

    if [[ ! -s "$fileBashrc" ]]; then
        cat > "$fileBashrc" <<'EOF'
# Load tmux Bash configuration
source "$HOME/.tmux_bashrc_config"
EOF
    else
        sed -i '$a\
\
# Load tmux Bash configuration\
source "$HOME/.tmux_bashrc_config"' "$fileBashrc"
    fi
else
    echo "tmux configuration is already sourced by: $fileBashrc"
fi

echo
echo "Configured:"
echo "  $fileTmuxBashrcTarget -> $fileTmuxBashrcSource"
echo
echo "Start a new Bash shell or run:"
echo "  source \"$fileBashrc\""
