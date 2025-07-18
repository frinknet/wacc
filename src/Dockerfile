FROM bash:latest

RUN apk add clang make inotify-tools

WORKDIR /src

ENTRYPOINT ["/src/utils/build.sh"]
