#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

scripts=(
    "01_setup_tmux_in_user-home.sh"
    "02_setup_tmux-plugins.sh"
    "03_setup_tmux_bashrc_config.sh"
    "04_install_fuzzyfind.sh"
)

for script in "${scripts[@]}"; do
    echo "------------------------------------------------------------"
    echo "Running: $script"
    echo "------------------------------------------------------------"

    (
        cd "$script_dir"
        bash "$script"
    )
done

echo "------------------------------------------------------------"
echo "Installation completed successfully."
echo "------------------------------------------------------------"
