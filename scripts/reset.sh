#!/usr/bin/env bash
set -euo pipefail

rm -f /tmp/devops-ci-ctf-*.sh /tmp/ctf-flag
docker rm -f devops-ci-ctf >/dev/null 2>&1 || true
docker rmi devops-ci-ctf >/dev/null 2>&1 || true
printf '%s\n' 'Challenge artifacts reset. Hosted instances must be reset by closing/deleting the disposable PR or repository.'
