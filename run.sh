#!/usr/bin/dumb-init /bin/sh
set -e

# We need to capture these signals we we gracefully exit 
# Without missing logs 
function control_c {
  echo "[!] waiting 45 seconds to finish writing logs before exiting..."
  sleep 45
  exit 
}
trap control_c SIGINT
trap control_c SIGTERM

for v in $(env | grep ^NOMAD_META_ | cut -d= -f1); do
  if [ -n "$meta_vars" ]; then
    meta_vars="${meta_vars},${v}"
  else
    meta_vars="${v}"
  fi
done

#export DEVICE_ID=$(python get_device_ids.py)
sigil -f ./filebeat.yml.tmpl meta_vars=$meta_vars > ./filebeat.yml



exec "$@"
