#!/usr/bin/make -f
.ONESHELL:
.SHELLFLAGS = -e -o pipefail -u -c
SHELL := /bin/bash
MAKEFLAGS += --warn-undefined-variables

JSONNET_PATH = lib

XDG_KARABINER ?= $(HOME)/.config/karabiner
DEST ?= $(XDG_KARABINER)/assets/complex_modifications/

SOURCES = $(wildcard sources/*.libsonnet)
ALL = $(subst sources/,out/,$(subst libsonnet,json,$(SOURCES))) out/karabiner.json

out/%.json: sources/%.libsonnet
	JSONNET_PATH=$(JSONNET_PATH) jsonnet $< > $@.tmp && mv $@.tmp $@ || rm $@.tmp

out/karabiner.json: karabiner.libsonnet $(wildcard sources/*)
	JSONNET_PATH=$(JSONNET_PATH) jsonnet $< > $@.tmp && mv $@.tmp $@ || rm $@.tmp

.PHONY: all
all: $(ALL)

.PHONY: export
export: all
	@for config in out/*; do
	    name="$$(basename "$${config}")"
	    if [ "$${name}" = "karabiner.json" ]; then
	        to="$(XDG_KARABINER)/$${name}"
	    else
	        to="$(DEST)/$${name}"
	    fi
	    if diff $$config $${to} ; then
	        echo $$config
	    else
	        cp -vi $$config $${to}
	    fi
	    done
