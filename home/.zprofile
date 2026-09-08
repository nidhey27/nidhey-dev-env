# Load Homebrew into the environment (login shells).
# Handles both Apple Silicon (/opt/homebrew) and Intel (/usr/local) Macs.
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
