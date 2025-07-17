#!/bin/sh

DEFAULT_BIN="$HOME/bin"
DEFAULT_NAME="wacc"

DEST="${1:-$DEFAULT_BIN/$DEFAULT_NAME}"
BASEDIR="${DEST%/*}"
[ "$BASEDIR" = "$DEST" ] && BASEDIR="."
mkdir -p "$BASEDIR"

if [ -f "$DEST" ]; then
  printf "File %s exists. Overwrite? [y/N]: " "$DEST"
  read ans < /dev/tty
  case "$ans" in
    [yY]*) ;;
    *) echo;echo "Okey dokie. Bacon smokey. No overwriting $DEST";;
  esac
fi

REPO="${REPO:-frinknet/wacc}"
URL="https://raw.githubusercontent.com/$REPO/main/utils/cli.sh"
TMP="$(mktemp)"

if command -v curl >/dev/null; then
  curl -fsSL -o "$TMP" "$URL"
elif command -v wget >/dev/null; then
  wget -qO "$TMP" "$URL"
else
  echo
  echo "What you don'tt have curl or wget!!!!" >&2
  exit 2
fi

sed -i "s|^REPO=.*|REPO=\"$REPO\"|" "$TMP"
mv "$TMP" "$DEST" && chmod +x "$DEST"

echo
echo "Installed at $DEST";

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
echo
echo "Ready to WACC with tab completion—suckless style achieved."
