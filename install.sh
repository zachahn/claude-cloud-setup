#!/bin/sh
set -eu

base_url="${CLAUDE_CLOUD_SETUP_URL:-https://raw.githubusercontent.com/zachahn/claude-cloud-setup/main}"

curl -fsSL "$base_url/claude_dev_setup" -o /usr/local/bin/claude_dev_setup
chmod +x /usr/local/bin/claude_dev_setup
