#!/usr/bin/env bash

set -o pipefail

export REPO="frinknet/wacc"
export VER="1.2"
export BIN="${0##*/}"
export CMD="$1"
shift || true

HELP=$(cat<<EOF

  ${BIN^^} - v${VER} // © 2025 FRINKnet & Friends
  MIT LICENSE - Suckless. Forkable. Hackable.

  Usage: $BIN [command]

  Dead simple WASM dev environment for those who ONLY like C/C++

  $BIN init [dir]           Create a new WACC project in [dir]
  $BIN dev                  Start continuous build. Change are rebuilt.
  $BIN down                 Pencil's down heads up turn off the server
  $BIN serve [module]       Only run server and  jump to a module link
  $BIN module [type]        Create a new module of the type sepcified
  $BIN update               Update your code to the latest WACC core
  $BIN upgrade              Upgrade this binary to the latest version
  $BIN build [modules]      Quickly build only the modules you specify
  $BIN pack [modules]       Package the modules you specify in a zip
  $BIN logs [serve|build]   Show either the serve logs or build logs
  $BIN env [name] [value]   Change your environment"

  Get in... Write code... Ship fast... Leave the yak unshaved!!!
 
EOF
)

function snark() {
  echo
  #echo -e "  \e[1;93m$1\e[0m"
  echo -e "  $1"
  echo
}

function wacc_check() {
  if [[ ! -e src/common/jscc.h ]]; then
    echo "Not in a ${BIN^^} project: src/common/jscc.h missing." >&2
    exit 2
  fi
  set -a
  [ -f .env ] && source .env
  set +a
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

  if [[ -f web/loadWASM.js && -f src/common/jscc.h ]]; then
    snark "DUDE!!! - You can't out ${BIN^^} the ${BIN^^}"
    snark "  $BIN init [dirname]"
    snark "Try initializing a new directory instead..." >&2
    exit 3
  fi

  snark "Let's get this party started..."

  [[ -d $wacc ]] || git submodule add https://github.com/$REPO.git libs/wacc

  wacc_update

  snark "Welcome to your new game of WACC a mole!!!"
}

function wacc_update() {
  local wacc sub

  wacc_check

  wacc="libs/wacc"

  if [[ -d $wacc ]]; then
    git submodule update --remote --rebase

    for sub in $wacc/libs/*; do
      ln -sf $sub libs/${sub##*/}
    done

    mkdir -p src/common src/modules web/wasm

    # TODO if the files are different show the diff and ask
    cp -ui $wacc/Makefile .
    cp -ui $wacc/docker-compose.yaml .
    cp -rui $wacc/src/Dockerfile src/
    cp -rui $wacc/web/* web/
    cp -ui $wacc/.gitignore .
  fi

  snark "UP TO DATE!!! - And now the real fun begins..."
}

function wacc_upgrade() {
  snark "This doesn't work yet. It should reinstall the binary."
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
  COMPOSE_IGNORE_ORPHANS=True docker compose up -d
  url="http://${SERVER_ADDRESS:-localhost:80}"

  snark "You have places to be. Brace yourself for exploration..."
  (command -v xdg-open &> /dev/null && xdg-open "$url") || echo "  Open $url in your browser."
}

function wacc_build() {
  local err out

  wacc_check
  docker compose build build
  err=$?

  if [ "$err" -ne 0 ]; then
    snark "Looks like the spark plugs got lost!!!"
    snark "Your src/Dockerfile is a MESS!!!"
    exit "$err"
  fi

  COMPOSE_IGNORE_ORPHANS=True BUILD_ONCE=1 docker compose run --rm build "$@"
  err=$?

  if [ "$err" -ne 0 ]; then
    snark "That build DID NOT go well... WHAT DID YOU DO??!"
    exit $err
  fi

  if [ "$1" == "debug" ]; then
    snark "So... Did you solve the mystery of life or what?"
  elif [ "$1" == "clean" ]; then
    snark "I guess we have to start over now... WELL FUN!!!"
  else
    snark "Well - It worked I guess... Onwards and upwards!"
  fi
}

function wacc_serve() {
  wacc_check
  COMPOSE_IGNORE_ORPHANS=True docker compose up serve -d
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
  docker compose down --remove-orphans
  snark "Hyperdrive disengaged captain!"
}

function wacc_pack() {
  local file="wacc-dist-$(date).zip"

  wacc_build
  zip -r $file web
  snark "  Packed web directory as $file. Enjoy!"
}

function wacc_logs() {
  docker compose logs
}

function wacc_error() {
  snark "Um... Did you even READ the manual???"
  snark "   $BIN help"
  snark "Go ask for help like a good little grimlin."
}

# TODO go to gitroot

# Run the command
case "$CMD" in
  init)    wacc_init "$@";;
  dev)     wacc_dev "$@";;
  down)    wacc_down "$@";;
  serve)   wacc_serve "$@";;
  module)  wacc_module "$@";;
  update)  wacc_update "$@";;
  upgrade) wacc_upgrade "$@";;
  build)   wacc_build "$@";;
  pack)    wacc_pack "$@";;
  logs)    wacc_logs "$@";;
  env)     wacc_env "$@";;
  ""|help|--help|-h) echo "$HELP";;
  *) wacc_error;;
esac
