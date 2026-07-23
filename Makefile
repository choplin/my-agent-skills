# Makefile — install this repo's skills and Claude-Code add-ons locally.
#
# Skills are distributed via the vercel-labs/skills CLI; agent-specific extras
# (subagents, hooks) under opts/ are distributed by scripts/install-opts.sh.
# See README.md and docs/skill-first-architecture.md for the full model.

# --- Overridable knobs -------------------------------------------------------
# AGENT  : space-separated skills-CLI agent ids, or '*' for all 70+ agents.
# SKILL  : skill name to install, or '*' for all.
# SOURCE : skill source. './skills' installs from this working tree;
#          'choplin/my-agent-skills' installs the published repo instead.
# SCOPE  : '-g' for global (user-level), empty for project-level.
AGENT  ?= claude-code codex
SKILL  ?= *
SOURCE ?= ./skills
SCOPE  ?= -g

# Manifest: the set of skill names this repo has installed into the shared store
# (~/.agents/skills). The store's lock never records local-path/gist installs, so
# we keep our own list: install unions names in, purge removes them and clears it.
MANIFEST := $(HOME)/.agents/.my-agent-skills.manifest

.DEFAULT_GOAL := help

.PHONY: help install install-skills install-opts manifest-record list validate-skills reset purge

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: install-skills manifest-record install-opts ## Install skills + record them in the manifest + Claude-Code add-ons

install-skills: ## Install skills via the skills CLI (symlink; SCOPE/AGENT/SKILL overridable)
	skills add $(SOURCE) --skill '$(SKILL)' -a $(AGENT) $(SCOPE) -y

install-opts: ## Distribute opts/claude/* into ~/.claude (subagents, hooks)
	scripts/install-opts.sh claude

manifest-record: ## Union the skills the CLI installs from SOURCE into the install manifest
	@{ cat $(MANIFEST) 2>/dev/null; \
		skills add $(SOURCE) --list 2>&1 | grep -E '│[[:space:]]+[a-z0-9][a-z0-9-]*[[:space:]]*$$' | awk '{print $$NF}'; } \
		| sort -u > $(MANIFEST).tmp && mv $(MANIFEST).tmp $(MANIFEST)
	@echo "manifest: $$(grep -c . $(MANIFEST)) skill(s) tracked as this repo's"

list: ## Browse available skills in SOURCE without installing
	skills add $(SOURCE) --list

validate-skills: ## Validate every skill strictly with skill-validator
	scripts/validate-skills.sh

reset: ## Purge this repo's skills & add-ons, then reinstall from SOURCE (clears renamed/deleted leftovers)
	$(MAKE) purge
	$(MAKE) install
	@echo "reset complete: renamed/deleted skills and add-ons are gone; current SOURCE is installed."

purge: ## Uninstall this repo's skills (per manifest) from the store, clear the manifest, remove opts
	@names="$$(cat $(MANIFEST) 2>/dev/null)"; \
		if [ -n "$$names" ]; then skills remove $$names $(SCOPE) -y; else echo "manifest empty; no skills to remove"; fi
	@: > $(MANIFEST)
	scripts/uninstall-opts.sh claude
