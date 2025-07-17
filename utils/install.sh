#!/bin/sh

DEST="${1:-wacc}"
BASEDIR="$(dirname "$DEST")"

if [ -z "$BASEDIR" ]; then
  DEST="$HOME/bin/$DEST"
  BASEDIR="$HOME/bin"
fi

mkdir -p "$BASEDIR"

REPO="${REPO:-frinknet/wacc}"
URL="https://raw.githubusercontent.com/$REPO/main/utils/cli.sh"
TMP="$(mktemp)"

# Fetch the CLI
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

# Set up bash-completion
COMPD="/etc/bash_completion.d"
[ -w "$COMPD" ] || COMPD="$HOME/.bash_completion.d"
mkdir -p "$COMPD"

# Write a completion file
cat > "$COMPD/wacc" <<'EOF'
_wacc_complete() {
  local cur prev opts
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

# Friendly ending
echo "Ready to WACC with tab magic—and nary a yak in sight."
