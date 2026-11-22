#!/bin/bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"

docker run --rm --platform linux/amd64 -v "$repo_dir:/src:ro" ubuntu:24.04 bash -euo pipefail -c '
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq curl ca-certificates unzip libatomic1 postgresql >/dev/null

export CLAUDE_CLOUD_SETUP_URL=file:///src

run_setup() {
  sh /src/install.sh
  claude_dev_setup rv
  claude_dev_setup fnm
  claude_dev_setup postgres
}

check() {
  local shell_flags=$1
  echo "--- bash $shell_flags"
  bash "$shell_flags" "rv --version && fnm --version && psql -d postgres -tAc \"select current_user\""
}

echo "=== first run"
run_setup
check -ic
check -lc

echo "=== node and ruby"
bash -ic "fnm install --lts && fnm exec --using=lts-latest node --version"
bash -ic "rv ruby install && rv ruby list"

echo "=== second run"
run_setup
check -ic
hook_count=$(grep -cF "for f in /etc/profile.d/claude-*.sh" /root/.bashrc)
echo "bashrc hook count: $hook_count"
test "$hook_count" -eq 1

echo "=== non-interactive bash -c"
bash -c "command -v rv fnm" || echo "rv/fnm not on PATH in bash -c"

echo "=== PASS"
'
