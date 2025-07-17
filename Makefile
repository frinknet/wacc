# Makefile - standalone JSCC build (no jscc submodule)

CC = clang
CFLAGS = --target=wasm32 -nostdlib -Wl,--no-entry -Wl,--export-dynamic \
	 -Wl,--import-memory -Wl,--export=malloc -Wl,--export=free \
	 -O2 -flto -fno-builtin -Isrc -Icimgui

SRCDIR = src
WEBDIR = web
CIMGUIDIR = cimgui
SOURCES = $(wildcard $(SRCDIR)/*.c)
WASM_OUTPUT = $(WEBDIR)/demo.wasm

.PHONY: all clean serve submodules install-deps

all: install-deps $(WASM_OUTPUT)

$(WASM_OUTPUT): $(SOURCES) $(SRCDIR)/jscc.h $(CIMGUIDIR)/cimgui.h | $(WEBDIR)
	$(CC) $(CFLAGS) -o $@ $(SOURCES)

$(WEBDIR):
	mkdir -p $(WEBDIR)

submodules:
	@if [ ! -d "$(CIMGUIDIR)/.git" ]; then \
	  git submodule add https://github.com/cimgui/cimgui.git $(CIMGUIDIR); \
	fi
	git submodule update --init --recursive

install-deps: submodules

clean:
	rm -f $(WASM_OUTPUT)

serve: all
	@echo "Serving from $(WEBDIR) at http://localhost:8080"
	@cd $(WEBDIR) && (python3 -m http.server 8080 2>/dev/null || python -m SimpleHTTPServer 8080)

help:
	@echo "Available targets:"
	@echo "  all	       - Build WebAssembly module (standalone, no jscc submodule)"
	@echo "  install-deps  - Clone necessary submodules only (cimgui)"
	@echo "  clean	       - Remove built files"
	@echo "  serve	       - Start local dev server from web/"
	@echo "  help	       - Show this help message"

