#!/bin/bash

while true; do
  make

  if [ "$BUILD_ONCE" -eq 1 ]; then
    exit 0
  fi

  inotifywait -e close_write,create,delete,move --exclude '(\.swp|~)$' -r .
done
