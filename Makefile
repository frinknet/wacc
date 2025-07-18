CC = clang
CFLAGS = --target=wasm32-wasi -O2 -nostdlib -Wl,--no-entry -Wl,--export-all
INCLUDES = -Isrc/common
SRC_DIR = src/modules
OUT_DIR = web/wasm
MODULES = $(basename $(notdir $(wildcard $(SRC_DIR)/**/*.c)))
WASM_TARGETS = $(addprefix $(OUT_DIR)/, $(addsuffix .wasm, $(MODULES)))

all: $(WASM_TARGETS)

$(OUT_DIR)/%.wasm: $(SRC_DIR)/**/%.c
	@mkdir -p $(OUT_DIR)
	$(CC) $(CFLAGS) $(INCLUDES) $< -o $@

clean:
	rm -f $(OUT_DIR)/*.wasm
