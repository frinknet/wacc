FROM bash:latest

RUN apk add clang make inotify-tools
RUN cat > /usr/local/bin/docker-entrypoint.sh <<'EOF'
#!/usr/local/bin/bash

if [ "$1" = "debug" ]; then
  echo -en "\n\e[1;33m	You are now DEEP in the WACC build system... BEWARE OF THE GRU!!!\e[0m"
  exec /usr/local/bin/bash --rcfile <(echo 'trap echo DEBUG; export PS1="\n\[\e[1;91m\]	\w \[\e[38;5;52m\]\$\[\e[0m\] \[\e]12;#999900\007\]\[\e]12;#999900\007\]\[\e[3 q\]"')
fi

C
  make "$@"
  status=$?

  if [ "$BUILD_ONCE" -eq 1 ]; then
    exit $status
  fi

  inotifywait -e close_write,create,delete,move --exclude '(\.swp|~)$' -r .
done

EOF

WORKDIR /build
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD []
