# JSCC WebAssembly Bridge Makefile

CC = clang
CFLAGS = --target=wasm32 -nostdlib -Wl,--no-entry -Wl,--export-dynamic \
         -Wl,--import-memory -Wl,--export=malloc -Wl,--export=free \
         -O2 -flto -fno-builtin

SOURCES = demo.c
HEADERS = jscc.h
WASM_OUTPUT = demo.wasm
JS_FILES = jscc.js
HTML_FILES = index.html

.PHONY: all clean serve

all: $(WASM_OUTPUT)

$(WASM_OUTPUT): $(SOURCES) $(HEADERS)
	$(CC) $(CFLAGS) -o $@ $(SOURCES)

clean:
	rm -f $(WASM_OUTPUT)

serve: all
	@echo "Starting local server on http://localhost:8080"
	@python3 -m http.server 8080 2>/dev/null || python -m SimpleHTTPServer 8080

install-deps:
	@echo "Installing cimgui headers..."
	@curl -L https://github.com/cimgui/cimgui/releases/latest/download/cimgui.h -o cimgui.h || \
	 echo "Please manually download cimgui.h from https://github.com/cimgui/cimgui"

help:
	@echo "Available targets:"
	@echo "  all         - Build WebAssembly module"
	@echo "  clean       - Remove built files"
	@echo "  serve       - Start local development server"
	@echo "  install-deps - Download required headers"
	@echo "  help        - Show this help message"

