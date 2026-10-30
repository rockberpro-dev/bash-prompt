#!/usr/bin/env bash
# Instala o terminal.sh em ~/.bashrc.d/ e o carrega no fim do ~/.bashrc.
#   local:  bash install.sh [--starship] [--local|--system] [--theme=<nome>] [--font=<nome>]   (com os arquivos na mesma pasta)
#   remoto: curl -fsSL <url>/install.sh | bash [-s -- --starship [--local|--system] [--theme=<nome>] [--font=<nome>]]
# --starship: instala também o starship, com o tema monokai (starship.toml) ou um preset
#   --local:  starship em ~/.local/bin (só para você, sem root)
#   --system: starship em /usr/local/bin (todos os usuários, precisa de sudo)
#   sem nenhum dos dois, pergunta onde instalar
#   --theme=<nome>: monokai (padrão) ou um preset de `starship preset --list`;
#                   sem a opção, pergunta qual tema usar
#   --font=<nome>:  Nerd Font em ~/.local/share/fonts/<nome>: JetBrainsMono (padrão), outra de
#                   https://github.com/ryanoasis/nerd-fonts/releases ou none (não instala);
#                   sem a opção, pergunta qual fonte instalar
set -euo pipefail

starship=0
bin_dir=
theme=
font=
for arg in "$@"; do
  case $arg in
    --starship) starship=1 ;;
    --local)    starship=1; bin_dir=$HOME/.local/bin ;;
    --system)   starship=1; bin_dir=/usr/local/bin ;;
    --theme=?*) starship=1; theme=${arg#--theme=} ;;
    --font=?*)  starship=1; font=${arg#--font=} ;;
    *) echo "Opção desconhecida: $arg" >&2; exit 1 ;;
  esac
done

# Onde os arquivos estão publicados (usado quando não há cópia local)
BASE_URL=${BASH_PROMPT_URL:-https://raw.githubusercontent.com/rockberpro-dev/bash-prompt/main}

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

  starship_bin=$(command -v starship || echo "$bin_dir/starship")
  all_presets=()
  while IFS= read -r p; do all_presets+=("$p"); done < <("$starship_bin" preset --list)
  # presets que só ajustam símbolos, não são temas completos
  modifiers=" bracketed-segments nerd-font-symbols no-empty-icons no-nerd-font no-runtime-versions plain-text-symbols "
  menu=()
  for p in "${all_presets[@]}"; do [[ $modifiers == *" $p "* ]] || menu+=("$p"); done

  explicit=0
  [[ -n $theme ]] && explicit=1
  if [[ -z $theme ]]; then
    theme=monokai
    if { exec 3</dev/tty; } 2>/dev/null; then
      echo "Qual tema do starship?"
      echo "  1) monokai (deste repo) [padrão]"
      for i in "${!menu[@]}"; do echo "  $((i + 2))) ${menu[i]}"; done
      read -rp "Escolha [1]: " ans <&3 || ans=
      exec 3<&-
      [[ -n $ans ]] && explicit=1
      if [[ $ans =~ ^[0-9]+$ ]] && (( ans >= 2 && ans <= ${#menu[@]} + 1 )); then
        theme=${menu[ans - 2]}
      fi
    fi
  fi

  if [[ $theme != monokai && " ${all_presets[*]} " != *" $theme "* ]]; then
    echo "Tema desconhecido: $theme (veja: starship preset --list)" >&2
    exit 1
  fi

  if [[ -f ~/.config/starship.toml ]]; then
    if (( explicit )); then
      cp ~/.config/starship.toml ~/.config/starship.toml.bak
      echo "~/.config/starship.toml anterior salvo em ~/.config/starship.toml.bak"
    else
      echo "~/.config/starship.toml já existe, mantido (o tema $theme não foi aplicado)"
      theme=
    fi
  fi
  if [[ $theme == monokai ]]; then
    install_file starship.toml ~/.config/starship.toml
  elif [[ -n $theme ]]; then
    "$starship_bin" preset "$theme" -o ~/.config/starship.toml
  fi
  [[ $bin_dir != "$HOME/.local/bin" || :$PATH: == *:$HOME/.local/bin:* ]] || echo "Atenção: adicione ~/.local/bin ao PATH antes do terminal.sh no ~/.bashrc"

  fonts=(JetBrainsMono FiraCode Hack Meslo CascadiaCode SourceCodePro UbuntuMono Iosevka RobotoMono)
  if [[ -z $font ]]; then
    font=JetBrainsMono
    if { exec 3</dev/tty; } 2>/dev/null; then
      echo "Qual Nerd Font instalar?"
      echo "  1) JetBrainsMono [padrão]"
      for i in "${!fonts[@]}"; do (( i )) && echo "  $((i + 1))) ${fonts[i]}"; done
      echo "  $((${#fonts[@]} + 1))) nenhuma (pular)"
      read -rp "Escolha [1]: " ans <&3 || ans=
      exec 3<&-
      if [[ $ans =~ ^[0-9]+$ ]] && (( ans >= 2 && ans <= ${#fonts[@]} )); then
        font=${fonts[ans - 1]}
      elif [[ $ans == $((${#fonts[@]} + 1)) ]]; then
        font=none
      fi
    fi
  fi

  if [[ $font == none ]]; then
    echo "Starship instalado. Use uma Nerd Font no terminal para ver os ícones (veja o GUIDE.md)."
  else
    dest=$HOME/.local/share/fonts/$font
    if [[ -d $dest ]]; then
      echo "Fonte $font já instalada"
    elif ! command -v xz >/dev/null; then
      echo "xz não encontrado, fonte não instalada (veja o GUIDE.md)" >&2
    else
      mkdir -p "$dest"
      if ! fetch "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.tar.xz" | tar -xJ -C "$dest"; then
        rm -rf "$dest"
        echo "Fonte desconhecida ou falha no download: $font" >&2
        exit 1
      fi
      command -v fc-cache >/dev/null && fc-cache -f
    fi
    family=
    if command -v fc-scan >/dev/null && compgen -G "$dest/*.[to]tf" >/dev/null; then
      family=$(fc-scan --format '%{family[0]}\n' "$dest"/*.[to]tf | sort -u | head -1)
    fi
    echo "Starship instalado. Selecione \"${family:-$font Nerd Font}\" nas preferências do terminal."
  fi
fi

echo "Instalado. Abra um novo terminal ou rode: . ~/.bashrc"
