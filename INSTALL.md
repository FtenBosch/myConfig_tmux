# MyConfig_tmux Installation

## Quickstart

1. Clone this repository to a permanent location.

```bash
git clone https://github.com/FtenBosch/myConfig_tmux MyConfig_tmux
cd MyConfig_tmux
```

2. Run install script

```bash
./install.sh
```
to execute all individual installation steps in order as described below.

3. Load the new Bash configuration

```bash
source ~/.bashrc
```

Alternatively, start a new bash.

The setup uses symbolic links from the user's home directory into the repository. Therefore the repository should not be moved afterwards without recreating those links.

---

## Manual initial setup

### 1. Clone the repository

```bash
git clone https://github.com/FtenBosch/myConfig_tmux MyConfig_tmux
cd MyConfig_tmux
```

### 2. Install the tmux configuration into `$HOME`

Run:
```bash
./01_setup_tmux_in_user-home.sh
```

The script determines the repository directory from its own location using `BASH_SOURCE`, so it does not have to be executed from the repository's working directory.

It installs symbolic links for:

```text
~/.tmux.conf
~/.tmux/bin/tmux_named_resurrect_save.sh
~/.tmux/bin/tmux_named_resurrect_restore.sh
```

The setup deliberately handles existing paths conservatively.

The script safely creates the required symlinks. Existing correct links are
left unchanged, broken links are repaired, and unrelated existing files or
links are never overwritten.

This makes the setup script safe to run repeatedly.

### 3. Install TPM

Run:

```bash
./02_setup_tmux-plugins.sh
```

The script installs TPM under `~/.tmux/plugins/tpm`. If that directory
already contains a Git checkout, its `origin` is verified before it is
accepted. Existing unrelated contents are never overwritten.

### 4. Configure the tmux nesting level

Run:

```bash
./03_setup_tmux_bashrc_config.sh
```

The script asks for:

```text
TMUX_NESTING_LEVEL [0-2]:
```

Available values are:

```text
0 = normal / outer tmux session
1 = first nested tmux session
2 = second nested tmux session
```

The script creates:

```text
~/.tmux_bashrc_config
```

containing, for example:

```bash
export TMUX_NESTING_LEVEL=0
```

It also makes sure that the following line ... 

```bash
source "$HOME/.tmux_bashrc_config"
```

... exists in:

```text
~/.bashrc
```

The source line is added only if it is not already present.

### 5. Install fzf (fuzzy finder)

Run:

```bash
./04_install_fuzzyfind.sh
```
### 6. Load the new Bash configuration

Run:

```bash
source ~/.bashrc
```

Alternatively, start a new Bash shell.

### 7. Start or enter tmux.

Start tmux:
```bash
tmux
```

In tmux, reload `.tmux.conf`:

```text
<leaderkey> r
```

### 8. Install plugins

Install the configured plugins through TPM with:

```text
<leaderkey> I
```

Capital `I` is the standard TPM plugin-install binding.

