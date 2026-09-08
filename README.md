# nidhey-dev-env

My personal macOS dotfiles + dev-environment bootstrap. Clone it on a new
machine, run one script, and the setup is up and running: Homebrew packages,
oh-my-zsh + plugins, `mise`-managed tool versions, and all my dotfiles.

## Quick start (new machine)

```bash
git clone <this-repo-url> ~/Documents/nidhey-dev-env
cd ~/Documents/nidhey-dev-env
./install.sh
exec zsh   # or just open a new terminal
```

`install.sh` is **idempotent** — safe to re-run whenever you add packages or
change a dotfile.

## What it does

1. Installs **Homebrew** (if missing).
2. Installs everything in [`Brewfile`](./Brewfile) via `brew bundle`.
3. Installs **oh-my-zsh** and these plugins: `zsh-autosuggestions`,
   `zsh-syntax-highlighting`, `fast-syntax-highlighting`, `zsh-autocomplete`.
4. **Symlinks** everything under [`home/`](./home) into `$HOME`
   (existing files are backed up to `~/.dotfiles-backup/<timestamp>/`).
5. Creates `~/.gitconfig.local` with your git identity (not committed).
6. Runs `mise install` to install pinned tool versions.

## Layout

| Path | Purpose |
|------|---------|
| `install.sh` | The bootstrap script. |
| `Brewfile` | Declarative list of brew formulae + casks. |
| `home/` | Mirrors `$HOME`; every file here is symlinked into place. |
| `home/.zshrc` | Zsh config (theme, plugins); sources the aliases file. |
| `home/.config/zsh/aliases.zsh` | Documented aliases & helper functions (kubectl set, etc.). |
| `home/.gitconfig` | Shared git settings; identity is `include`d from `~/.gitconfig.local`. |
| `home/.config/mise/config.toml` | Pinned tool versions for `mise`. |

## Kubernetes aliases

Defined in [`home/.config/zsh/aliases.zsh`](./home/.config/zsh/aliases.zsh).
Depend on `kubectl`, `kubectx`, and `fzf` (all in the Brewfile).

| Alias / fn | Expands to | Example |
|------------|-----------|---------|
| `k` | `kubectl` | `k get pods` |
| `kc` | `kubectl config` | `kc use-context prod` |
| `kx` | `kubectx` — switch **context** (cluster) | `kx` (picker) / `kx prod` |
| `kn` | `kubens` — switch **namespace** | `kn` (picker) / `kn kube-system` |
| `kpod <pat>` | pod names matching `<pat>` | `kpod api` |
| `grep_pod <pat>` | filter `kubectl get pods` to name column | `k get pods \| grep_pod api` |
| `grep_copy_pod <pat>` | same, but copies name to clipboard | `k get pods \| grep_copy_pod api` |
| `kexec <pat> [-c <c>] [cmd]` | exec into a matching pod (fzf if many) | `kexec api` / `kexec api -c app sh` |

## Adding things later

- **New brew package:** `brew install foo`, then regenerate the list:
  `brew bundle dump --force --file=Brewfile`. Commit the change.
- **New tool version:** `mise use -g foo@latest` (edits `~/.config/mise/config.toml`,
  which is the symlink — so it's tracked automatically). Commit it.
- **New dotfile:** drop it under `home/` at the right path, re-run `./install.sh`.
- **New alias:** edit `home/.zshrc`.

## Secrets

Nothing secret is committed. Machine-specific / private values go in
gitignored local files that `install.sh` (or you) create per machine:

- `~/.gitconfig.local` — git name/email.
- `~/.zshrc.local` — any machine-specific shell tweaks (sourced by `.zshrc`).

SSH keys and tokens are **never** stored here — set those up manually on each
machine.
