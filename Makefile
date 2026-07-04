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

.DEFAULT_GOAL := help

.PHONY: help install install-skills install-opts list uninstall-skills

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

install: install-skills install-opts ## Install skills + Claude-Code add-ons

install-skills: ## Install skills via the skills CLI (symlink; SCOPE/AGENT/SKILL overridable)
	skills add $(SOURCE) --skill '$(SKILL)' -a $(AGENT) $(SCOPE) -y

install-opts: ## Distribute opts/claude/* into ~/.claude (subagents, hooks)
	scripts/install-opts.sh claude

list: ## Browse available skills in SOURCE without installing
	skills add $(SOURCE) --list

uninstall-skills: ## Remove this repo's skills from AGENT at SCOPE
	skills remove --skill '$(SKILL)' -a $(AGENT) $(SCOPE) -y
