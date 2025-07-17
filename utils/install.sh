#!/bin/sh

DEFAULT_BIN="$HOME/bin"
DEFAULT_NAME="wacc"

# Destination logic—default to $HOME/bin/wacc, handle relative/absolute/plain names
DEST="${1:-$DEFAULT_BIN/$DEFAULT_NAME}"
BASEDIR="${DEST%/*}"
[ "$BASEDIR" = "$DEST" ] && BASEDIR="."
mkdir -p "$BASEDIR"

# Download CLI
REPO="${REPO:-frinknet/wacc}"
URL="https://raw.githubusercontent.com/$REPO/main/cli/cli.sh"
TMP="$(mktemp)"

if command -v curl >/dev/null; then
  curl -fsSL -o "$TMP" "$URL"
elif command -v wget >/dev/null; then
  wget -qO "$TMP" "$URL"
else
  echo "Error: need curl or wget." >&2
  exit 2
fi

sed -i "s|^REPO=.*|REPO=\"$REPO\"|" "$TMP"
mv "$TMP" "$DEST" && chmod +x "$DEST"
echo "Installed to $DEST"

# Bash completion
COMPD="/etc/bash_completion.d"
[ -w "$COMPD" ] || COMPD="$HOME/.bash_completion.d"
mkdir -p "$COMPD"

cat > "$COMPD/wacc" <<'EOF'
_wacc_complete() {
  local cur opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  opts="init dev build serve env down pack help --help -h"
  if [[ $COMP_CWORD -eq 1 ]]; then
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
  fi
}
complete -F _wacc_complete wacc
EOF

echo "Bash completion installed! If not live, try: source $COMPD/wacc"
echo "Ready to WACC with tab completion—suckless style achieved."
