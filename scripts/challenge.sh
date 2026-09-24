#!/usr/bin/env bash
set -euo pipefail

# Intentional vulnerability: PR_TITLE becomes shell source before Bash parses it.
: "${PR_TITLE:=normal validation title}"
if [[ -z "${CTF_FLAG:-}" ]]; then
  CTF_FLAG='DEVOPS_CTF{github_actions_context_injection}'
fi
export CTF_FLAG
generated="/tmp/devops-ci-ctf-${PPID}.sh"
trap 'rm -f "$generated"' EXIT

printf 'printf "Reading contributor commit...\\n"\n' > "$generated"
printf 'echo "Processing contributor title: %s"\n' "$PR_TITLE" >> "$generated"
bash "$generated"
./scripts/validate.sh
printf '%s\n' 'Thank you for the PR'
