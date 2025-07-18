WASI_SDK_PATH ?= /opt/wasi-sdk
CC	      = $(WASI_SDK_PATH)/bin/clang
SYSROOT       = --sysroot=$(WASI_SDK_PATH)/share/wasi-sysroot
CFLAGS	      = --target=wasm32-wasi $(SYSROOT) -O2 -Isrc/common -Wl,--export-all -Wl,--no-entry
MODULE_DIRS   := $(wildcard src/modules/*)
MODULES       := $(notdir $(MODULE_DIRS))
OUT_DIR       = web/wasm

.PHONY: $(MODULES) all clean

all: $(MODULES)

$(MODULES):
	$(CC) $(CFLAGS) $(shell find src/modules/$@ -name '*.c') -o $(OUT_DIR)/$@.wasm

clean:
	rm -f $(OUT_DIR)/*.wasm

