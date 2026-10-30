# Guide

## What the installer does

- Copies `terminal.sh` to `~/.bashrc.d/` and appends this line to `~/.bashrc`:
  ```bash
  [ -f ~/.bashrc.d/terminal.sh ] && . ~/.bashrc.d/terminal.sh
  ```
- Can be run again to update; the line is not duplicated.
- Files come from the local clone when present, otherwise from `BASH_PROMPT_URL` (default: this repo's `main` on GitHub).

## Starship

Run the installer with `--starship` (or any of `--local`, `--system`, `--theme=`, `--font=`).

**Binary location.** Without `--local`/`--system` the installer asks: `~/.local/bin` (default, no root) or `/usr/local/bin` (needs `sudo`; falls back to `~/.local/bin` if there is no `sudo`). If `~/.local/bin` is not on your `PATH`, add it before `terminal.sh` is loaded in `~/.bashrc`.

**Theme.** Option 1 is this repo's `monokai` theme (`starship.toml`); the rest come from `starship preset --list` (presets that only tweak symbols are hidden). Or pass `--theme=<name>`.

**Existing config.** If `~/.config/starship.toml` doesn't exist, it is created with the chosen theme. If it exists, it is kept, unless you picked a theme (menu or `--theme`): then it is saved as `~/.config/starship.toml.bak` and replaced. Without a terminal to ask, defaults are used.

**Changing theme later**

```bash
starship preset <name> -o ~/.config/starship.toml
```

To go back to `monokai`, copy this repo's `starship.toml` to `~/.config/`.

**Going back to the plain prompt.** When `starship` is on the `PATH`, `terminal.sh` uses it for the prompt (history, `fzf` and `zoxide` stay the same). Remove the binary:

```bash
rm ~/.local/bin/starship        # or: sudo rm /usr/local/bin/starship
```

## Nerd Font

Starship's icons need a [Nerd Font](https://www.nerdfonts.com).

- The installer asks which font to install: option 1 (default) is JetBrainsMono, the last option skips it.
- Or pass `--font=<name>`: any name from the [nerd-fonts releases](https://github.com/ryanoasis/nerd-fonts/releases), or `none`.
- Installed to `~/.local/share/fonts/<name>/`; the cache is refreshed with `fc-cache -f`. Needs `xz` (otherwise the font is skipped).
- Then select it (e.g. "JetBrainsMono Nerd Font") in your terminal preferences.

Remove:

```bash
rm -rf ~/.local/share/fonts/<name> && fc-cache -f
```

## Plain prompt (without Starship)

Git status in the prompt:

| Symbol | Meaning                |
|--------|------------------------|
| `*`    | unstaged changes       |
| `+`    | staged changes         |
| `%`    | untracked files        |
| `<`    | behind upstream        |
| `>`    | ahead of upstream      |
| `<>`   | diverged from upstream |
| `=`    | in sync with upstream  |

Production hosts get a red banner, SSH sessions a purple directory and `user@host`.

Edit `~/.bashrc.d/terminal.sh` to customize:

- `__is_prod_host`: hostname patterns treated as production (default: `*prod*`, `*prd*`)
- `PROMPT_DIRTRIM`: how many directory levels to show
- `HISTSIZE` / `HISTFILESIZE`: history size

These only apply to the plain prompt; with Starship active, the prompt comes from `~/.config/starship.toml`.

## Full uninstall

```bash
rm ~/.bashrc.d/terminal.sh
sed -i '\|\. ~/.bashrc.d/terminal.sh$|d' ~/.bashrc
rm -f ~/.local/bin/starship ~/.config/starship.toml   # if you installed Starship
```

Use `sudo rm /usr/local/bin/starship` if it was installed system-wide; remove the font as shown above.
