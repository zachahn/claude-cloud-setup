#!/bin/bash
set -euo pipefail

curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell

mkdir -p /root/.local/bin
ln -sf /root/.local/share/fnm/fnm /root/.local/bin/fnm

cat > /etc/profile.d/claude-fnm.sh <<'PROFILE'
export COREPACK_NPM_REGISTRY=https://registry.npmjs.org
export PATH="/root/.local/bin:/root/.local/share/fnm:$PATH"
eval "$(fnm env --use-on-cd --shell bash)"
PROFILE

read -r bashrc_hook <<'HOOK'
for f in /etc/profile.d/claude-*.sh; do . "$f"; done
HOOK
if ! grep -qF "$bashrc_hook" /root/.bashrc; then
  { echo "$bashrc_hook"; cat /root/.bashrc; } > /tmp/bashrc.new
  mv /tmp/bashrc.new /root/.bashrc
fi
