#!/usr/bin/env bash
set -euo pipefail

echo "---------------------------------"
echo "1. Installing tmux configuration:"
echo "---------------------------------"

# get git Repo dir independently from cwd
vcRepoDir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

vcTmuxConfSource="$vcRepoDir/.tmux.conf"
vcTmuxConfTarget="$HOME/.tmux.conf"


# Case 1: .tmux.conf does not exist
if [[ ! -e "$vcTmuxConfTarget" && ! -L "$vcTmuxConfTarget" ]]; then
    # Nothing exists
    echo "Linking: $vcTmuxConfTarget -> $vcTmuxConfSource"
    ln -v -s "$vcTmuxConfSource" "$vcTmuxConfTarget"
elif [[ -L "$vcTmuxConfTarget" && ! -e "$vcTmuxConfTarget" ]]; then
    # Broken symlink
    echo "Replacing broken symlink: $vcTmuxConfTarget"
    unlink "$vcTmuxConfTarget"
    ln -v -s "$vcTmuxConfSource" "$vcTmuxConfTarget"
elif [[ -L "$vcTmuxConfTarget" ]]; then
    # Valid symlink
    if [[ "$(readlink -f "$vcTmuxConfTarget")" == "$(readlink -f "$vcTmuxConfSource")" ]]; then
        echo "Already correctly linked: $vcTmuxConfTarget"
    else
        echo "WARNING: $vcTmuxConfTarget points somewhere else:"
        echo "  current: $(readlink "$vcTmuxConfTarget")"
        echo "  wanted:  $vcTmuxConfSource"
    fi
elif [[ -f "$vcTmuxConfTarget" ]]; then
    echo "WARNING: $vcTmuxConfTarget exists as a regular file."
    echo "Not overwriting it."
else
    echo "WARNING: $vcTmuxConfTarget exists and is neither a regular file nor symlink."
    echo "Not touching it."
fi

# Symlink the "resurrect" scripts into the ~/.tmux/bin directory
dirTmuxBinTarget="$HOME/.tmux/bin"
mkdir -p "$dirTmuxBinTarget"

for vcFileSource in "$vcRepoDir"/.tmux/bin/*; do
    vcFileTarget="$dirTmuxBinTarget/$(basename "$vcFileSource")"

    if [[ ! -e "$vcFileTarget" && ! -L "$vcFileTarget" ]]; then
        echo "Linking: $vcFileTarget -> $vcFileSource"
        ln -s "$vcFileSource" "$vcFileTarget"

    elif [[ -L "$vcFileTarget" && ! -e "$vcFileTarget" ]]; then
        echo "Replacing broken symlink: $vcFileTarget"
        unlink "$vcFileTarget"
        ln -s "$vcFileSource" "$vcFileTarget"

    elif [[ -L "$vcFileTarget" ]]; then
        if [[ "$(readlink -f "$vcFileTarget")" == "$(readlink -f "$vcFileSource")" ]]; then
            echo "Already correctly linked: $vcFileTarget"
        else
            echo "WARNING: $vcFileTarget points somewhere else:"
            echo "  current: $(readlink "$vcFileTarget")"
            echo "  wanted:  $vcFileSource"
        fi

    elif [[ -f "$vcFileTarget" ]]; then
        echo "WARNING: $vcFileTarget exists as a regular file."
        echo "Not overwriting it."

    else
        echo "WARNING: $vcFileTarget exists and is neither a regular file nor symlink."
        echo "Not touching it."
    fi
done


