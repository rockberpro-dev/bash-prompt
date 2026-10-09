#!/usr/bin/env bash
# Instala o terminal.sh em ~/.bashrc.d/ e o carrega no fim do ~/.bashrc.
#   local:  bash install.sh [--starship]      (com os arquivos na mesma pasta)
#   remoto: curl -fsSL <url>/install.sh | bash [-s -- --starship]
# --starship: instala também o starship em ~/.local/bin, com o tema Monokai Soda (starship.toml)
set -euo pipefail

# Onde os arquivos estão publicados (usado quando não há cópia local)
BASE_URL=${BASH_PROMPT_URL:-https://raw.githubusercontent.com/rockberpro/bash-prompt/main}

fetch() { if command -v curl >/dev/null; then curl -fsSL "$1"; else wget -qO- "$1"; fi; }

# install_file <nome no repo> <destino>: copia do clone local ou baixa do BASE_URL
src_dir=${BASH_SOURCE[0]:+$(dirname "${BASH_SOURCE[0]}")}
install_file() {
  if [[ -n $src_dir && -f $src_dir/$1 ]]; then
    [[ $(realpath "$src_dir/$1") == $(realpath "$2") ]] || cp "$src_dir/$1" "$2"
  else
    fetch "$BASE_URL/$1" > "$2.tmp"
    mv "$2.tmp" "$2"
  fi
}

mkdir -p ~/.bashrc.d
install_file terminal.sh ~/.bashrc.d/terminal.sh

line='[ -f ~/.bashrc.d/terminal.sh ] && . ~/.bashrc.d/terminal.sh'
grep -qxF "$line" ~/.bashrc 2>/dev/null || printf '\n%s\n' "$line" >> ~/.bashrc

if [[ ${1:-} == --starship ]]; then
  if ! command -v starship >/dev/null && [[ ! -x ~/.local/bin/starship ]]; then
    mkdir -p ~/.local/bin
    fetch https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin
  fi
  mkdir -p ~/.config
  if [[ -f ~/.config/starship.toml ]]; then
    echo "~/.config/starship.toml já existe, mantido (o tema Monokai Soda não foi aplicado)"
  else
    install_file starship.toml ~/.config/starship.toml
  fi
  [[ :$PATH: == *:$HOME/.local/bin:* ]] || echo "Atenção: adicione ~/.local/bin ao PATH antes do terminal.sh no ~/.bashrc"
  echo "Starship instalado. Use uma Nerd Font no terminal para ver os ícones (veja o README)."
fi

echo "Instalado. Abra um novo terminal ou rode: . ~/.bashrc"
