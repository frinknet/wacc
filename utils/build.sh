#!/usr/bin/env bash

while true; do
  make "$@"
  status=$?

  if [ "$BUILD_ONCE" -eq 1 ]; then
    exit $status
  fi

  inotifywait -e close_write,create,delete,move --exclude '(\.swp|~)$' -r .
done
