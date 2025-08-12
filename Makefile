<<<<<<< HEAD
CC	     := clang
TARGET	     := wasm32
CFLAGS	     := --target=$(TARGET) -O2 -Ilibs/cimgui  -Ilibs/MinQND-libc -Ilibs/wacc/src/common -Isrc/common -Wl,--export-all -Wl,--no-entry
MODULE_DIRS  := $(wildcard src/modules/*)
MODULES      := $(notdir $(MODULE_DIRS))
OUT_DIR      := web/wasm
=======
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

LIB_JSCC   := lib/jscc
LIB_SOKOL  := lib/sokol
LIB_IMGUI  := lib/imgui
LIB_CIMGUI := lib/cimgui

LIBRARIES := \
	$(LIB_JSCC) \
	$(LIB_SOKOL) \
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
	$(SRC_LUAGEN) \
	$(SRC_COMMON) \
	$(SRC_ASSETS) \
	$(SRC_MODULE) \
	$(SRC_SHADER)

ASSETS := $(wildcard $(SRC_ASSETS}/*)

COMMONS := \
	$(SRC_COMMON)/jscc.h \
	$(SRC_COMMON)/cimgui.cpp \
	$(SRC_COMMON)/cimgui.h

MODULES := $(notdir $(wildcard $(SRC_MODULE}/*))

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

lowercase=$(subst -,_,$(subst A,a,$(subst B,b,$(subst C,c,$(subst D,d,$(subst E,e,$(subst F,f,$(subst G,g,$(subst H,h,$(subst I,i,$(subst J,j,$(subst K,k,$(subst L,l,$(subst M,m,$(subst N,n,$(subst O,o,$(subst P,p,$(subst Q,q,$(subst R,r,$(subst S,s,$(subst T,t,$(subst U,u,$(subst V,v,$(subst W,w,$(subst X,x,$(subst Y,y,$(subst Z,z,$1)))))))))))))))))))))))))))
lcasefont=$(patsubst $(SRC_ASSETS)/%.ttf,font_%,$(call lowercase,$1))
fontnameh=$(SRC_ASSETS)/$(call lcasefont,$1).h
glslnameh=$(patsubst $(SRC_SHADER)/%.glsl,$(SRC_SHADER)/glsl_%.h,$1)

embed_file=$(TOOL_EMBED) -base85 $1 $2 > $3;
shade_glsl=$(BIN_TOOL)/sokol-shdc --input $1 --output $2 --slang $3;
>>>>>>> 3744021 (major make breaking changes)

.PHONY: all clean $(MODULES)
all: modules

modules: $(MODULES)
$(MODULES):
	@say GEN $(DIR_OUTPUT)/$@.wasm 
	@$(CC) $(CFLAGS) $(shell find $(DIR_MODULE}/$@ -name '*.c') -o $(DIR_OUTPUT)/$@.wasm

libraries: $(LIBRARIES)
$(LIBRARIES): 
	@say GEN $@
	@git submodule update --init --recursive --depth 1

sources: $(SOURCES)
$(SOURCES):
	@say GEN $@
	@mkdir -p $@

fonts: $(FONTS)
$(FONTS): $(BIN_TOOL)/bin2comp $(BIN_TOOL)
	@say GEN $@
	@$(foreach font, $(SRC_ASSETS), $(call embed_file,$(font),$(call lcasefont,$(font)),$(call fontnameh,$(font))))

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
