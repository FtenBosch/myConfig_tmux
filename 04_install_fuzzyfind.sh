#!/usr/bin/env bash
set -euo pipefail

# Exit immediately if a command exits with a non-zero status
set -e

echo "########################"
echo "4. Installing fuzzy-find"
echo "########################"
echo 

echo "🔍 Checking fzf installation status"
if command -v fzf >/dev/null 2>&1; then
    echo "fzf already installed: $(fzf --version)"
    exit 0
else
    echo "fzf is not installed."
fi

echo "🔍 Detecting system package manager..."

# Check for apt (Ubuntu, Debian, Mint)
if command -v apt-get &> /dev/null; then
    echo "📦 Detected Ubuntu/Debian-based system (apt)."
    sudo apt-get update
    sudo apt-get install -y fzf

# Check for dnf (Fedora, RHEL, CentOS)
elif command -v dnf &> /dev/null; then
    echo "📦 Detected Fedora/RHEL-based system (dnf)."
    sudo dnf install -y fzf

# Check for pacman (Arch Linux, Manjaro)
elif command -v pacman &> /dev/null; then
    echo "📦 Detected Arch-based system (pacman)."
    sudo pacman -S --noconfirm fzf

# Check for zypper (openSUSE)
elif command -v zypper &> /dev/null; then
    echo "📦 Detected openSUSE system (zypper)."
    sudo zypper install -y fzf

# Fallback: Install via Git if no popular package manager is found
else
    echo "⚠️ No supported package manager found. Falling back to Git installation..."
    
    # Ensure git is installed
    if ! command -v git &> /dev/null; then
        echo "❌ Git is required for fallback installation but not found. Please install git manually."
        exit 1
    fi

    # Clone fzf official repository and run the install script
    if [ ! -d "$HOME/.fzf" ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    fi
    "$HOME/.fzf/install" --all
fi

# Verify installation
if command -v fzf &> /dev/null; then
    echo "🎉 fzf successfully installed! Version: $(fzf --version)"
else
    echo "❌ Installation failed or fzf is not in your PATH."
    exit 1
fi

