# .github: every command this repo has. `just` with no arguments lists them.
#
# Started from the workflow plugin's justfile-conventions template
# (LealSoftware/claude-plugins). This file is the repo's own, so adapt it.
# scripts/check-commits.py, scripts/check-claude-md.py and .githooks/ are
# copies of the template's and are never edited here: change them in the
# template and copy them back, so every repo checks the same way.
#
# If the repo relies on a .env file, make the first line
# `set dotenv-load := true`.

default:
    @just --list

# --- The stack -------------------------------------------------------------
#
# Paste in stack-node.just, stack-rust.just or stack-docs.just from the
# template (or write the equivalent), keeping the standard names: install,
# dev, build, check, lint, format, format-check, test, clean. Then put its
# checks at the front of verify-all below.

# --- Shared checks ---------------------------------------------------------

# Add --no-scope (a repo without components yet) or --scopes a,b to match
# the repo's CLAUDE.md. The script takes them as flags so it never needs
# editing here.
[doc("Conventional Commits on every commit since base")]
lint-commits base="origin/main":
    python3 scripts/check-commits.py --base {{ base }}

# A credential that reaches git history stays there, so the whole history is
# scanned, not just the diff. CI installs gitleaks at a pinned version.
[doc("Fail on a credential anywhere in git history")]
scan-secrets:
    gitleaks git --no-banner --redact --exit-code 1 .

[doc("CLAUDE.md and SKILL.md length, TODO headings and @-imports")]
check-claude-md:
    python3 scripts/check-claude-md.py

# What CI runs on every push, and what the pre-push hook runs before one.
# The stack's format-check, lint, check and test go first: cheapest first,
# so a formatting slip fails in a second, not after the suite.
[doc("Every check CI runs; the pre-push hook runs it too")]
verify-all: format-check lint lint-commits scan-secrets check-claude-md

# --- Shipping --------------------------------------------------------------

# Once per clone. GitHub's free plan has no branch protection on private
# repos, so these hooks and pr-merge are what refuse a commit or push to
# main or staging. See .githooks/ for the escape hatches.
[doc("Install the git hooks: no commits on main/staging, verify-all before a push")]
install-hooks:
    git config core.hooksPath .githooks
    @echo "installed: pre-commit refuses commits on main and staging"
    @echo "installed: pre-push refuses pushes to them, then runs just verify-all (SKIP_VERIFY=1 skips the checks)"

# The shared script, from the installed workflow plugin rather than a copy:
# it runs only on a developer's machine, never in CI.
[doc("Merge a PR on green with a merge commit, then remove its worktree and branches")]
pr-merge +args:
    #!/usr/bin/env bash
    set -euo pipefail
    script="$HOME/.claude/plugins/marketplaces/leal-software/plugins/workflow/skills/ship-change/scripts/pr-merge.sh"
    [ -f "$script" ] || { echo "pr-merge: install the workflow plugin first: claude plugin marketplace add LealSoftware/claude-plugins && claude plugin install workflow@leal-software" >&2; exit 1; }
    exec bash "$script" {{ args }}

# --- The stack: documentation only (Markdown) ------------------------------
# markdownlint for structure, Prettier for formatting, both
# from package.json's devDependencies.
# verify-all: format-check lint lint-commits scan-secrets check-claude-md

[doc("Install the lint and format tools")]
install:
    npm ci

[doc("Lint every Markdown file")]
lint:
    npx markdownlint-cli2 "**/*.md" "#node_modules"

[doc("Format everything, writing changes")]
format:
    npx prettier --write .

[doc("Check formatting without writing (what CI runs)")]
format-check:
    npx prettier --check .
