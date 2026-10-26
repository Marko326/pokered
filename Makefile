# CHS_Mod maintenance wrapper: src/ is authoritative; buildRB/ is generated.
# ROMs and VC patches are published at the repository root, like pret/pokered.
.DEFAULT_GOAL := all
PYTHON ?= python3
BUILD_DIR := buildRB

ROMS := pokered.gbc pokeblue.gbc pokered_debug.gbc pokeblue_debug.gbc \
        pokered_vc.gbc pokeblue_vc.gbc
PATCHES := pokered.patch pokeblue.patch

# The upstream build system uses shared temporary files/tools. Avoid races
# between separate recursive makes, especially with `make -j all`.
.NOTPARALLEL:
.PHONY: all prepare red blue red_debug blue_debug red_vc blue_vc clean rebuild help FORCE

prepare:
	$(PYTHON) scripts/prepare_build.py

# Explicit dependency edges make the outputs discoverable by IDE/mobile
# build tools that inspect Makefile rules without executing recursive make.
all: red blue red_debug blue_debug red_vc blue_vc
red: pokered.gbc
blue: pokeblue.gbc
red_debug: pokered_debug.gbc
blue_debug: pokeblue_debug.gbc
red_vc: pokered.patch pokered_vc.gbc
blue_vc: pokeblue.patch pokeblue_vc.gbc

# Always ask the nested make to check incremental dependencies: changes in
# src/ must be noticed even when a root-level ROM already exists.
# Use an order-only prepare step so it runs before the nested make.
FORCE:

$(ROMS) $(PATCHES): FORCE | prepare
	+$(MAKE) -C $(BUILD_DIR) $@
	@if ! cmp -s "$(BUILD_DIR)/$@" "$@"; then cp "$(BUILD_DIR)/$@" "$@"; fi

clean:
	$(RM) $(ROMS) $(PATCHES)
	$(RM) -r $(BUILD_DIR)

rebuild:
	+$(MAKE) clean
	+$(MAKE) all

help:
	@printf '%s\n' 'make red       Compile ./pokered.gbc' \
	  'make blue      Compile ./pokeblue.gbc' \
	  'make           Compile all ROM and VC patch targets' \
	  'make prepare   Regenerate translated sources only when needed' \
	  'make clean     Delete generated ROMs and buildRB/' \
	  'make rebuild   Regenerate and build everything'
