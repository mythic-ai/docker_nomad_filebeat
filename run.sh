#!/usr/bin/dumb-init /bin/sh
set -x
# We need to capture these signals we we gracefully exit 
# Without missing logs 
function control_c {
  echo "[!] waiting 45 seconds to finish writing logs before exiting..."
  sleep 45
  exit 
}
function cleanup()
{
    echo "$1"
    exit 0
}

trap 'cleanup SIGINT' SIGINT
trap 'cleanup TERM' SIGTERM
trap 'cleanup SIGABRT' SIGABRT
trap 'cleanup SIGKILL' SIGKIL

for v in $(env | grep ^NOMAD_META_ | cut -d= -f1); do
  if [ -n "$meta_vars" ]; then
    meta_vars="${meta_vars},${v}"
  else
    meta_vars="${v}"
  fi
done

#export DEVICE_ID=$(python get_device_ids.py)
sigil -f ./filebeat.yml.tmpl meta_vars=$meta_vars > ./filebeat.yml

filebeat -e&
while true; do sleep .5; done
