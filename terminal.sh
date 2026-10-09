# ~/.bashrc.d/terminal.sh
# Carregue no fim do ~/.bashrc:
#   [ -f ~/.bashrc.d/terminal.sh ] && . ~/.bashrc.d/terminal.sh
# Remova (ou comente) a definição antiga de PS1 para não haver conflito.

[[ $- != *i* ]] && return   # só em shells interativos

# ---------- Histórico ----------
HISTSIZE=100000
HISTFILESIZE=200000
HISTCONTROL=ignoreboth:erasedups   # sem duplicatas, ignora comandos com espaço na frente
HISTTIMEFORMAT='%F %T  '           # data/hora no `history`
shopt -s histappend cmdhist        # não sobrescreve o histórico de outras sessões

# ---------- Comportamento ----------
shopt -s checkwinsize globstar 2>/dev/null   # globstar: ** recursivo
PROMPT_DIRTRIM=2                             # \w mostra só os 2 últimos níveis

# ---------- Ferramentas (opcionais: só ativa se estiverem instaladas) ----------
# fzf: Ctrl-R com busca fuzzy no histórico, Ctrl-T para arquivos
if command -v fzf >/dev/null; then
  if __fzf_init=$(fzf --bash 2>/dev/null); then
    eval "$__fzf_init"                                      # fzf >= 0.48
  elif [[ -f /usr/share/doc/fzf/examples/key-bindings.bash ]]; then
    . /usr/share/doc/fzf/examples/key-bindings.bash         # fzf do apt (versões antigas)
  fi
  unset __fzf_init
fi

# zoxide: `z alfa` pula para o diretório mais usado que bate com "alfa"
command -v zoxide >/dev/null && eval "$(zoxide init bash)"

# No Ubuntu, bat e fd vêm com outros nomes
command -v batcat >/dev/null && ! command -v bat >/dev/null && alias bat=batcat
command -v fdfind >/dev/null && ! command -v fd  >/dev/null && alias fd=fdfind

# ---------- Starship (opcional) ----------
# Se o starship estiver instalado, ele cuida do prompt e o resto do arquivo é ignorado.
if command -v starship >/dev/null; then
  eval "$(starship init bash)"
  return
fi

# ---------- Git no prompt ----------
for __f in /usr/lib/git-core/git-sh-prompt \
           /usr/share/git-core/contrib/completion/git-prompt.sh; do
  [[ -f $__f ]] && { . "$__f"; break; }
done
unset __f
GIT_PS1_SHOWDIRTYSTATE=1      # * não staged, + staged
GIT_PS1_SHOWUNTRACKEDFILES=1  # % arquivos não rastreados
GIT_PS1_SHOWUPSTREAM=auto     # < atrás, > à frente, <> divergiu, = sincronizado

# ---------- Prompt ----------
# Ajuste os padrões abaixo para os hostnames dos seus servidores de produção.
__is_prod_host() { case $HOSTNAME in *prod*|*prd*) return 0 ;; esac; return 1; }

trap '__timer_start=${__timer_start:-$SECONDS}' DEBUG   # mede duração dos comandos

__prompt() {
  local reset='\[\e[0m\]' dim='\[\e[2m\]' branch='\[\e[33m\]'
  local dircolor='\[\e[32m\]' host=''

  if __is_prod_host; then
    dircolor='\[\e[1;31m\]'
    host='\[\e[1;41;97m\] \u@\h \[\e[0m\] '        # faixa vermelha: produção
  elif [[ -n $SSH_CONNECTION ]]; then
    dircolor='\[\e[35m\]'
    host='\u@\h '
  fi

  local elapsed=$(( SECONDS - ${__timer_start:-$SECONDS} ))
  unset __timer_start
  local took=''
  (( elapsed >= 5 )) && took="${dim}${elapsed}s${reset} "

  # A branch vai numa variável referenciada no PS1 (não interpolada nele),
  # para que um nome de branch com $(...) não seja executado pelo shell.
  __prompt_git=''
  declare -F __git_ps1 >/dev/null && __prompt_git=$(__git_ps1 ' (%s)')

  PS1='\[\e]0;\w\a\]'"${took}${host}${dircolor}"'\w'"${reset}${branch}"'${__prompt_git}'"${reset}"' \$ '
}

# adiciona __prompt ao PROMPT_COMMAND só uma vez
[[ $PROMPT_COMMAND == *__prompt* ]] || PROMPT_COMMAND="__prompt${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
