#!/usr/bin/env bash
# Instala o terminal.sh em ~/.bashrc.d/ e o carrega no fim do ~/.bashrc.
#   local:  bash install.sh [--starship] [--local|--system]   (com os arquivos na mesma pasta)
#   remoto: curl -fsSL <url>/install.sh | bash [-s -- --starship [--local|--system]]
# --starship: instala também o starship, com o tema Monokai Soda (starship.toml)
#   --local:  starship em ~/.local/bin (só para você, sem root)
#   --system: starship em /usr/local/bin (todos os usuários, precisa de sudo)
#   sem nenhum dos dois, pergunta onde instalar
set -euo pipefail

starship=0
bin_dir=
for arg in "$@"; do
  case $arg in
    --starship) starship=1 ;;
    --local)    starship=1; bin_dir=$HOME/.local/bin ;;
    --system)   starship=1; bin_dir=/usr/local/bin ;;
    *) echo "Opção desconhecida: $arg" >&2; exit 1 ;;
  esac
done

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

if (( starship )); then
  if [[ -z $bin_dir ]]; then
    bin_dir=$HOME/.local/bin
    # no "curl | bash" o stdin é o próprio script, então a resposta vem do terminal
    if { exec 3</dev/tty; } 2>/dev/null; then
      echo "Onde instalar o starship?"
      echo "  1) ~/.local/bin   (só para você, sem root) [padrão]"
      echo "  2) /usr/local/bin (todos os usuários, precisa de sudo)"
      read -rp "Escolha [1]: " ans <&3 || ans=
      exec 3<&-
      [[ $ans == 2 ]] && bin_dir=/usr/local/bin
    fi
  fi
  if [[ $bin_dir == /usr/local/bin && ! -w $bin_dir ]] && ! command -v sudo >/dev/null; then
    echo "Sem permissão em $bin_dir e sem sudo, usando ~/.local/bin" >&2
    bin_dir=$HOME/.local/bin
  fi
  if ! command -v starship >/dev/null && [[ ! -x $bin_dir/starship ]]; then
    [[ $bin_dir == "$HOME/.local/bin" ]] && mkdir -p "$bin_dir"
    fetch https://starship.rs/install.sh | sh -s -- -y -b "$bin_dir"
  fi
  mkdir -p ~/.config
  if [[ -f ~/.config/starship.toml ]]; then
    echo "~/.config/starship.toml já existe, mantido (o tema Monokai Soda não foi aplicado)"
  else
    install_file starship.toml ~/.config/starship.toml
  fi
  [[ $bin_dir != "$HOME/.local/bin" || :$PATH: == *:$HOME/.local/bin:* ]] || echo "Atenção: adicione ~/.local/bin ao PATH antes do terminal.sh no ~/.bashrc"
  echo "Starship instalado. Use uma Nerd Font no terminal para ver os ícones (veja o README)."
fi

echo "Instalado. Abra um novo terminal ou rode: . ~/.bashrc"
