FROM alpine:latest

# Install prerequisites
RUN apk add --no-cache \
      bash \
      luajit \
      clang \
      lld \
      make \
      inotify-tools \
      llvm-dev \
      libc++ \
      libc++-dev \
      vim \
      curl \
      tar

RUN apk add wabt --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing/

# Set up bash prompt and debug helpers
RUN echo "trap echo DEBUG"	 >> /root/.bashrc && \
    echo 'export PS1="\n\[\e[1;91m\]  \w \[\e[38;5;52m\]\$\[\e[0m\] \[\e]12;#999900\007\]\[\e]12;#999900\007\]\[\e[3 q\]"' >> /root/.bashrc

RUN cat <<'EOF' > /usr/local/bin/docker-entrypoint.sh
#!/usr/bin/env bash
set -e

if [ "$1" = "cli" ]; then
  echo -e "\n\n\e[1;33m  You are now DEEP in the WACC build system... BEWARE OF THE GRUE!!!\e[0m"
  exec bash -i
fi

while true; do
  make "$@"
  status=$?
  if [ "$BUILD_ONCE" = "1" ]; then
    exit $status
  fi
  inotifywait -e close_write,create,delete,move --exclude "(\.swp|~)\$" -r .
done
EOF

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /build
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD []
