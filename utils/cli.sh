#!/usr/bin/env bash

export REPO="frinknet/wacc"
export VER="1.2"
export BIN="${0##*/}"

set -e

function snark() {
  echo
  echo "  $1"
  echo
}

function wacc_check() {
  if [[ ! -f src/common/wacc.h ]]; then
    echo "Not in a ${BIN^^} project: src/common/wacc.h missing." >&2
    exit 2
  fi
  set -a
  [ -f .env ] && source .env
  set +a
}

function wacc_help() {
  cat <<EOF

  ${BIN^^} v${VER} // © 2025 FRINKnet & Friends
  MIT LICENSE - Suckless. Forkable. Hackable.

  Usage: $BIN [command]

  Dead simple WASM dev environment for those who ONLY like C/C++ 

    $BIN init [dir]      Create a new WACC project in [dir]
    $BIN dev             Start continuous build process
    $BIN down            Pencil's down heads up
    $BIN serve           Only run the server
    $BIN module          Create a new module in WACC
    $BIN update          Update WACC core
    $BIN build           Build your WASM fresh
    $BIN pack            Pack your WASM to go
    $BIN env             Change your environment

  Get in, write code, ship fast, and leave the yak unshaved!!!!

EOF
}

function wacc_init() {
  local dest wacc

  dest="${1:-.}"
  wacc="libs/wacc"

  mkdir -p "$dest"
  cd "$dest"
  mkdir -p src/common src/modules web/wasm
  git rev-parse --is-inside-work-tree &>/dev/null || git init --quiet
  git submodule update --init --recursive --depth 1

  if [[ -f web/loadWASM.js && -f src/common/wacc.h ]]; then
    snark "DUDE!!! - You can't out ${BIN^^} the ${BIN^^}"
    snark "  $BIN init [dirname]"
    snark "Try initializing a new directory instead..." >&2
    exit 3
  fi

  snark "Liet's get this party started..."

  [[ -d $wacc ]] || git submodule add https://github.com/$REPO.git libs/wacc
  git submodule update --init --recursive --depth 1

  mkdir -p src/common src/modules web/wasm

  cp -rui $wacc/src/common/* src/common/
  cp -rui $wacc/src/Dockerfile src/
  cp -rui $wacc/web/* web/

  wacc_update

  snark "Welcome to your new game of WACC a mole!!!"
}

function wacc_update() {
  local wacc sub

  wacc_check

  wacc="libs/wacc"

  if [[ -d $wacc ]]; then
    git submodule update --init --recursive --depth 1

    for sub in $wacc/libs/*; do
      ln -sf $sub libs/${sub##*/}
    done

    mkdir -p src/common src/modules web/wasm

    cp -ui $wacc/Makefile .
    cp -ui $wacc/docker-compose.yaml .
    cp -ui $wacc/LICENSE .

    cp -rui $wacc/src/common/* src/common/
    cp -rui $wacc/src/Dockerfile src/
    cp -rui $wacc/web/* web/
  fi

  snark "UP TO DATE!!! - And now the real fun begins..."
}

function wacc_module() {
  local template_dir module_dir templates template mod_name dest ans

  template_dir="libs/wacc/src/templates"
  module_dir="src/modules"

  if [[ ! -d libs/wacc ]]; then
    snark "You are not in a WACC project... Where are you?"
    exit 5
  fi

  templates=($(ls -1 "$template_dir" 2>/dev/null | grep -vE '^\.|^_'))

  if [[ ${#templates[@]} -eq 0 ]]; then
    snark "Um... What's up with your libs/WACC?"
    snark "There is nothing there!!!"
    exit 5
  fi

  while true; do
    read -p "Choose a name for your new module: " mod_name
    [[ -n "$mod_name" ]] && break
    snark "Nameless modules wander the void. Try again."
  done

  snark "Available templates:"
  select template in "${templates[@]}"; do
    [[ -n "$template" ]] && break
    snark "Try again. Pick a real number this time."
  done

  dest="$module_dir/$mod_name"
  if [[ -e "$dest" ]]; then
    read -p "$dest exists. Overwrite? [y/N] " ans
    [[ ! "$ans" =~ ^[Yy]$ ]] && snark "Aborted. Module already exists." && exit 44
    rm -rf "$dest"
  fi

  cp -r "$template_dir/$template" "$dest"
  snark "Your $template module is ready at $dest."
}


function wacc_dev() {
  wacc_check
  docker compose up -d
  url="${SERVER_ADDRESS:-localhost:80}"

  snark "You have places to be. Brace yourself for exploration..."
  (command -v xdg-open &> /dev/null && xdg-open "$url") || echo "  Open $url in your browser."
}

function wacc_build() {
  wacc_check
  BUILD_ONCE=1 docker compose up --build build
}

function wacc_serve() {
  wacc_check
  docker compose up serve -d
  snark "We have liftoff!!"
}

function wacc_env() {
  wacc_check
  # If no arguments, show whole .env if present, else the process env
  if [[ $# -eq 0 ]]; then
    if [[ -f .env ]]; then
      cat .env
    else
      printenv
    fi
  # If one argument, show value if in .env, else system env
  elif [[ $# -eq 1 ]]; then
    grep "^$1=" .env 2>/dev/null || printenv | grep "^$1="
  # If two arguments, set value in .env
  elif [[ $# -eq 2 ]]; then
    tmpfile="$(mktemp)"
    grep -v "^$1=" .env 2>/dev/null > "$tmpfile" || true
    echo "$1=$2" >> "$tmpfile"
    mv "$tmpfile" .env
    echo "$1 set to $2"
  else
    echo "Usage: $0 env [VAR [VAL]]"
    exit 1
  fi
}

function wacc_down() {
  wacc_check
  docker compose down
  snark "Hyperdrive disengaged captain!"
}

function wacc_pack() {
  wacc_build
  zip -r "web-dist.zip" web
  snark "  Packed web directory as web-dist.zip"
}

function wacc_logs() {
  docker compose logs
}

function wacc_error() {
  snark "Um... Did you even READ the manual???"
  snark "   $BIN help"
  snark "Go ask for help like a good little grimlin."
}

CMD="$1"
shift || true

case "$CMD" in
  init)   wacc_init "$@";;
  dev)    wacc_dev;;
  down)   wacc_down;;
  serve)  wacc_serve;;
  module)   wacc_module;;
  update)   wacc_update;;
  build)  wacc_build;;
  pack)   wacc_pack;;
  logs)   wacc_logs;;
  env)    wacc_env "$@";;
  ""|help|--help|-h) wacc_help;;
  *) wacc_error;;
esac

