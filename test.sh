#!/usr/bin/env bash
set -euo pipefail

# Source environment variables if .envrc exists
if [ -f .envrc ]; then
  # shellcheck disable=SC1090
  source <(grep -v '^use ' .envrc)
fi

run() {
  local label=$1; shift
  local output status
  output=$(curl -s -i "$@" | tr -d '\r' | tr '\n' ' ' | sed 's/  */ /g')
  status=$?
  # Use a pipe as a separator for column command
  printf "%s|%s|%s\n" "$label" "$status" "$output"
}

{
  # Use a pipe as a separator for column command
  echo "Test|Exit|Output"
  run "Invalid Content-Type" -X POST "localhost:${PORT}" -H "Content-Type: application/json" -d '{"foo":"bar"}'
  run "Valid Content-Type"   -X POST "localhost:${PORT}" -H "Content-Type: application/text" -d '{"foo":"bar"}'
  run "OPTIONS /"   /y         -X OPTIONS "localhost:${PORT}"
} | column -t -s '|'
# We use the pipe character '|' as a delimiter for the column command instead of a tab '	'.
# This is because the output from curl can contain spaces and other characters that might
# be misinterpreted by the column command when using tabs, leading to formatting issues.
# The pipe is a safer choice as it's unlikely to appear in the curl output.