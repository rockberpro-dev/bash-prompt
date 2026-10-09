# bash-prompt

Prompt e configurações de terminal para bash:

- prompt com diretório (2 últimos níveis) e branch git com estado
- duração do comando quando passa de 5s
- destaque para hosts de produção (faixa vermelha) e sessões SSH
- histórico grande, sem duplicatas, com data/hora e compartilhado entre sessões
- integra `fzf` (Ctrl-R / Ctrl-T) e `zoxide` (`z`), se estiverem instalados

## Instalação

```bash
curl -fsSL https://raw.githubusercontent.com/rockberpro/bash-prompt/main/install.sh | bash
```

Ou com `wget`:

```bash
wget -qO- https://raw.githubusercontent.com/rockberpro/bash-prompt/main/install.sh | bash
```

Ou a partir de um clone:

```bash
git clone https://github.com/rockberpro/bash-prompt.git
bash bash-prompt/install.sh
```

O instalador copia o `terminal.sh` para `~/.bashrc.d/` e adiciona ao fim do `~/.bashrc`:

```bash
[ -f ~/.bashrc.d/terminal.sh ] && . ~/.bashrc.d/terminal.sh
```

Pode ser rodado de novo para atualizar; a linha não é duplicada. Depois, abra um novo terminal ou rode `. ~/.bashrc`.

## Opcional: Starship

Prompt em blocos coloridos com ícones, via [Starship](https://starship.rs). Instale com `--starship`:

```bash
curl -fsSL https://raw.githubusercontent.com/rockberpro/bash-prompt/main/install.sh | bash -s -- --starship
```

Isso instala o `starship` em `~/.local/bin` e, se ainda não existir, cria `~/.config/starship.toml` com o tema Monokai Soda deste repositório (`starship.toml`, baseado no preset `pastel-powerline`). Se o arquivo já existir, ele é mantido. Quando o `starship` está no `PATH`, o `terminal.sh` usa ele no prompt; histórico, `fzf` e `zoxide` continuam iguais. Para voltar ao prompt simples, remova o binário: `rm ~/.local/bin/starship`.

Os ícones precisam de uma [Nerd Font](https://www.nerdfonts.com) configurada no terminal. Para instalar a JetBrainsMono:

```bash
mkdir -p ~/.local/share/fonts
curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz | tar -xJ -C ~/.local/share/fonts
fc-cache -f
```

Depois escolha "JetBrainsMono Nerd Font" nas preferências do terminal.

Outros visuais: `starship preset --list` e `starship preset <nome> -o ~/.config/starship.toml`. Para voltar ao Monokai Soda, copie o `starship.toml` daqui para `~/.config/`.

## Estado do git no prompt

| Símbolo | Significado                         |
|---------|-------------------------------------|
| `*`     | alterações não staged               |
| `+`     | alterações staged                   |
| `%`     | arquivos não rastreados             |
| `<`     | atrás do remoto                     |
| `>`     | à frente do remoto                  |
| `<>`    | divergiu do remoto                  |
| `=`     | sincronizado com o remoto           |

## Personalização

Edite `~/.bashrc.d/terminal.sh`:

- `__is_prod_host`: padrões de hostname considerados produção (padrão: `*prod*`, `*prd*`)
- `PROMPT_DIRTRIM`: quantos níveis do diretório mostrar
- `HISTSIZE` / `HISTFILESIZE`: tamanho do histórico

## Desinstalação

```bash
rm ~/.bashrc.d/terminal.sh
sed -i '\|\. ~/.bashrc.d/terminal.sh$|d' ~/.bashrc
```
