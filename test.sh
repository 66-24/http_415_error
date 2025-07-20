#!/usr/bin/env bash
set -euo pipefail

run() {
  local label=$1; shift
  local output status
  output=$(curl -s -i "$@" | tr '\r\n' ' ' | sed 's/  */ /g')
  status=$?
  printf "%s\t%s\t%s\n" "$label" "$status" "$output"
}

{
  echo -e "Test\tExit\tOutput"
  run "Invalid Content-Type" -X POST localhost:8888 -H "Content-Type: application/json" -d '{"foo":"bar"}'
  run "Valid Content-Type"   -X POST localhost:8888 -H "Content-Type: application/text" -d '{"foo":"bar"}'
  run "OPTIONS /"            -X OPTIONS localhost:8888
} | column -t -s $'\t'
