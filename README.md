````markdown
# MyConfig_tmux

Personal tmux configuration and setup scripts with:

- nesting-level-dependent tmux prefix keys
- pane and window management shortcuts
- TPM-based plugin management
- `tmux-resurrect` integration
- named resurrect snapshots
- `fzf`-based snapshot restore picker
- setup scripts for installing the configuration into the user's home directory
- Bash environment configuration for selecting the tmux nesting level

## Repository structure

```text
.
├── 01_setup_tmux_in_user-home.sh
├── 02_setup_tmux-plugins.sh
├── 03_setup_tmux_bashrc_config.sh
├── README.md
├── .tmux.conf
└── .tmux
    └── bin
        ├── tmux_named_resurrect_restore.sh
        └── tmux_named_resurrect_save.sh
````

## Requirements

The configuration expects:

* Bash
* tmux 3.2 or newer
* Git
* `fzf` for the interactive resurrect restore picker

The following tmux plugins are configured through TPM:

* `tmux-plugins/tpm`
* `tmux-plugins/tmux-resurrect`
* `tmux-plugins/tmux-yank`
* `tmux-plugins/vim-tmux-focus-events`
* `nordtheme/tmux`

There is deliberately no `tmux-sensible` dependency. This repository itself contains the personal tmux baseline configuration.

`tmux-resurrect` snapshots are stored under:

```text
~/.tmux/resurrect
```

---

# Installation

Clone this repository to a permanent location.

The setup uses symbolic links from the user's home directory into the repository. Therefore the repository should not be moved afterwards without recreating those links.

## 1. Install the tmux configuration into `$HOME`

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

For each managed symlink:

* if the target does not exist, the symlink is created
* if the correct symlink already exists, nothing is changed
* if an existing symlink is broken, it is replaced
* if a valid symlink points somewhere else, a warning is shown and it is left unchanged
* if a regular file already exists, a warning is shown and it is not overwritten
* if another type of filesystem object exists at the target location, it is left untouched

This makes the setup script safe to run repeatedly.

## 2. Install TPM

Run:

```bash
./02_setup_tmux-plugins.sh
```

The script first verifies that `git` is available.

It creates:

```text
~/.tmux/plugins
```

and installs TPM into:

```text
~/.tmux/plugins/tpm
```

If TPM is already present as a Git repository, its `origin` remote is checked.

Accepted remotes are:

```text
https://github.com/tmux-plugins/tpm
https://github.com/tmux-plugins/tpm.git
```

If the target directory exists and contains files but is not a TPM Git checkout, the script stops with a warning instead of overwriting it.

## 3. Configure the tmux nesting level

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

It also makes sure that the following line exists in:

```text
~/.bashrc
```

```bash
source "$HOME/.tmux_bashrc_config"
```

The source line is added only if it is not already present.

After changing the nesting level, either start a new Bash shell or run:

```bash
source ~/.bashrc
```

The setup script itself should normally be executed:

```bash
./03_setup_tmux_bashrc_config.sh
```

rather than sourced.

## 4. Load the tmux configuration and install plugins

Inside tmux, reload the configuration with:

```text
<prefix> r
```

Then install the configured plugins through TPM with:

```text
<prefix> I
```

Capital `I` is the standard TPM plugin-install binding.

---

# tmux nesting levels and prefix keys

The tmux prefix is selected using:

```bash
TMUX_NESTING_LEVEL
```

The configuration supports three designated nesting levels:

| Nesting level | Prefix   | Intended use        |
| ------------- | -------- | ------------------- |
| `0`           | `Alt-w`  | normal / outer tmux |
| `1`           | `Ctrl-b` | first nested tmux   |
| `2`           | `Ctrl-b` | second nested tmux  |

If `TMUX_NESTING_LEVEL` is not set, the configuration defaults to level `0`.

The environment variable is included in tmux's `update-environment` list:

```tmux
set -ag update-environment " TMUX_NESTING_LEVEL"
```

## Addressing nested tmux levels

With three nested tmux instances:

```text
Level 0
prefix: Alt-w
    │
    └── Level 1
        prefix: Ctrl-b
            │
            └── Level 2
                prefix: Ctrl-b
