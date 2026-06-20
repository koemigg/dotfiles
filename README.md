# dotfiles

[GNU Stow](https://www.gnu.org/software/stow/) でシンボリックリンクを管理する。

## Setup

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

```sh
git clone git@github.com:koemigg/dotfiles.git ~/dotfiles
```

```sh
cd ~/dotfiles
brew install stow
brew bundle install
```

```sh
cd ~/dotfiles
stow home
```

既存の実ファイルがあると stow が止まる。その場合は退避するか、初回だけ `--adopt` で取り込む:

```sh
stow --adopt home       # 既存ファイルをリポジトリ側に取り込んでリンク化
git diff                # 取り込まれた内容を確認し、不要なら git checkout で戻す
```

```sh
mise install
```
