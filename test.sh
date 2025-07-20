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
  run "Invalid Content-Type" -X POST "localhost:$PORT" -H "Content-Type: application/json" -d '{"foo":"bar"}'
  run "Valid Content-Type"   -X POST "localhost:$PORT" -H "Content-Type: application/text" -d '{"foo":"bar"}'
  run "OPTIONS /"            -X OPTIONS "localhost:$PORT"
} | column -t -s 
\t'
