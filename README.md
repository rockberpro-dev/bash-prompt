# Bash Prompt

Prompt and terminal settings for bash.

- Prompt with the last 2 directory levels and git branch + status
- Command duration when it takes longer than 5s
- Red banner on production hosts, highlight on SSH sessions
- Large shared history, no duplicates, with timestamps
- `fzf` (Ctrl-R / Ctrl-T) and `zoxide` (`z`) when installed
- `bat` / `fd` aliases for Ubuntu's `batcat` / `fdfind`

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/rockberpro-dev/bash-prompt/main/install.sh | bash
```

Or use `wget -qO-` instead of `curl -fsSL`, or clone the repo and run `bash install.sh`. Then open a new terminal.

## Starship (optional)

Colored block prompt with icons, via [Starship](https://starship.rs):

```bash
curl -fsSL https://raw.githubusercontent.com/rockberpro-dev/bash-prompt/main/install.sh | bash -s -- --starship
```

| Flag               | Effect                                                    |
|--------------------|-----------------------------------------------------------|
| `--starship`       | install Starship (asks for location, theme and font)      |
| `--local` / `--system` | binary in `~/.local/bin` / `/usr/local/bin` (sudo)    |
| `--theme=<name>`   | `monokai` (default) or a name from `starship preset --list` |
| `--font=<name>`    | Nerd Font (default `JetBrainsMono`) or `none`             |

Any of these flags implies `--starship`. Select the installed Nerd Font in your terminal preferences to see the icons.

## Uninstall

```bash
rm ~/.bashrc.d/terminal.sh
sed -i '\|\. ~/.bashrc.d/terminal.sh$|d' ~/.bashrc
```

Details (Starship, fonts, git status symbols, customization, full uninstall): [GUIDE.md](GUIDE.md)
