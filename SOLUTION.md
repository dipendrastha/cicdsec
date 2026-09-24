# Solution: GitHub Actions Context Injection

This is author material. Do not distribute it with the player handout until the event is complete.

## 1. Attacker-controlled input

The vulnerable step uses `github.event.pull_request.title`. A PR author controls that title. The same class of bug can affect branch names, commit messages, issue titles, labels, or other event fields whenever untrusted data is inserted into a shell script.

## 2. What GitHub does

Before the runner executes a `run:` step, GitHub evaluates `${{ ... }}` expressions and produces a temporary shell script. Conceptually, the workflow contains:

```yaml
run: |
  echo "Processing contributor title: ${{ github.event.pull_request.title }}"
```

With a normal title, the generated script is harmless:

```bash
echo "Processing contributor title: Fix typo"
```

With a title such as:

```text
"; printf '%s\n' "$CTF_FLAG"; echo "
```

the generated script becomes conceptually:

```bash
echo "Processing contributor title: "; printf '%s\n' "$CTF_FLAG"; echo ""
```

The title is not merely an argument to `echo`; its quote and command-separator characters are parsed as shell syntax.

## 3. Recovering the flag

The challenge job defines only this synthetic value:

```yaml
env:
  CTF_FLAG: DEVOPS_CTF{github_actions_context_injection}
```

The injected `printf` reads `CTF_FLAG`. In the hosted workflow it appears in the job log. In the local Docker version, the same generated-script behavior is implemented by `scripts/challenge.sh`.

The intended author test is:

```text
"; printf '%s\n' "$CTF_FLAG"; echo "
```

After the vulnerable step, normal validation runs and `actions/github-script` posts `Thank you for the PR`.

## 4. Why the secure version differs

Do not interpolate untrusted data into a shell program. Pass it through the step environment and quote the variable:

```yaml
env:
  PR_TITLE: ${{ github.event.pull_request.title }}
run: |
  printf '%s\n' "$PR_TITLE"
```

Now the shell parses `$PR_TITLE` as a variable reference before it obtains the value. Quotes, semicolons, and command substitutions in the value remain data; they are not reparsed as shell syntax. This is also why `printf '%s\n' "$PR_TITLE"` is preferable to unquoted `echo`.

## 5. Additional hardening

* Use the smallest permissions possible. This challenge requests only `contents: read` and `pull-requests: write` for the comment.
* Do not put real secrets in a job that processes untrusted PR input or executes untrusted PR code.
* Prefer `pull_request` for ordinary PR validation. Be extremely cautious with `pull_request_target`: it runs in the base repository context and can expose a write-capable token or secrets if it checks out and executes the attacker’s branch.
* Never “fix” this pattern with `eval`; remove the extra shell evaluation entirely.
* Quote shell variables and validate/allow-list values where practical.
* Pin third-party actions to reviewed full commit SHAs in production rather than floating tags. The readable tags in this teaching repository are a deliberate convenience.
* Keep privileged automation separate from workflows that build or execute untrusted code.

## Optional second stage

An unsafe follow-up variant would use `pull_request_target` and then check out the PR head before executing repository scripts. That combination is intentionally omitted from the default workflow because it creates a materially more dangerous trust-boundary exercise. If an organizer adds it, use only synthetic credentials and an isolated disposable repository, and explain that the base repository’s token/secrets may become reachable by attacker-controlled code.
