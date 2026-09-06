# MyConfig_tmux

---

## Installation

See [INSTALL.md](INSTALL.md) for installation and initial setup.

---

## What is this?

Personal tmux configuration and setup scripts with:

- 🪆 Nesting-level-dependent tmux leader key configurations
- 🪟 Pane and window management shortcuts
- 🔌 TPM-based plugin management
- 💾 Integration of `tmux-resurrect` plugin
- 🏷️  Named resurrect snapshots
- 🔎 `fzf`-based snapshot restore picker
- 🔧 Setup scripts for installing the configuration into the user's home directory
- 🐚 Bash environment configuration for selecting the tmux nesting level

--- 

## Repository structure

```text
.
├── 01_setup_tmux_in_user-home.sh
├── 02_setup_tmux-plugins.sh
├── 03_setup_tmux_bashrc_config.sh
├── 04_install_fuzzyfind.sh
├── INSTALL.md
├── install.sh
├── README.md
├── .tmux.conf
└── .tmux
    └── bin
        ├── tmux_named_resurrect_restore.sh
        └── tmux_named_resurrect_save.sh
```

---

## Requirements

The configuration expects:

* Bash
* tmux 3.2 or newer
* Git
* `fzf` for the interactive resurrect restore picker (will be installed if not yet available)

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

## General tmux configuration

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

## Key bindings

### Key bindings: Window management

| Binding | Action |
|---|---|
| `<leaderkey> r` | Reload `~/.tmux.conf` |
| `<leaderkey> Alt-s` | Enter copy mode |
| `<leaderkey> Ctrl-k` | Kill current session |
| `<leaderkey> c` | Create window in current directory |
| `<leaderkey> n` | Go to next window |
| `<leaderkey> p` | Go to previous window |
| `<leaderkey> l` | Go to most recently used ("last") window |
| `<leaderkey> s` | Swap window numbers |

### Key bindings: Pane management

| Binding | Action |
|---|---|
| `<leaderkey> "` or `<leaderkey> h` | `split-window -v` |
| `<leaderkey> %` or `<leaderkey> v` | `split-window -h` |
| `<leaderkey> j` | Move/reparent current pane |
| `Alt-↑/↓/←/→` | Select adjacent pane |

---

## Plugins

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

### tmux-resurrect

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

#### Save a named snapshot

Use:

```text
<leaderkey> Ctrl-s
```

tmux opens a prompt:

```text
Save name:
```

The current tmux session name is used as the initial value.

##### Behaviour 

The wrapper first runs tmux-resurrect's normal `save.sh`, then copies the resulting snapshot file referenced by the symlink `~/.tmux/resurrect/last` to the requested snapshot name. Reusing a name silently replaces that named snapshot.

The normal timestamped `tmux-resurrect` snapshots remain available independently.

##### Valid snapshot names

Snapshot names may contain letters, digits, `.`, `_`, and `-`; `last` is reserved. Names containing spaces, path separators, shell characters, or other unsupported characters are rejected.

##### Retention duration

Named snapshots are kept until overwritten or manually deleted.
tmux-resurrect's timestamped `tmux_resurrect_*.txt` backups remain subject to tmux-resurrect's normal retention policy.

#### Restore a snapshot

Use:

```text
<leaderkey> Ctrl-r
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

##### Relative `last` symlink

After selecting a snapshot, the restore wrapper creates:

```text
~/.tmux/resurrect/last
```

as a relative symbolic link to the selected snapshot.
The wrapper then invokes:

```text
~/.tmux/plugins/tmux-resurrect/scripts/restore.sh
```

which reads the selected snapshot through `last`.

---

## Normal workflow

Save a named snapshot:

```text
<leaderkey> Ctrl-s
```

Restore a snapshot using the `fzf` picker:

```text
<leaderkey> Ctrl-r
```

Reload the tmux configuration after modifying `.tmux.conf`:

```text
<leaderkey> r
```

Because the files installed under `$HOME` are symbolic links into this repository, changes to:

```text
.tmux.conf
.tmux/bin/
```

immediately become the installed configuration.

---

## tmux nesting levels and leaderkey keys

The tmux leaderkey is selected using:

```bash
TMUX_NESTING_LEVEL
```

The configuration supports three designated nesting levels:

| Nesting level | Leaderkey | Intended use        |
| ------------- | --------- | ------------------- |
| `0`           | `Alt-w`   | normal / outer tmux |
| `1`           | `Ctrl-b`  | first nested tmux   |
| `2`           | `Ctrl-b`  | second nested tmux  |

If `TMUX_NESTING_LEVEL` is not set, the configuration defaults to level `0`.

The environment variable is included in tmux's `update-environment` list:

```tmux
set -ag update-environment " TMUX_NESTING_LEVEL"
```

### Addressing nested tmux levels

With three nested tmux instances:

```text
Level 0
leaderkey: Alt-w
    │
    └── Level 1
        leaderkey: Ctrl-b
            │
            └── Level 2
                leaderkey: Ctrl-b
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

The configuration binds the leaderkey itself to `send-prefix`, so:

```text
Ctrl-b Ctrl-b
```

sends a `Ctrl-b` leaderkey through the level-1 tmux instance to level 2.

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

