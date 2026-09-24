# DevOps CI Injection CTF

This repository is an intentionally vulnerable GitHub Actions challenge about command injection through attacker-controlled pull-request metadata.

The workflow runs on pull requests, checks out the repository, inserts the PR title directly into a shell command, runs `app.js`, and posts:

```text
Thank you for the PR
```

## Setup

Use only a disposable GitHub repository. Create a repository secret named `FLAG` with the synthetic value:

```text
DEVOPS_CTF{github_actions_context_injection}
```

The workflow exposes it only to the challenge job as:

```yaml
env:
  FLAG: ${{ secrets.FLAG }}
```

Never use real credentials, cloud credentials, production secrets, or a self-hosted runner with sensitive network access.

## Flow

```text
Pull request
     |
     v
GitHub Actions runner
     |
     v
PR title inserted into run: shell source
     |
     v
Command injection reads secrets.FLAG
     |
     v
node app.js -> PR comment: Thank you for the PR
```

## Intended exploit

The PR title is attacker-controlled. A title conceptually shaped like this can terminate the generated `echo` string, run a command, and restore the surrounding syntax:

```text
"; printf '%s\n' "$FLAG"; echo "
```

The flag is synthetic and is intentionally available only in the disposable challenge repository. See [SOLUTION.md](SOLUTION.md) for the full explanation and secure remediation.

## Files

- `.github/workflows/pr-check.yml` — intentionally vulnerable workflow
- `app.js` — harmless validation fixture
- `README.md` — setup and safety notes
- `SOLUTION.md` — author walkthrough
