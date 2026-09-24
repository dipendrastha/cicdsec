#!/usr/bin/env bash
set -euo pipefail

test -s app/hello.txt
grep -Fq 'CI validation fixture' app/hello.txt
printf '%s\n' 'Validation successful.'
