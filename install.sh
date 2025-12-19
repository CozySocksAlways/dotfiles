#! /usr/bin/env bash

# exit immediately if any command fails
set -e

DOTFILES="$HOME/dotfiles"

ln -sf "$DOTFILES/.vimrc" "$HOME/.vimrc"
ln -sf "$DOTFILES/.inputrc" "$HOME/.inputrc"
ln -sf "$DOTFILES/.gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
