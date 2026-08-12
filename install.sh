#!/usr/bin/env bash
# Symlinks this dotfiles repo into place on a fresh macOS machine.
# Not executable by default (git doesn't preserve the bit reliably across
# clones) - run `chmod +x install.sh` once before `./install.sh`,
# or invoke directly as `bash install.sh`.
set -euo pipefail

if [[ "$(uname)" != "Darwin" ]]; then
  echo "install.sh is macOS-only." >&2
  exit 1
fi

# NOTE: run this script directly from the repo (./install.sh or bash
# install.sh) - don't symlink install.sh itself elsewhere (e.g. ~/bin). The
# path below is derived from BASH_SOURCE and doesn't resolve through
# symlinks, so running it via one silently points at the wrong repo.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d%H%M%S)"

link() {
  local src="$1" dst="$2"

  mkdir -p "$(dirname "$dst")"

  if [[ -L "$dst" ]]; then
    if [[ "$(readlink "$dst")" == "$src" ]]; then
      echo "ok:      $dst"
      return
    fi
    echo "relink:  $dst (was -> $(readlink "$dst"))"
    rm "$dst"
  elif [[ -e "$dst" ]]; then
    mkdir -p "$BACKUP_DIR"
    echo "backup:  $dst -> $BACKUP_DIR/"
    mv "$dst" "$BACKUP_DIR/$(basename "$dst")"
  fi

  ln -s "$src" "$dst"
  echo "linked:  $dst -> $src"
}

link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
link "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
link "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
link "$DOTFILES_DIR/claude/notify.sh" "$HOME/.claude/notify.sh"

if [[ -d "$BACKUP_DIR" ]]; then
  echo
  echo "Existing files backed up to: $BACKUP_DIR"
fi

echo
echo "Done."
