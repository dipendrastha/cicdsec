# DevOps CI Injection CTF

**Difficulty:** Medium · **Topic:** GitHub Actions command injection · **Status:** intentionally vulnerable training material

This disposable challenge models a development team that logs a pull-request title before running normal validation. The title is attacker-controlled, but the workflow interpolates it directly into a generated shell script. A crafted title can therefore change shell syntax and execute a command that reads the synthetic flag.

No real credentials, cloud credentials, production data, or repository secrets are used. The live workflow exposes only `CTF_FLAG`, a fake flag created solely for this challenge.

## Architecture

```text
                    GitHub
                      |
                 Pull Request
                      |
                      v
             GitHub Actions Runner
                      |
                      v
             PR metadata extracted
                      |
        +-----------------------------+
        | Vulnerable shell invocation |
        +-----------------------------+
                      |
                 injection
                      |
                      v
                CTF flag read
                      |
                      v
                 Job completes
                      |
                      v
              PR comment created
             "Thank you for the PR"
```

## Quick start: local disposable environment

Requirements: Bash, Docker, and a POSIX-like host.

```bash
docker build -f docker/Dockerfile -t devops-ci-ctf .
docker run --rm -e PR_TITLE='normal validation title' devops-ci-ctf
```

The author test payload is:

```text
"; printf '%s\n' "$CTF_FLAG"; echo "
```

Run it locally without letting your interactive shell interpret it:

```bash
PR_TITLE='"; printf '\''%s\n'\'' "$CTF_FLAG"; echo "'
docker run --rm -e "PR_TITLE=$PR_TITLE" devops-ci-ctf
```

The image runs `scripts/challenge.sh`, which simulates the shell script GitHub Actions generates after expression expansion.

## Deploying the GitHub version

1. Create a **new disposable repository** in a throwaway GitHub organization or account.
2. Push this repository to it and enable Actions.
3. Keep the default workflow permissions restricted. The workflow declares only `contents: read` and `pull-requests: write`.
4. Open a PR from a test branch. The workflow validates it and, on success, posts `Thank you for the PR`.
5. Players can update the PR title and inspect workflow output for the synthetic flag.
6. Delete the disposable repository when the event is over.

The workflow uses `pull_request`, not `pull_request_target`, and does not read repository secrets. GitHub may restrict write tokens for fork PRs depending on repository/org policy; the Docker path is the canonical fallback.

## Reset

```bash
./scripts/reset.sh
```

This removes only `/tmp/devops-ci-ctf-*` files and the project-tagged local Docker image/container. For a hosted instance, close/delete the disposable PR or repository.

## Security warnings

This repository is intentionally vulnerable. Do not run it in production, on a self-hosted runner with network access, or beside real credentials. Use a disposable GitHub repository or the Docker image. Never add actual secrets to `CTF_FLAG`; it is intentionally a plain environment variable. Do not grant cloud permissions or broaden the workflow token.

The secure reference passes the title through `env:` and quotes the shell variable. It keeps the privileged comment step separate from any future untrusted-code execution.

See [CHALLENGE.md](CHALLENGE.md) for the player handout and [SOLUTION.md](SOLUTION.md) for the walkthrough.
