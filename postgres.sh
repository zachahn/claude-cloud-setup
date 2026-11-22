#!/bin/bash
set -euo pipefail

service postgresql start

root_role_exists=$(su postgres -c "psql -tAc \"select 1 from pg_roles where rolname='root'\"")
if [ "$root_role_exists" != "1" ]; then
  su postgres -c "createuser -s root"
fi
