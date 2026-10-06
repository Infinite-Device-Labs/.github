#!/usr/bin/env python3
"""Conventional Commits check over every commit on the branch.

    check-commits.py [--base origin/main] [--no-scope | --scopes a,b]

Copied from the workflow plugin's justfile-conventions template
(LealSoftware/claude-plugins). Never edit it here: change it there and copy
it back, so every repo checks commits the same way. A repo's own rules come
in as flags, which is why the script never needs editing.

Every commit since the merge base with --base, merges excluded (GitHub's
"Merge pull request" isn't one we author), must be
`<type>(<scope>)!: <description>` with a known type, a lowercase first letter,
no trailing period, and a header of at most 72 characters. The scope is
optional and any lowercase word unless --no-scope (the repo has no
components yet) or --scopes (only these) says otherwise.

Commits by dependabot[bot] are skipped. Its headers are generated, not
authored, and dependabot.yml's commit-message prefix already types them,
but a grouped update reads "build: Bump the ... group across 1 directory
with 2 updates": capitalised and over 72 characters, which would fail every
grouped Dependabot PR's CI.

Stdlib only, so a repo needs no Node toolchain for it.
"""
import argparse
import re
import subprocess
import sys

TYPES = "feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert"
HEADER_RE = re.compile(
    rf"^(?P<type>{TYPES})(?:\((?P<scope>[a-z0-9_-]+)\))?(?P<bang>!)?: (?P<desc>\S.*)$"
)
MAX_HEADER = 72
GENERATED_BY = ("dependabot[bot]",)


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--base", default="origin/main")
    group = ap.add_mutually_exclusive_group()
    group.add_argument("--no-scope", action="store_true", help="refuse any scope")
    group.add_argument("--scopes", default="", help="comma-separated scopes allowed")
    args = ap.parse_args()
    allowed = [s for s in args.scopes.split(",") if s]

    if subprocess.run(["git", "rev-parse", "--verify", "--quiet", args.base],
                      capture_output=True).returncode != 0:
        print(f"lint-commits: base {args.base!r} isn't available here, so nothing was checked")
        return 0
    log = subprocess.run(
        ["git", "log", "--no-merges", "--format=%h%x00%an%x00%s", f"{args.base}..HEAD"],
        capture_output=True, text=True, check=True,
    ).stdout

    problems = []
    skipped = 0
    for line in filter(None, log.splitlines()):
        sha, author, header = line.split("\x00", 2)
        if author in GENERATED_BY:
            skipped += 1
            continue
        m = HEADER_RE.match(header)
        found = []
        if not m:
            found.append(f"not `<type>(<scope>): <description>` with a type in {TYPES}")
        else:
            desc, scope = m.group("desc"), m.group("scope")
            if desc[0].isupper():
                found.append("description starts with a capital letter")
            if desc.endswith("."):
                found.append("description ends with a period")
            if scope and args.no_scope:
                found.append("omit the scope: this repo has no components")
            elif scope and allowed and scope not in allowed:
                found.append(f"scope must be one of {', '.join(allowed)}")
        if len(header) > MAX_HEADER:
            found.append(f"header is {len(header)} characters, over {MAX_HEADER}")
        problems += [f"{sha}: {header!r}: {p}" for p in found]

    for p in problems:
        print(p)
    note = f", skipped {skipped} by dependabot" if skipped else ""
    print(f"lint-commits: {len(problems)} problem(s) since {args.base}{note}")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
