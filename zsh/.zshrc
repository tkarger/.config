# ====================
# Basic Environment
# ====================
export PATH=$HOME/bin:/usr/local/bin:$PATH
# Update PATH for Devbox/Nix tmux
export PATH="$HOME/.local/share/devbox/global/default/.devbox/nix/profile/default/bin:$PATH"
# ====================
# ZSH
# ====================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
ZSH_TMUX_AUTOSTART=true
ZSH_TMUX_CONFIG="$HOME/.config/tmux/tmux.conf"
plugins=(git mvn cloudfoundry node yarn tmux zsh-interactive-cd zsh-z )
[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"
# . "$HOME/.profile"
export SDKMAN_DIR="/opt/sdkman"; [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
# ====================
# Hooks
# ====================
eval "$(starship init zsh)"
eval "$(devbox global shellenv --init-hook)"
eval "$(direnv hook zsh)"
eval "$(zoxide init zsh)"
source <(fzf --zsh)
# ====================
# Alias
# ====================
alias ll="ls -al"
alias dev="cd ~/Documents/dev"
alias nv="nvim"
alias lg="lazygit"
alias gp="git pull"
alias ock="ocl && k9s"

# ====================
# Env Variables
# ====================
export X_ACCOUNT_USERNAME=X60046978
export A_ACCOUNT_USERNAME=A60046978

# ============================
# Certificates & Node
# ============================
export REQUESTS_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"
export NODE_EXTRA_CA_CERTS="/etc/ssl/certs/ca-certificates.crt"

# ============================
# Autocompletion
# ============================
source <(kubectl completion zsh)
autoload -U compinit && compinit
# history setup
setopt SHARE_HISTORY
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt HIST_EXPIRE_DUPS_FIRST
export PATH="$PATH:$(go env GOPATH)/bin"
