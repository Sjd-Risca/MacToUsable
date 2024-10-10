#!/usr/bin/make -f
.ONESHELL:
.SHELLFLAGS = -e -o pipefail -u -c
SHELL := /bin/bash
MAKEFLAGS += --warn-undefined-variables

JSONNET_PATH = lib

DEST ?= $(HOME)/.config/karabiner/assets/complex_modifications/

SOURCES = $(wildcard sources/*.libsonnet)
ALL = $(subst sources/,out/,$(subst libsonnet,json,$(SOURCES)))

out/%.json: sources/%.libsonnet
	JSONNET_PATH=$(JSONNET_PATH) jsonnet $< > $@.tmp && mv $@.tmp $@ || rm $@.tmp

.PHONY: all
all: $(ALL)

.PHONY: export
export: all
	cp -vi out/* $(DEST)
