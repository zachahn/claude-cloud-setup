#!/bin/bash
set -euo pipefail

base_url="${CLAUDE_CLOUD_SETUP_URL:-https://raw.githubusercontent.com/zachahn/claude-cloud-setup/main}"

for script in rv fnm postgres; do
  curl -fsSL "$base_url/$script.sh" | bash
done
