# .github — agent notes

Infinite-Device-Labs' special `.github` repo: the organization profile
(`profile/README.md`) and the org-wide default `SECURITY.md`. GitHub reads
both from `main`. `README.md` is the human-facing overview; keep both in step.

**This repo is public, and has to be**: GitHub uses default community health
files and the profile only from a public `.github`. Nothing internal goes in
here, including client names, private repo details and incident notes.

Use `just` for every command in this repo, never the underlying tool. Run
`just` with no arguments to list the recipes; each has a one-line
description there. If a command has no recipe, add one.

**`just verify-all` is the gate**, and CI runs exactly it on every push.
Run it before calling a change done. **`just install-hooks` once per
clone**: the hooks refuse commits and pushes to `main` and run
`verify-all` before a push. Merge with **`just pr-merge <branch>`**, which
waits for green. `scripts/check-*.py` and `.githooks/` are copies of the
workflow plugin's template: never edit them here.

## What belongs here

- **Only files GitHub reads from `.github`.** Repo settings and labels are
  server-playbook's `github_repos` role; CI, hooks and conventions are the
  workflow plugin's.
- **No org-wide issue or PR templates, `CONTRIBUTING` or code of conduct**,
  by decision: almost every issue and PR is made through `gh`, and a repo
  with anything in its own `ISSUE_TEMPLATE/` silently loses all the defaults.
- **The profile's wording follows infinitedevice.xyz.** It shows no email
  address, as the site doesn't: contact goes through the site's form.

## Git

- Commits, pushes, PRs and merges each need an explicit ask. Being asked to
  change something is not permission to commit it.
- [Conventional Commits](https://www.conventionalcommits.org/):
  `<type>(<scope>): <description>`, imperative, lowercase, no trailing
  period. `just lint-commits` checks them.
- New work starts in its own worktree on a `worktree-<topic>` branch, never
  on `main` in the primary clone. Merge commits only.

## Tracking deferred work

A GitHub issue, never a TODO here: this file is read every session, and a
TODO in it is a tracker nobody watches.
