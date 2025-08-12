SHELL := bash

CC := clang
LJ := luajit

TARGET := wasm32
CFLAGS := --target=$(TARGET) -O2 \
	-I$(SRC_COMMON) \
	-I$(SRC_ASSETS) \
	-I$(SRC_SHADER) \
	-Wl,--export-all \
	-Wl,--no-entry

BIN_TOOL := utils/extras

TOOL_EMBED := $(BIN_TOOL)/bin2c
TOOL_SHADE := $(BIN_TOOL)/shdc

TOOLS := \
	$(TOOL_COMP) \
	$(TOOL_GLSL)

LIB_JSCC   := libs/jscc
LIB_IMGUI  := libs/imgui
LIB_CIMGUI := libs/cimgui
LIB_MINQND := libs/MinQND-libc

LIBRARIES := \
	$(LIB_JSCC) \
	$(LIB_IMGUI) \
	$(LIB_CIMGUI)

SRC_LUAGEN := src/generator
SRC_GENOUT := $(SRC_LUAGEN)/output
SRC_COMMON := src/common
SRC_ASSETS := src/assets
SRC_MODULE := src/modules
SRC_SHADER := src/shaders

SOURCES := \
	$(SRC_GENOUT) \
	$(SRC_COMMON) \
	$(SRC_ASSETS) \
	$(SRC_MODULE) \
	$(SRC_SHADER)

COMMONS := \
	$(SRC_COMMON)/jscc.h \
	$(SRC_COMMON)/jscc.h \
	$(SRC_COMMON)/cimgui.cpp \
	$(SRC_COMMON)/cimgui.h

MODULES := $(notdir $(wildcard $(SRC_MODULE)/*))

FONTS := $(patsubst $(SRC_ASSETS)/%,$(SRC_ASSETS)/font_$(call embed_name,%).h,$(wildcard $(SRC_ASSETS)/*.[toTO][tT][fF]))

OUT_WASM := web/wasm

OUTPUTS := \
	$(OUT_WASM)

define BASH_FUNC_say%%
() {
	for x in $$@; do
		if [ "$$1" != "$$x" ]; then
			echo -e "$$1\t$$x"
		fi
	done
}
endef
export BASH_FUNC_say%%

embed_name = $(shell echo "$(basename $(1))" | sed 's/[.]ttf$$//i; s/ /_/g; y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/')

.PHONY: all clean $(MODULES)
all: modules

modules: $(MODULES)
$(MODULES): 
	@say GEN $(OUT_WASM)/$@.wasm
	@$(CC) $(CFLAGS) $(wildcard $(SRC_MODULE)/$@/*.c) -o $(OUT_WASM)/$@.wasm

$(addsuffix .wasm,$(MODULES)): $(foreach m,$(MODULES),$(wildcard $(SRC_MODULE)/$m/*.c))

libraries: $(LIBRARIES)
$(LIBRARIES): 
	@say GEN $@
	@git submodule update --init --recursive --depth 1

sources: $(SOURCES)
$(SOURCES):
	@say GEN $@
	@mkdir -p $@

fonts: $(FONTS)
$(SRC_ASSETS)/font_%.h: $(SRC_ASSETS)/%.[toTO][tT][fF] $(TOOL_EMBED)
	@say GEN $@
	@$(TOOL_EMBED) $< font_$(call embed_name,$<) > $@

tools: $(TOOLS)

$(BIN_TOOL):
	@say GEN $@
	@mkdir -p $(BIN_TOOL);

$(TOOL_SHDC):
	@say GEN $@
	@wget -qO $@ https://github.com/floooh/sokol-tools-bin/raw/refs/heads/master/bin/linux/sokol-shdc

$(TOOL_COMP): $(LIB_IMGUI)/misc/fonts/binary_to_compressed_c.cpp
	@say GEN $@
	@$(CC) $< -o $@

commons: $(COMMONS) 

$(SRC_COMMON)/jscc.h: $(LIB_JSCC)/jscc.h
	@say GEN $@
	@cp $< $@

$(SRC_COMMON)/cimgui.cpp $(SRC_COMMON)/cimgui.h: $(SRC_LUAGEN)/out
	@$cd $(SRC_LUAGEN); (LJ)  generator.lua $(CC) internal glfw opengl3 opengl2 sdl -DIMGUI_USER_CONFIG="\"../common/imgui_config.h\"" &>/dev/null
	@cp -r $(SRC_LUAGEN)/output/* $(SRC_COMMON)/

$(SRC_LUAGEN) $(SRC_LUAGEN)/generator.lua: $(LIB_CIMGUI)/generator
	@say GEN $@
	@cp -r $< $@

outputs: $(OUTPUTS)
$(OUTPUT):
	@say GEN $@
	@mkdir -p $@

clean: clean-out clean-gen

clean-out:
	@say DEL $(OUT_WASM) 
	@rm -rf $(OUT_WASM) 

clean-gen:
	@say DEL $(DIR_COMMON)/gen
	@rm -rf $(DIR_COMMON)/gen 
