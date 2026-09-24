# Challenge: The Helpful CI Bot

**Difficulty: Medium**

A development team has a CI workflow that checks pull requests. It checks out the repository, reads contributor metadata, logs what it is processing, runs a harmless validation, and leaves this comment when everything succeeds:

```text
Thank you for the PR
```

Your objective is to recover the synthetic CTF flag from the workflow execution. The flag format is:

```text
DEVOPS_CTF{...}
```

You may control pull-request metadata such as the PR title. You may use the disposable local Docker environment or a challenge repository prepared by the organizer. Do not attack any system outside the challenge.

The organizer guarantees that all credentials and flags are fake.

## Hints

### Hint 1

Not everything appearing inside a GitHub Actions workflow originates from the repository owner.

### Hint 2

Look at how GitHub context expressions interact with `run:` steps.

### Hint 3

Ask yourself whether the value becomes data passed to a program or part of the shell program itself.

### Hint 4

The shell has syntax for ending a quoted string, sequencing another command, and starting a quoted string again.

## Success condition

Recover the flag and explain why the workflow still reaches its normal validation and PR-comment steps after your input is processed.
