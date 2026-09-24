# Solution: GitHub Actions Context Injection

This is author material.

## Vulnerable input

The workflow uses `github.event.pull_request.title` inside a `run:` block. A pull-request author controls that title.

## Why it works

GitHub evaluates `${{ ... }}` expressions before sending the `run:` block to the runner. The result becomes a temporary shell script. With a normal title, the script is equivalent to:

```bash
echo "Processing contributor title: Fix typo"
```

With a title such as:

```text
"; printf '%s\n' "$FLAG"; echo "
```

the generated shell source becomes conceptually:

```bash
echo "Processing contributor title: "; printf '%s\n' "$FLAG"; echo ""
```

The quote closes the original string, `;` separates commands, and the final quote restores valid shell syntax. The injected `printf` reads `FLAG`, which the workflow receives from the synthetic repository secret `secrets.FLAG`.

## Secure remediation

Pass untrusted values through the environment instead of inserting them into shell source:

```yaml
env:
  PR_TITLE: ${{ github.event.pull_request.title }}
run: |
  printf '%s\n' "$PR_TITLE"
```

Here the shell parses `$PR_TITLE` as a variable reference. Metacharacters in the value remain data and are not reparsed as shell syntax. Avoid `eval`, use quoted variables, and prefer `printf` with a format string.

## Additional hardening

- Use only the minimum workflow permissions. This challenge needs `contents: read` and `pull-requests: write` for the comment.
- Keep `FLAG` synthetic and scoped to the disposable repository. Never expose production secrets to untrusted PR workflows.
- Prefer `pull_request` for ordinary validation. Be especially cautious with `pull_request_target`, which runs in the base repository context; checking out and executing an attacker’s branch there can expose the base repository token or secrets.
- Keep privileged automation separate from workflows that execute untrusted code.
- Pin third-party actions to reviewed commit SHAs in production.
