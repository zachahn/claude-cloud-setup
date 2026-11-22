#!/bin/bash
set -euo pipefail

curl -LsSf https://rv.dev/install | RV_NO_MODIFY_PATH=1 sh

rv_install_dir="${XDG_BIN_HOME:-$HOME/.local/bin}"
ln -sf "$rv_install_dir/rv" /usr/local/bin/rv
ln -sf "$rv_install_dir/rvx" /usr/local/bin/rvx

# Ruby to preinstall. rv can only resolve an exact version here: listing
# rubies needs api.github.com, which cloud sandboxes block. Keep in sync with
# the .ruby-version of the apps you work on, or override with RUBY_VERSION.
rv ruby install "${RUBY_VERSION:-4.0.10}"

eval "$(rv shell env bash)"
for ruby_executable in "$RUBY_ROOT"/bin/*; do
  cat > "/usr/local/bin/${ruby_executable##*/}" <<'WRAPPER'
#!/bin/bash
eval "$(rv shell env bash)"
exec "$RUBY_ROOT/bin/${0##*/}" "$@"
WRAPPER
  chmod +x "/usr/local/bin/${ruby_executable##*/}"
done

cat > /etc/profile.d/claude-rv.sh <<'PROFILE'
eval "$(rv shell init bash)"
PROFILE

read -r bashrc_hook <<'HOOK'
for f in /etc/profile.d/claude-*.sh; do . "$f"; done
HOOK
touch /root/.bashrc
if ! grep -qF "$bashrc_hook" /root/.bashrc; then
  { echo "$bashrc_hook"; cat /root/.bashrc; } > /tmp/bashrc.new
  mv /tmp/bashrc.new /root/.bashrc
fi
