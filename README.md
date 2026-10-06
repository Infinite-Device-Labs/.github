# .github

Infinite-Device-Labs' organization-wide GitHub files. GitHub reads this repo
by name, so it has to stay **public** and be called `.github`.

| File                                     | What GitHub does with it                                                                        |
| ---------------------------------------- | ----------------------------------------------------------------------------------------------- |
| [`profile/README.md`](profile/README.md) | Shown on the [organization page](https://github.com/Infinite-Device-Labs)                       |
| [`SECURITY.md`](SECURITY.md)             | The security policy for every repo in the org that doesn't have its own, private repos included |

Everything here is world-readable. Don't put anything internal in it.

## What doesn't live here

- **Repo settings and labels:** server-playbook's `github_repos` role.
- **CI, hooks, Dependabot and the commit conventions:** the `workflow` plugin's
  template, copied into each repo by its `new-repo` skill.
- **Issue and PR templates, `CONTRIBUTING`, code of conduct:** deliberately
  not set org-wide. A repo that needs them carries its own.

## Working on it

`just` lists every command. `just verify-all` is what CI runs; run
`just install-hooks` once after cloning. Changes go through a branch and a
PR like any other repo, and land on `main`, which is what GitHub reads.
