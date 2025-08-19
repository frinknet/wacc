SHELL := bash

CC := clang
LJ := luajit

OUT_WASM := web/wasm

BIN_TOOL := utils/extras

TOOL_EMBED := $(BIN_TOOL)/bin2c
TOOL_SHADE := $(BIN_TOOL)/shdc

TOOLS := \
	$(TOOL_EMBED) \
	$(TOOL_SHADE)

LIB_DIR		:= lib
LIB_IMGUI	:= lib/imgui
LIB_CIMGUI	:= lib/cimgui
LIB_JACLIBC := lib/jaclibc/include

LIBRARIES := \
	$(LIB_JACLLIBC) \
	$(LIB_IMGUI) \
	$(LIB_CIMGUI)

SRC_DIR    := src
SRC_COMMON := src/common
SRC_ASSETS := src/assets
SRC_MODULE := src/modules
SRC_SHADER := src/shaders
SRC_LUAGEN := src/generator
SRC_OUTPUT := src/output

SOURCES := \
	$(SRC_COMMON) \
	$(SRC_ASSETS) \
	$(SRC_MODULE) \
	$(SRC_OUTPUT) \
	$(SRC_SHADER)

CIMGUI = \
	$(SRC_COMMON)/cimgui.cpp \
	$(SRC_COMMON)/cimgui.h \
	$(SRC_COMMON)/cimgui_impl.cpp \
	$(SRC_COMMON)/cimgui_impl.h

COMMONS := \
	$(CIMGUI)

COMMON_SRCS := src/common/cimgui.cpp src/common/cimgui_impl.cpp
COMMON_OBJS := $(patsubst src/common/%.cpp,$(SRC_OUTPUT)/common/%.o,$(COMMON_SRCS))

MODULES := $(notdir $(wildcard $(SRC_MODULE)/*))

FONTS := $(patsubst $(SRC_ASSETS)/%,$(SRC_ASSETS)/font_$(call embed_name,%).h,$(wildcard $(SRC_ASSETS)/*.[tT][tT][fF]))

OUTPUTS := $(addprefix $(OUT_WASM)/,$(addsuffix .wasm,$(MODULES)))

TARGET := wasm32-unknown-unknown

CFLAGS := \
	--target=$(TARGET) \
	-O2 \
	-nostdlib \
	-mbulk-memory \
	-ffreestanding \
	-Wall \
	-Wno-unused-function \
	-I$(LIB_JACLIBC) \
	-I$(SRC_COMMON) \
	-I$(LIB_IMGUI) \
	-include wacc.h

LFLAGS := \
	-fuse-ld=lld \
	-Wl,--import-memory \
	-Wl,--export-all,--no-entry

IFLAGS := \
	-include imgui_internal.h \
	-include imgui.h \
	-include cimgui.h

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

.SUFFIXES:		# clear all
.SUFFIXES: .o .wasm  # only allow .o→.wasm

.PHONY: all clean $(MODULES)
all: $(OUTPUTS)

.PHONY: FORCE
FORCE:

modules: $(MODULES)
$(MODULES):
	@rm -f $(OUT_WASM)/$@.wasm
	@$(MAKE) $(OUT_WASM)/$@.wasm

$(addprefix $(OUT_WASM)/,$(addsuffix .wasm,$(MODULES))): $(foreach m,$(MODULES),$(wildcard $(SRC_MODULE)/$m/*.c))

$(CIMGUI): $(SRC_LUAGEN) | $(SRC_COMMON)
	@say GEN $(CIMGUI)
	@cd $(SRC_LUAGEN) && IMGUI_PATH=$(shell realpath $(LIB_IMGUI)) $(LJ) generator.lua $(CC) internal glfw opengl3 opengl2 sdl2 >/dev/null
	@sed '/#include[[:space:]]*<[^>]*>/d' $(LIB_IMGUI)/imgui.h > $(SRC_COMMON)/imgui.h
	@sed '/#include[[:space:]]*<[^>]*>/d' $(LIB_IMGUI)/imgui_internal.h > $(SRC_COMMON)/imgui_internal.h
	@mv $(SRC_DIR)/cimgui* $(SRC_COMMON)/

libraries: $(LIBRARIES)
$(LIBRARIES): 
	@say GEN $(LIBRARIES)
	@git submodule update --init --recursive --depth 1

sources: $(SOURCES)
$(SOURCES):
	@say $@
	@mkdir -p $@

fonts: $(FONTS)
$(SRC_ASSETS)/font_%.h: $(SRC_ASSETS)/%.[tT][tT][fF] $(TOOL_EMBED)
	@say GEN $@
	@$(TOOL_EMBED) $< font_$(call embed_name,$<) > $@

tools: $(TOOLS)

$(BIN_TOOL):
	@say GEN $@
	@mkdir -p $(BIN_TOOL);

$(TOOL_SHDC):
	@say GEN $@
	@wget -qO $@ https://github.com/floooh/sokol-tools-bin/raw/refs/heads/master/bin/linux/sokol-shdc

$(TOOL_EMBED): $(LIB_IMGUI)/misc/fonts/binary_to_compressed_c.cpp
	@say GEN bin2c
	@$(CC) $< -o $@

$(SRC_LUAGEN): $(LIB_CIMGUI)/generator
	@say GEN $@
	@cp -r $< $@
	@say GEN $@/*
	@sed -i 's|"./imgui/|"|g;/#include[[:space:]]*<[^>]*>/d' $(SRC_LUAGEN)/*template*

.SUFFIXES: .c .o .wasm

$(SRC_OUTPUT)/common/%.o: src/common/%.cpp
	@say GEN $@
	@mkdir -p $(dir $@)
	@$(CC) -std=gnu++17 $(CFLAGS) -c $< -o $@

$(SRC_OUTPUT)/%.o: $(SRC_MODULE)/%/*.c | $(SRC_OUTPUT)
	@say GEN $@
	$(CC) -std=gnu++17 $(CFLAGS) $(IFLAGS) -xc++ -c $< -o $@

$(OUT_WASM):
	@say GEN $@
	@mkdir -p $@

$(OUT_WASM)/%.wasm: $(SRC_OUTPUT)/%.o $(COMMON_OBJS) | $(OUT_WASM)
	@say GEN $@
	@$(CC) -fuse-ld=lld -Wl,--export-all,--no-entry $^ -o $@

clean:
	@say DEL $(wildcard $(SRC_COMMON)/cimgui* $(SRC_COMMON)/imgui*.h $(SRC_LUAGEN)/* $(SRC_LUAGEN))
	@rm -rf $(wildcard $(SRC_COMMON)/cimgui* $(SRC_COMMON)/imgui*.h) $(SRC_LUAGEN)
	@say DEL $(wildcard $(SRC_OUTPUT)/*/*.* $(SRC_OUTPUT))
	@rm -rf $(SRC_OUTPUT)
	@say DEL $(wildcard $(OUT_WASM)/*.wasm)
	@rm -f $(OUT_WASM)/*.wasm
