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

## Commands

If you're using the CLI the easiest way to do things you can use the following command:

```text

  WACC v1.2 // © 2025 FRINKnet & Friends
  MIT LICENSE - Suckless. Forkable. Hackable.

  Usage: wacc [command]

  Dead simple WASM dev environment for those who ONLY like C/C++ 

  wacc init [dir]           Create a new WACC project in [dir]
  wacc dev                  Start continuous build. Change are rebuilt.
  wacc down                 Pencil's down heads up turn off the server
  wacc serve [module]       Only run server and  jump to a module link
  wacc module [type]        Create a new module of the type sepcified
  wacc update               Update your code to fix customizations
  wacc upgrade              Upgrade the core to the latest WACC code
  wacc build [modules]      Quickly build only the modules you specify
  wacc pack [modules]       Package the modules you specify in a zip
  wacc logs [serve|build]   Show either the serve logs or build logs
  wacc env [name] [value]   Change your environment

  Get in, write code, ship fast, and leave the yak unshaved!!!!

```
There are also snarhy error messages guiding for almost anything. It's both fun and practical. The whole point of the WCC system is it's small and it works.

## Modularity

Another key component of this system is the modularity. You don't have to use the docker build system. You can just call `make` and it will build or call `make module` to run a specific module. In addition you have a server running `web/Caddyfile` that you can comstomize however you need. And if that's not enough you can for from this repo as a template. As I've already stated above you can install from a diferent repo  and if you inspect the internals you will find that this is the web equivalent to `dwm` where you get to customize it to your liking by rolling your own stuff very very easily.

## Organization

Code organization is straight fowarad in the `libs` you will find all third party libs in use. in '`src` you have `templates`, `modules` and `common` all doing what you expected. If you fork this for personal or corporate use you can create your own templates with boiler pliate as you see fit allowing much faster scaffolding. I try to stay lean and faily unopinionated about how you name your code. The only rules really are that all file in each module directory summed with common headers should become one WASM module. The templates are just modules designed to be starting points rather than finished examples. I've tried to cover the main use cases in the templates but I'm sure you'll tell me if it's not what you need.

## Internal Macros

The C code is built largely on macros to make things both reusable and extremely susinct. Most of the documentation should be in the header files in `src/common` and I've not yet taken time to provide extemsive documentation. The old phrase "Use the Source Luke" has always seemed a better direction than an overactive imagination in prose. I'll come back and write more later but I don't have time right now. However the headers from my end are a reasonable length and should provide everything you need.

## Liscense

I almost put this at BSD0 but decided that MIT is probably the most well known ad respected license. Although I have great respect for Rob Landley I feel that attribution should still be a cornerstone and therefore have put it into my work. Butt if there are Baboons out there that want to howl and quible this is a free world and you are free to do whatever. Just tell everyone where you got the code and we'll call it a day. FRINKnet is an obfixscation construct so that you can fill in your on Ur-Verb as you compare FRINK with GORETS or so the alt.fans.lemus newsgroup clained years ago. I can ttell you to do good but you're going to do what you're going to do. So use this to make a million dolars. It's fine with me.

