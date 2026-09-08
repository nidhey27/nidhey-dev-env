# ~/.zshrc — managed by nidhey-dev-env dotfiles.
# Machine-specific tweaks that should NOT be committed go in ~/.zshrc.local
# (sourced at the bottom of this file).

# Path to Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme.
ZSH_THEME="awesomepanda"

# Plugins. The non-bundled ones (autosuggestions, syntax highlighting,
# autocomplete) are installed by install.sh into $ZSH/custom/plugins.
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  fast-syntax-highlighting
  zsh-autocomplete
)

source "$ZSH/oh-my-zsh.sh"

# --- User configuration ---------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"

# mise — runtime/tool version manager.
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Raise file-descriptor limit (helps with dev servers / watchers).
ulimit -n 65536

# --- Aliases & helper functions -------------------------------------------
# Kept in a separate file for readability (see home/.config/zsh/aliases.zsh).
[ -f "$HOME/.config/zsh/aliases.zsh" ] && source "$HOME/.config/zsh/aliases.zsh"

# --- Machine-specific overrides (not committed) ---------------------------
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
