#!/usr/bin/dumb-init /bin/sh
set -e

for v in $(env | grep ^NOMAD_ | grep -v ^NOMAD_META_ | cut -d= -f1); do
  if [ "$v" = "NOMAD_MEMORY_LIMIT" ]; then continue; fi
  if [ "$v" = "NOMAD_CPU_LIMIT" ]; then continue; fi
  if [ "$v" = "NOMAD_ALLOC_DIR" ]; then continue; fi
  if [ "$v" = "NOMAD_TASK_DIR" ]; then continue; fi
  if [ "$v" = "NOMAD_SECRETS_DIR" ]; then continue; fi

  if [ -n "$nomad_vars" ]; then
    nomad_vars="${nomad_vars},${v}"
  else
    nomad_vars="${v}"
  fi
done

for v in $(env | grep ^NOMAD_META_ | cut -d= -f1); do
  if [ -n "$meta_vars" ]; then
    meta_vars="${meta_vars},${v}"
  else
    meta_vars="${v}"
  fi
done

sigil -f ./filebeat.yml.tmpl meta_vars=$meta_vars nomad_vars=$nomad_vars > ./filebeat.yml

exec "$@"
