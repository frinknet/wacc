#!/bin/bash

# jscc - JSCC project CLI
# Usage: jscc init <workdir> [jscc_repo_url (optional)]
#        jscc serve            (watches & auto-builds/serves using Docker)

set -e

REPO_URL_DEFAULT="https://github.com/frinknet/jscc.git"

command="$1"
WORKDIR="$2"
REPO_URL="${3:-$REPO_URL_DEFAULT}"

copy_repo_with_prompt() {
  local src_dir="$1"
  local dest_dir="$2"
  find "$src_dir" -type f -print0 | while IFS= read -r -d '' src_path; do
    local rel_path="${src_path#$src_dir/}"
    local dest_path="$dest_dir/$rel_path"
    local dest_dir_path
    dest_dir_path=$(dirname "$dest_path")
    mkdir -p "$dest_dir_path"
    if [ -e "$dest_path" ]; then
      if [[ "$rel_path" == "src/demo.c" ]]; then
        echo "Skipping existing $dest_path"
        continue
      fi
      read -p "'$dest_path' exists! Overwrite? [y/N] " yn
      case "$yn" in
        [Yy]*) cp "$src_path" "$dest_path"; echo "Overwritten: $dest_path" ;;
        *) echo "Skipped: $dest_path" ;;
      esac
    else
      cp "$src_path" "$dest_path"
    fi
  done
}

case "$command" in
  init)
    if [ -z "$WORKDIR" ]; then
      echo "Please specify a work directory for init."
      exit 1
    fi
    mkdir -p "$WORKDIR"
    cd "$WORKDIR"
    git init
    git submodule add "$REPO_URL" jscc || {
      echo "Submodule may already exist. Continuing..."
    }
    copy_repo_with_prompt jscc .
    mkdir -p src web
    echo "JSCC project initialized in $WORKDIR"
    echo "Tip: Run 'jscc serve' in this directory to auto-build and serve with Docker."
    ;;

  serve)
    # Rebuild and serve with Docker on file change (requires inotify-tools in host or polling)
    echo "Starting JSCC Docker build and Caddy server (auto-reloads on change)..."
    which inotifywait >/dev/null 2>&1 || { echo "Install inotify-tools for instant rebuilds."; }
    (while true; do
        # Aggressively watch for any change in src/ or web/ or Makefile or jscc/
        inotifywait -e modify,create,delete,move -r src web jscc Makefile docker-compose.yaml 2>/dev/null
        echo "Change detected. Rebuilding WASM in Docker..."
        docker-compose run --rm builder || echo "Docker build failed."
        echo "Waiting for changes..."
     done) &
    docker-compose up web
    ;;

  *)
    echo "Usage: jscc init <workdir> [jscc_repo_url]"
    echo "       jscc serve"
    exit 1
    ;;
esac

