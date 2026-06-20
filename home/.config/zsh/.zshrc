# ~/.config/zsh/.zshrc — インタラクティブシェル設定

# すっきりしたプロンプト表示
PROMPT='%~ %# '

# 補完機能
autoload -U compinit && compinit -u

# ------------------------------------------------------------------
# エイリアス（定義は .aliases に分離）
# ------------------------------------------------------------------
[[ -r "${ZDOTDIR:-$HOME}/.aliases" ]] && source "${ZDOTDIR:-$HOME}/.aliases"

# ------------------------------------------------------------------
# zsh 挙動
# ------------------------------------------------------------------
autoload -Uz colors && colors

setopt print_eight_bit      # 日本語ファイル名を表示
setopt auto_cd              # ディレクトリ名だけで cd
setopt no_beep              # ビープ音停止
setopt nolistbeep           # 補完時のビープ音停止
setopt auto_pushd           # cd 履歴をスタックに積む
setopt pushd_ignore_dups    # 重複は積まない
setopt correct              # コマンドのスペル訂正
setopt extended_glob        # 拡張 glob

# 単語境界から / を除く（Ctrl-W が / で止まる）
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# ------------------------------------------------------------------
# ヒストリ
# ------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks

# ------------------------------------------------------------------
# 補完スタイル
# ------------------------------------------------------------------
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'   # 小文字で大文字にもマッチ
zstyle ':completion:*:default' menu select=1          # 補完候補を選択式に

# ------------------------------------------------------------------
# git ブランチを右プロンプトに表示
# ------------------------------------------------------------------
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
RPROMPT=\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats '%b'

# ------------------------------------------------------------------
# fzf
#   公式のキーバインド/補完を有効化（Ctrl-R 履歴 / Ctrl-T ファイル / Alt-C cd）
# ------------------------------------------------------------------
export FZF_DEFAULT_OPTS='--layout=reverse --border --height 60%'
source <(fzf --zsh)

# Ctrl-S を fzf に使うため、端末のフロー制御（XOFF）を無効化
stty stop undef

# Ctrl-J: ack で全文検索し、ヒット箇所を bat でプレビュー
function fzf-ack-search() {
  ack "$@" . | fzf --preview $'echo {} | awk -F ":" \'{print $1 " -r " $2 ":" " -H " $2}\' | xargs bat --color=always' | awk -F ":" '{print $1 " -H " $2}' | xargs bat --color=always
  zle clear-screen
}
zle -N fzf-ack-search
bindkey '^j' fzf-ack-search

# Ctrl-S: ホーム以下のディレクトリ + コマンド履歴を横断検索
#   cd 候補を選べば移動、コマンド履歴を選べば行に展開
function fzf_any_search() {
  local fdpath='fd . ~ --full-path --type d --exclude debug --exclude Library | sed -e "s/^/cd /"'
  local history='\history -n 1 | sort | uniq | grep -v "cd" | tail -r'
  local result=$({ eval "$fdpath" ; eval "$history" ; } | fzf --query "$LBUFFER")
  if [[ "$result" =~ ^cd ]]; then
    eval "$result"
    zle clear-screen
  else
    BUFFER="$result"
    zle clear-screen
  fi
}
zle -N fzf_any_search
bindkey '^s' fzf_any_search

# ------------------------------------------------------------------
# mise (node / ruby のバージョン管理。設定は ~/.config/mise/config.toml)
# ------------------------------------------------------------------
eval "$(mise activate zsh)"

# ------------------------------------------------------------------
# ユーザーローカルの実行ファイル
# ------------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"
