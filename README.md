# WebAssembly Concise Compiler / v1.2 / MIT

We are building a simple and repeatable way to build WASM SPAs, Workers, Worklets and other fun without wrangling Pythons oth te Amazon and 25 build tools. This is a batteries included oppinionated framework and livecycle management system written for the suckless community that loves C. It's work in progress not quite ready for primetime but maturing fast. I've got several big commercial projects where this will be used so don't think of it as a hobby thing. Once those are live I'll post some links so that you can check out how awesome this is. I promise it's coming soon. See how fast the commits are flying!!!

---

## Features

- Dead simple command line you can remember
- Repeatable builds in Docker runs everywhere
- Recompile on the fly s you can dev and test continually
- Dead simple SPA with WASM manages EVERYTHING in C the way it should be
- Multipage APPS are just as doable
- Plays fine with others so you can run in production or delveopment
- Single line of code to enter into WASM mode in either HTML or JS
- Plumbing for using WASM as web workers, audio and video worklets
- Seamless interactivity between JS and C using simple macros
- Build script is one small Makefile for tinkering
- CLI in Bash so you don't have to remember any commands
- Raw CLANG compiling without Emscripten extras
- Suckless methodology: Not much code. Do good stuff fast

## Installing

You can do a quick install the CLI for instantly from any shel with no fuss. Just run:

```sh
wget -qO- https://raw.githubusercontent.com/frinknet/wacc/main/utils/install.sh | sh
```

By default, this lands `wacc` in your `~/bin` directory but you can install anywhere you want and even install from your on fork.

```sh
REPO=myuser/myfork wget -qO- https://raw.githubusercontent.com/frinknet/wacc/main/utils/install.sh | sudo sh -s /usr/local/bin/wacc
```

Because of this you can install multiple concurent version. (Although why would you want to do that???) They are simple enough that they shouldn't colide. It's all very small Bash so use the Source Luke and don't spend time on stupid tooling.
