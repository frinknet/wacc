FROM clang:15

RUN apt-get update && apt-get install -y make inotify-tools && rm -rf /var/lib/apt/lists/*

WORKDIR /src

CMD ["/src/utils/build.sh"]
