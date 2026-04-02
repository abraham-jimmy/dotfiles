# Enable Powerlevel10k instant prompt. Keep this near the top.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git fzf extract)

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

source ~/.config/bash/.colors
source ~/.config/shell/path.sh
source ~/.config/shell/aliases.sh
source ~/.config/git/git_aliases
source ~/.config/shell/dotfiles.sh

export PATH="$PATH:$HOME/.local/share/gem/ruby/3.4.0/bin"

setopt HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_EXPIRE_DUPS_FIRST
setopt APPEND_HISTORY INC_APPEND_HISTORY
HISTFILE=~/.zsh_histfile
HISTSIZE=10000
SAVEHIST=1000
setopt appendhistory
bindkey -v

if [[ -o interactive ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_TTY" ]]; then
  t
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

if command -v tv >/dev/null 2>&1; then
  eval "$(tv init zsh)"
fi

[[ -r "$HOME/.local/share/powerlevel10k/powerlevel10k.zsh-theme" ]] && source "$HOME/.local/share/powerlevel10k/powerlevel10k.zsh-theme"
[[ -r "$HOME/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$HOME/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -r "$HOME/.local/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh" ]] && source "$HOME/.local/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
[[ -r "$HOME/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "$HOME/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

[[ -f ~/.config/zsh/.p10k.zsh ]] && source ~/.config/zsh/.p10k.zsh

# bun completions
[ -s "/home/jimmy/.bun/_bun" ] && source "/home/jimmy/.bun/_bun"
