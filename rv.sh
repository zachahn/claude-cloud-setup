#!/bin/bash
set -euo pipefail

curl -LsSf https://rv.dev/install | sh

cat > /etc/profile.d/claude-rv.sh <<'PROFILE'
export PATH="/root/.local/bin:$PATH"
eval "$(rv shell init bash)"
PROFILE

read -r bashrc_hook <<'HOOK'
for f in /etc/profile.d/claude-*.sh; do . "$f"; done
HOOK
if ! grep -qF "$bashrc_hook" /root/.bashrc; then
  { echo "$bashrc_hook"; cat /root/.bashrc; } > /tmp/bashrc.new
  mv /tmp/bashrc.new /root/.bashrc
fi
