FROM bash:latest

RUN apk add clang make inotify-tools

RUN cat > /usr/local/bin/docker-entrypoint.sh <<'EOF'
#!/usr/local/bin/bash

if [ "$1" = "debug" ]; then
  exec /usr/local/bin/bash
fi

while true; do
  make "$@"
  status=$?

  if [ "$BUILD_ONCE" -eq 1 ]; then
    exit $status
  fi

  inotifywait -e close_write,create,delete,move --exclude '(\.swp|~)$' -r .
done

echo "$@"

EOF

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD []
