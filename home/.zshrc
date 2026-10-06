# ~/.zshrc - managed by nidhey-dev-env dotfiles.
# Secrets and machine-specific tweaks go in ~/.zshrc.local (sourced at the bottom).

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="awesomepanda"

# zsh-syntax-highlighting must be last. Do not also load fast-syntax-highlighting:
# the two are competing implementations and both wrap every ZLE widget.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source "$ZSH/oh-my-zsh.sh"

# Ghostty's background is overridden to #1e3a5f, and the default fg=8 (#666666)
# only reaches 2:1 contrast against it. This blue-grey gets ~4.7:1.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#8fa8c8'

# --- User configuration ---------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"

# gcloud components (gke-gcloud-auth-plugin) installed by the brew gcloud-cli cask
export PATH="/opt/homebrew/share/google-cloud-sdk/bin:$PATH"

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Raise file-descriptor limit (helps with dev servers / watchers).
ulimit -n 65536

[ -f "$HOME/.config/zsh/aliases.zsh" ] && source "$HOME/.config/zsh/aliases.zsh"

if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
  complete -F __start_kubectl k
fi

# The webservice pod sets TMPDIR=/tmp/gitlab, and mirrord copies that env into
# the local supervisor. Go's os.MkdirTemp then panics if the directory is
# missing, and macOS periodically clears /tmp.
caproni() {
  [[ "$1" == run ]] && mkdir -p /tmp/gitlab
  command caproni "$@"
}

# Closing the terminal instead of Ctrl-C leaves `caproni run` unreverted: mirror
# deployments stay up, originals sit at 0 replicas, and the next run refuses to start.
caproni-clean() {
  pkill -f edit-mode-process-supervisor
  pkill -f 'mirrord intproxy'
  local d
  for d in $(caproni kubectl -n gitlab get deploy -o name | grep -- '-caproni$'); do
    caproni kubectl -n gitlab delete "$d"
    caproni kubectl -n gitlab scale "${d%-caproni}" --replicas=1
  done
}

# The VM silently loses its col0 (vzNAT) interface. colima still says Running,
# `caproni status` still says ready and every deployment still reports 1/1, but
# `colima list` shows a blank ADDRESS and nothing on 192.168.64.2 answers.
# `caproni kubectl` keeps working because it carries its own kubeconfig, so the
# first thing that breaks is usually mirrord, whose error mentions no networking.
caproni-net() {
  local addr
  addr=$(colima ssh --profile caproni -- ip -4 addr show col0 2>/dev/null | awk '/inet /{print $2}')
  if [[ -n "$addr" ]]; then
    echo "col0 up: $addr"
    return 0
  fi

  echo "col0 missing, restarting the caproni VM"
  colima restart --profile caproni || return 1

  addr=$(colima ssh --profile caproni -- ip -4 addr show col0 2>/dev/null | awk '/inet /{print $2}')
  [[ -z "$addr" ]] && { echo "col0 still missing after restart, needs digging into"; return 1; }
  echo "col0 restored: $addr"
  # A restart drops gitlabhq_test and the CREATEDB grant, so spec runs need it back.
  echo "note: run 'mise run gitlab:rspec' expecting a db:test:prepare first"
}

# ---------------------------------------------------------------------------
# CKAD practice mode
#
# The exam gives a bare bash shell. It DOES provide a `k` alias and kubectl
# completion, so those stay on - turning them off would be practising harder
# than the real thing. What it does not have is autosuggestion ghost text,
# syntax colouring, and a decorated prompt.
#
#   plugins-off   before a practice paper
#   plugins-on    back to normal work
#   plugins-status   which mode am I in
# ---------------------------------------------------------------------------
plugins-off() {
  typeset -f _zsh_autosuggest_disable >/dev/null 2>&1 && _zsh_autosuggest_disable
  typeset -ga CKAD_HL_SAVED
  if [[ -z ${CKAD_HL_SAVED[*]} && -n ${ZSH_HIGHLIGHT_HIGHLIGHTERS[*]} ]]; then
    CKAD_HL_SAVED=("${ZSH_HIGHLIGHT_HIGHLIGHTERS[@]}")
  fi
  ZSH_HIGHLIGHT_HIGHLIGHTERS=()
  [[ -z $CKAD_PROMPT_SAVED ]] && export CKAD_PROMPT_SAVED="$PROMPT"
  PROMPT='%n@%m:%~$ '
  RPROMPT=''
  export CKAD_PRACTICE=1
  print -P "%F{yellow}practice mode on%f  - no autosuggestions, no highlighting, plain prompt"
  print -P "  kubectl completion and your k alias are still on, as in the real exam"
}

plugins-on() {
  typeset -f _zsh_autosuggest_enable >/dev/null 2>&1 && _zsh_autosuggest_enable
  if [[ -n ${CKAD_HL_SAVED[*]} ]]; then
    ZSH_HIGHLIGHT_HIGHLIGHTERS=("${CKAD_HL_SAVED[@]}")
  else
    ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)
  fi
  [[ -n $CKAD_PROMPT_SAVED ]] && PROMPT="$CKAD_PROMPT_SAVED"
  unset CKAD_PRACTICE CKAD_PROMPT_SAVED
  print -P "%F{green}plugins on%f - back to normal"
}

plugins-status() {
  if [[ -n $CKAD_PRACTICE ]]; then
    print -P "%F{yellow}practice mode%f (autosuggestions off, highlighting off)"
  else
    print -P "%F{green}normal mode%f (autosuggestions on, highlighting on)"
  fi
}

# Singular spellings, because that is what fingers type.
plugin-off()    { plugins-off "$@"; }
plugin-on()     { plugins-on "$@"; }
plugin-status() { plugins-status "$@"; }

# Closest thing to the real exam shell: bash, only the k alias, nothing else.
# macOS ships bash 3.2.57 (2007); the exam runs bash 5.x. `brew install bash`
# gets you a modern one and this picks it up automatically.
ckad-shell() {
  local rc sh
  for sh in /opt/homebrew/bin/bash /usr/local/bin/bash /bin/bash; do
    [[ -x $sh ]] && break
  done
  rc=$(mktemp /tmp/ckad-bashrc.XXXXXX) || return 1
  cat > "$rc" <<'BRC'
export BASH_SILENCE_DEPRECATION_WARNING=1
alias k=kubectl
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion bash) 2>/dev/null
  complete -o default -F __start_kubectl k 2>/dev/null
fi
set -o vi 2>/dev/null || true
PS1='candidate@base:\w\$ '
BRC
  print -P "%F{yellow}bare bash %F{white}($($sh --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1))%F{yellow} - 'exit' to come back%f"
  "$sh" --noprofile --rcfile "$rc" -i
  rm -f "$rc"
}

# --- Machine-specific overrides and secrets (not committed) ---------------
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
