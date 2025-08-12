CC	     := clang
TARGET	     := wasm32
CFLAGS	     := --target=$(TARGET) -O2 -Ilibs/cimgui  -Ilibs/MinQND-libc -Ilibs/wacc/src/common -Isrc/common -Wl,--export-all -Wl,--no-entry
MODULE_DIRS  := $(wildcard src/modules/*)
MODULES      := $(notdir $(MODULE_DIRS))
OUT_DIR      := web/wasm

.PHONY: all clean $(MODULES)
all: $(MODULES)

$(MODULES):
	$(CC) $(CFLAGS) $(shell find src/modules/$@ -name '*.c') -o $(OUT_DIR)/$@.wasm

clean:
	rm -f $(OUT_DIR)/*.wasm