```

Commands for level 0 use:

```text
Alt-w <command>
```

For example:

```text
Alt-w c
```

creates a new window in the outer tmux instance.

Commands for level 1 use:

```text
Ctrl-b <command>
```

For example:

```text
Ctrl-b c
```

creates a new window in the first nested tmux instance.

Levels 1 and 2 both use `Ctrl-b`.

The configuration binds the prefix key itself to `send-prefix`, so:

```text
Ctrl-b Ctrl-b
```

sends a `Ctrl-b` prefix through the level-1 tmux instance to level 2.

Therefore a command for level 2 looks like:

```text
Ctrl-b Ctrl-b <command>
```

For example:

```text
Ctrl-b Ctrl-b c
```

creates a new window in the level-2 tmux instance.

---

# General tmux configuration

The configuration includes:

```text
Default shell:       /bin/bash
History limit:       50000 lines
Mouse support:       enabled
Focus events:        enabled
Copy mode keys:      vi
Window numbering:    starts at 1
Pane numbering:      starts at 1
Automatic renaming:  enabled
Terminal type:       screen-256color
```

The configuration uses:

```tmux
set -sg escape-time 0
```

and enables true-color support with:

```tmux
set -ga terminal-overrides ",*256col*:Tc"
```

---

# Key bindings

In the descriptions below:

```text
<prefix>
```

means either:

```text
Alt-w
```

for nesting level `0`, or:

```text
Ctrl-b
```

for nesting levels `1` and `2`.

## Reload configuration

```text
<prefix> r
```

Reloads:

```text
~/.tmux.conf
```

## Copy mode

```text
<prefix> Alt-s
```

Enters tmux copy mode.

This provides an alternative to the default:

```text
<prefix> [
```

which is inconvenient on a German keyboard because `[` normally requires `AltGr`.

## Kill session

```text
<prefix> Ctrl-k
```

Kills the current tmux session.

---

# Pane management

## Split panes

Both the standard tmux split keys and mnemonic alternatives are available.

Create a pane above/below the current pane:

```text
<prefix> "
```

or:

```text
<prefix> h
```

Both execute:

```tmux
split-window -v
```

Create a pane beside the current pane:

```text
<prefix> %
```

or:

```text
<prefix> v
```

Both execute:

```tmux
split-window -h
```

New panes inherit the current pane's working directory:

```tmux
-c "#{pane_current_path}"
```

## Select panes with Alt + arrow keys

These bindings do not require the tmux prefix:

```text
Alt-Up      select pane above
Alt-Down    select pane below
Alt-Left    select pane left
Alt-Right   select pane right
```

## Move / reparent panes

Use:

```text
<prefix> j
```

The currently selected pane is marked and a tmux menu is opened.

Available directions are:

```text
l   Left
r   Right
k   Above
j   Below
```

After choosing the desired direction, tmux displays the available target panes.

Selecting a target reparents the marked source pane using `join-pane`.

---

# Window management

## Create a new window

```text
<prefix> c
```

The new window starts in the current pane's working directory.

## Swap window numbers

```text
<prefix> s
```

tmux prompts for:

```text
swap-window from:
```

followed by:

```text
swap-window to:
```

and swaps the corresponding windows.

---

# Plugins

Plugins are declared in `.tmux.conf` and loaded through TPM.

Configured plugins are:

```text
tmux-plugins/tpm
tmux-plugins/tmux-resurrect
tmux-plugins/tmux-yank
tmux-plugins/vim-tmux-focus-events
nordtheme/tmux
```

TPM is initialized with:

```tmux
run '~/.tmux/plugins/tpm/tpm'
```

---

# tmux-resurrect

`tmux-resurrect` provides tmux session persistence.

This repository adds two wrapper scripts:

```text
~/.tmux/bin/tmux_named_resurrect_save.sh
~/.tmux/bin/tmux_named_resurrect_restore.sh
```

They provide:

* named resurrect snapshots
* silent replacement of an existing named snapshot
* an `fzf` restore picker
* restoration through tmux-resurrect's normal `restore.sh`

The snapshot directory is configured as:

```text
~/.tmux/resurrect
```

---

# Save a named snapshot

Use:

```text
<prefix> Ctrl-s
```

tmux opens a prompt:

```text
Save name:
```

The current tmux session name is used as the initial value.

The wrapper first invokes:

```text
~/.tmux/plugins/tmux-resurrect/scripts/save.sh
```

which creates or updates:

```text
~/.tmux/resurrect/last
```

The resulting snapshot is then copied to the selected snapshot name.

For example:

```text
Save name: Work
```

creates or replaces:

```text
~/.tmux/resurrect/Work
```

Saving again using the same name silently replaces the existing named snapshot.

The normal timestamped `tmux-resurrect` snapshots remain available independently.

## Valid snapshot names

Named snapshots may contain:

```text
letters
digits
_
-
.
```

Examples:

```text
Work
Home
Fedora-Dev
project_01
before-upgrade
2026-09-06
```

Names containing spaces, path separators, shell characters, or other unsupported characters are rejected.

The name:

```text
last
```

is reserved and cannot be used as a named snapshot.

`tmux-resurrect` uses that pathname to select the snapshot that should be restored.

If:

```text
~/.tmux/resurrect
```

does not yet exist, the save wrapper creates it automatically.

---

# Restore a snapshot

Use:

```text
<prefix> Ctrl-r
```

This opens an 80% x 80% tmux popup containing an `fzf` picker.

The restore script changes temporarily into:

```text
~/.tmux/resurrect
```

and builds the selection list from the regular snapshot files in that directory.

The rolling:

```text
last
```

symlink is excluded.

Snapshots are sorted by modification time, newest first.

The picker can contain both:

* automatically generated `tmux-resurrect` snapshots
* manually created named snapshots

Only the snapshot filename is passed through the picker.

Examples:

```text
Work
Home
tmux_resurrect_20260906T001234.txt
```

A preview of the beginning of the selected snapshot is shown using:

```bash
sed -n 1,40p
```

If the picker is cancelled, no restore operation is performed.

## Relative `last` symlink

After selecting a snapshot, the restore wrapper creates:

```text
~/.tmux/resurrect/last
```

as a relative symbolic link to the selected snapshot.

For example:

```text
last -> Work
```

rather than:

```text
last -> /home/user/.tmux/resurrect/Work
```

The wrapper then invokes:

```text
~/.tmux/plugins/tmux-resurrect/scripts/restore.sh
```

which reads the selected snapshot through `last`.

---

# Typical initial setup

Clone the repository:

```bash
git clone <repository-url> MyConfig_tmux
cd MyConfig_tmux
```

Install the configuration:

```bash
./01_setup_tmux_in_user-home.sh
```

Install TPM:

```bash
./02_setup_tmux-plugins.sh
```

Configure the desired tmux nesting level:

```bash
./03_setup_tmux_bashrc_config.sh
```

Load the new Bash configuration:

```bash
source ~/.bashrc
```

Start or enter tmux.

Reload `.tmux.conf`:

```text
<prefix> r
```

Install the configured TPM plugins:

```text
<prefix> I
```

---

# Normal workflow

Save a named snapshot:

```text
<prefix> Ctrl-s
```

Restore a snapshot using the `fzf` picker:

```text
<prefix> Ctrl-r
```

Reload the tmux configuration after modifying `.tmux.conf`:

```text
<prefix> r
```

Because the files installed under `$HOME` are symbolic links into this repository, changes to:

```text
.tmux.conf
.tmux/bin/
```

immediately become the installed configuration.

```
```

