#!/usr/bin/env bash

export VER="1.2"

set -e

function wacc_check() {
  if [[ ! -f src/common/wacc.h ]]; then
    echo "Not in a $0 project: src/common/wacc.h missing." >&2
    exit 2
  fi
  set -a
  [ -f .env ] && source .env 2>/dev/null
}

function wacc_help() {
  local run="${0##*/}"

  cat <<EOF

  ${run^^} v${VER} // © 2025 FRINKnet & Friends
  MIT LICENSE - Suckless. Forkable. Hackable.

  Usage: $run [command]

  Dead simple WASM development environment for those who ONLY like C. 

    $run init [dir]      Create a new WACC project in [dir]
    $run dev             Start continuous build process
    $run build           Build your WASM fresh
    $run serve           Only run the server
    $run env             Change your environment
    $run down            Pencil's down heads up
    $run pack            Pack your WASM to go

  Get in, write code, ship fast, and leave the yak unshaved!!!!

EOF
}

function wacc_init() {
  dest="${1:-.}"
  mkdir -p "$dest"
  cd "$dest"
  git init
  echo "# New WACC Project" > README.md
  echo "Initialized WACC project in $PWD"
}

function wacc_dev() {
  wacc_check
  export server_domain=$(grep '^server_address=' .env 2>/dev/null | cut -d'=' -f2)
  docker compose up
  url="${SERVER_ADDRESS:-localhost:80}"
  (command -v xdg-open &> /dev/null && xdg-open "$url") || echo "Open $url in your browser."
}

function wacc_build() {
  wacc_check
  BUILD_ONCE=1 docker compose up --build build
}

function wacc_serve() {
  wacc_check
  docker compose up serve -d
}

function wacc_env() {
  touch .env
  read -p "server_name: " srvname
  read -p "server_address [http://localhost:80](http://localhost:80): " srvaddr
  echo "server_name=${srvname:=wacc}" > .env
  echo "server_address=${srvaddr:=http://localhost:80}" >> .env
  echo ".env set with server_name and server_address"
}

function wacc_down() {
  wacc_check
  docker compose down -d
}

function wacc_pack() {
  wacc_build
  zip -r "web-dist.zip" web
  echo "Packed web directory as web-dist.zip"
}

CMD="$1"
shift || true

case "$CMD" in
  init)   wacc_init "$@";;
  dev)    wacc_dev;;
  build)  wacc_build;;
  serve)  wacc_serve;;
  env)    wacc_env;;
  down)   wacc_down;;
  pack)   wacc_pack;;
  ""|help|--help|-h) wacc_help;;
  *) show_usage; exit 1;;
esac

