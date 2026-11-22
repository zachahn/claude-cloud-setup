#!/bin/bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"

docker run --rm --platform linux/amd64 -v "$repo_dir:/src:ro" ubuntu:24.04 bash -euo pipefail -c '
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq curl ca-certificates unzip xz-utils libatomic1 postgresql >/dev/null

export CLAUDE_CLOUD_SETUP_URL=file:///src

run_setup() {
  sh /src/install.sh
  claude_dev_setup rv
  claude_dev_setup fnm
  claude_dev_setup postgres
}

ruby_checks="rv --version && ruby --version && gem --version && bundle --version && ruby -e \"require %q(json); puts JSON.generate(ok: true)\""

check_ruby() {
  echo "--- bash -ic"
  bash -ic "$ruby_checks"
  echo "--- bash -lc"
  bash -lc "$ruby_checks"
  echo "--- bash -c"
  bash -c "$ruby_checks"
  echo "--- bash -c with minimal environment"
  env -i HOME=/root PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin bash -c "$ruby_checks"
}

check_others() {
  echo "--- fnm and postgres"
  bash -ic "fnm --version && psql -d postgres -tAc \"select current_user\""
  bash -lc "fnm --version && psql -d postgres -tAc \"select current_user\""
}

echo "=== first run"
run_setup
check_ruby
check_others

echo "=== .ruby-version is honored in bash -c"
mkdir -p /tmp/project
echo 3.4 > /tmp/project/.ruby-version
(cd /tmp/project && rv ruby install)
(cd /tmp/project && bash -c "ruby --version") | grep -F "ruby 3.4"

echo "=== node"
bash -ic "fnm install --lts && fnm exec --using=lts-latest node --version"

echo "=== second run"
run_setup
check_ruby
hook_count=$(grep -cF "for f in /etc/profile.d/claude-*.sh" /root/.bashrc)
echo "bashrc hook count: $hook_count"
test "$hook_count" -eq 1

echo "=== PASS"
'
