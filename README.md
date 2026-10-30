# Bash Prompt

Prompt and terminal settings for bash:

- prompt with the current directory (last 2 levels) and git branch with status
- command duration when it takes longer than 5s
- highlight for production hosts (red banner) and SSH sessions
- large history, no duplicates, with timestamps, shared across sessions
- `fzf` (Ctrl-R / Ctrl-T) and `zoxide` (`z`) integration, when installed

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/rockberpro/bash-prompt/main/install.sh | bash
```

Or with `wget`:

```bash
wget -qO- https://raw.githubusercontent.com/rockberpro/bash-prompt/main/install.sh | bash
```

Or from a clone:

```bash
git clone https://github.com/rockberpro/bash-prompt.git
bash bash-prompt/install.sh
```

The installer copies `terminal.sh` to `~/.bashrc.d/` and appends this line to `~/.bashrc`:

```bash
[ -f ~/.bashrc.d/terminal.sh ] && . ~/.bashrc.d/terminal.sh
```

It can be run again to update; the line is not duplicated. Then open a new terminal or run `. ~/.bashrc`.

## Optional: Starship

Colored block prompt with icons, via [Starship](https://starship.rs). Install with `--starship`:

```bash
curl -fsSL https://raw.githubusercontent.com/rockberpro/bash-prompt/main/install.sh | bash -s -- --starship
```

The installer asks where to put `starship`: `~/.local/bin` (just you, no root needed; the default) or `/usr/local/bin` (all users, needs `sudo`). To skip the question, add `--local` or `--system`:

```bash
curl -fsSL https://raw.githubusercontent.com/rockberpro/bash-prompt/main/install.sh | bash -s -- --starship --local
```

It then asks which theme to use: option 1 (default) is this repo's `monokai` theme (`starship.toml`); the others come from `starship preset --list`. To skip the question, pass `--theme=<name>` (`monokai` or a preset name):

```bash
curl -fsSL https://raw.githubusercontent.com/rockberpro/bash-prompt/main/install.sh | bash -s -- --theme=tokyo-night
```

If `~/.config/starship.toml` doesn't exist yet, it is created with the chosen theme. An existing file is kept, unless you picked a theme (in the menu or with `--theme`): then it is saved as `~/.config/starship.toml.bak` and replaced. Without a terminal to ask, the default is used. When `starship` is on the `PATH`, `terminal.sh` uses it for the prompt; history, `fzf` and `zoxide` stay the same. To go back to the plain prompt, remove the binary: `rm ~/.local/bin/starship` or `sudo rm /usr/local/bin/starship`.

The icons require a [Nerd Font](https://www.nerdfonts.com) set in your terminal. To install JetBrainsMono:

```bash
mkdir -p ~/.local/share/fonts
curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz | tar -xJ -C ~/.local/share/fonts
fc-cache -f
```

Then select "JetBrainsMono Nerd Font" in your terminal preferences.

Other looks: `starship preset --list` and `starship preset <name> -o ~/.config/starship.toml`. To go back to this theme, copy this repo's `starship.toml` to `~/.config/`.

## Git status in the prompt

| Symbol | Meaning                  |
|--------|--------------------------|
| `*`    | unstaged changes         |
| `+`    | staged changes           |
| `%`    | untracked files          |
| `<`    | behind upstream          |
| `>`    | ahead of upstream        |
| `<>`   | diverged from upstream   |
| `=`    | in sync with upstream    |

## Customization

Edit `~/.bashrc.d/terminal.sh`:

- `__is_prod_host`: hostname patterns treated as production (default: `*prod*`, `*prd*`)
- `PROMPT_DIRTRIM`: how many directory levels to show
- `HISTSIZE` / `HISTFILESIZE`: history size

## Uninstall

```bash
rm ~/.bashrc.d/terminal.sh
sed -i '\|\. ~/.bashrc.d/terminal.sh$|d' ~/.bashrc
```
