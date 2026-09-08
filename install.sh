#!/usr/bin/env bash
#
# install.sh — bootstrap a fresh macOS machine from these dotfiles.
#
# Usage:
#   git clone <this-repo> ~/Documents/nidhey-dev-env
#   cd ~/Documents/nidhey-dev-env
#   ./install.sh
#
# Safe to re-run any time (idempotent). Existing dotfiles are backed up
# before being replaced with symlinks.

set -euo pipefail

# --- Setup ----------------------------------------------------------------
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_SRC="$DOTFILES_DIR/home"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

bold() { printf '\033[1m%s\033[0m\n' "$*"; }
info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m ✓\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m ! \033[0m%s\n' "$*"; }

# --- Preconditions --------------------------------------------------------
if [[ "$(uname -s)" != "Darwin" ]]; then
  warn "This script targets macOS. Continuing, but Homebrew/cask steps may not apply."
fi

# --- 1. Homebrew ----------------------------------------------------------
install_homebrew() {
  info "Homebrew"
  if command -v brew >/dev/null 2>&1; then
    ok "already installed"
  else
    info "installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  # Make brew available in this shell for the rest of the script.
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

# --- 2. Brew packages -----------------------------------------------------
install_brew_packages() {
  info "Homebrew packages (Brewfile)"
  brew bundle --file="$DOTFILES_DIR/Brewfile"
  ok "Brewfile applied"
}

# --- 3. Oh My Zsh ---------------------------------------------------------
install_oh_my_zsh() {
  info "Oh My Zsh"
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    ok "already installed"
  else
    # --unattended: don't run zsh or change the shell mid-script.
    RUNZSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  clone_plugin() {
    local name="$1" url="$2"
    if [[ -d "$custom/plugins/$name" ]]; then
      ok "plugin $name present"
    else
      info "installing plugin $name"
      git clone --depth=1 "$url" "$custom/plugins/$name"
    fi
  }
  clone_plugin zsh-autosuggestions      https://github.com/zsh-users/zsh-autosuggestions
  clone_plugin zsh-syntax-highlighting  https://github.com/zsh-users/zsh-syntax-highlighting
  clone_plugin fast-syntax-highlighting https://github.com/zdharma-continuum/fast-syntax-highlighting
  clone_plugin zsh-autocomplete         https://github.com/marlonrichert/zsh-autocomplete
}

# --- 4. Symlink dotfiles --------------------------------------------------
link_dotfiles() {
  info "Symlinking dotfiles from home/ -> \$HOME"
  # Walk every file under home/ and link it to the matching path in $HOME,
  # preserving directory structure.
  while IFS= read -r -d '' src; do
    local rel="${src#"$HOME_SRC"/}"
    local dest="$HOME/$rel"

    mkdir -p "$(dirname "$dest")"

    # Already the correct symlink? skip.
    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
      ok "$rel"
      continue
    fi

    # Back up anything real that's in the way.
    if [[ -e "$dest" || -L "$dest" ]]; then
      mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
      mv "$dest" "$BACKUP_DIR/$rel"
      warn "backed up existing $rel -> $BACKUP_DIR/$rel"
    fi

    ln -s "$src" "$dest"
    ok "linked $rel"
  done < <(find "$HOME_SRC" -type f -print0)
}

# --- 5. Git identity (kept out of the repo) -------------------------------
setup_git_identity() {
  info "Git identity (~/.gitconfig.local)"
  local local_cfg="$HOME/.gitconfig.local"
  if [[ -f "$local_cfg" ]]; then
    ok "already configured"
    return
  fi
  local name email
  read -rp "git user.name: " name
  read -rp "git user.email: " email
  cat > "$local_cfg" <<EOF
[user]
	name = $name
	email = $email
EOF
  ok "created $local_cfg"
}

# --- 6. mise tools --------------------------------------------------------
install_mise_tools() {
  info "mise tools (.config/mise/config.toml)"
  if command -v mise >/dev/null 2>&1; then
    mise install
    ok "mise tools installed"
  else
    warn "mise not found on PATH yet; open a new shell and run 'mise install'"
  fi
}

# --- Run ------------------------------------------------------------------
main() {
  bold "Bootstrapping dev environment from $DOTFILES_DIR"
  install_homebrew
  install_brew_packages
  install_oh_my_zsh
  link_dotfiles
  setup_git_identity
  install_mise_tools
  bold "Done. Open a new terminal (or run: exec zsh) to load everything."
}

main "$@"
