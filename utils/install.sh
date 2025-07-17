#!/bin/sh

DEST="${1:-wacc}"
BASEDIR="$(dirname "$DEST")"

if [ -z "$BASEDIR" ]; then
  DEST="$HOME/bin/$DEST"
  BASEDIR="$HOME/bin"
fi

mkdir -p "$BASEDIR"

REPO="${REPO:-frinknet/wcc}"
URL="https://raw.githubusercontent.com/$REPO/main/utils/cli.sh"
TMP="$(mktemp)"

if ! wget -qO "$TMP" "$URL"; then
  echo "ERROR: Unable to fetch cli.sh from $REPO at:\n\n$URL"
  exit 2
fi

sed -i "s|^REPO=.*|REPO=\"$REPO\"|" "$TMP"
mv "$TMP" "$DEST" && chmod +x "$DEST"

echo "Installed to $DEST"
