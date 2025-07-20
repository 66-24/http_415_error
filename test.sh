#!/usr/bin/env bash
set -euo pipefail

# Source environment variables if .envrc exists
if [ -f .envrc ]; then
  # shellcheck disable=SC1090
  source <(grep -v '^use ' .envrc)
fi

# --- Main Logic ---

# Default formatter is the classic column view
formatter="column"
# Check for flags
if [[ "${1:-}" == "--raw" ]]; then
  formatter="raw"
elif [[ "${1:-}" == "--json" ]]; then
  formatter="json"
fi


run() {
  local label=$1; shift
  local output status
  output=$(curl -s -i "$@" | tr -d '\r' | tr '\n' ' ' | sed 's/  */ /g')
  status=$?

  if [[ "$formatter" == "json" ]]; then
    # jq is required for json output
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is not installed. Please install it to use --json output." >&2
        exit 1
    fi
    jq -n \
      --arg label "$label" \
      --arg status "$status" \
      --arg output "$output" \
      '{Test: $label, Exit: $status, Output: $output}'
  else
    # Pipe is the separator for raw and column format
    printf "%s|%s|%s\n" "$label" "$status" "$output"
  fi
}

# Run tests and collect output into an array
mapfile -t results < <(
  run "Invalid Content-Type" -X POST "localhost:${PORT}" -H "Content-Type: application/json" -d '{"foo":"bar"}'
  run "Valid Content-Type"   -X POST "localhost:${PORT}" -H "Content-Type: application/text" -d '{"foo":"bar"}'
  run "OPTIONS /"            -X OPTIONS "localhost:${PORT}"
)

# Format and print the output
if [[ "$formatter" == "json" ]]; then
  printf '%s\n' "${results[@]}" | jq -s '.' # Wrap individual JSON objects into a single array
elif [[ "$formatter" == "raw" ]]; then
  echo "Test|Exit|Output"
  printf '%s\n' "${results[@]}"
else # "column"
  {
    echo "Test|Exit|Output"
    printf '%s\n' "${results[@]}"
  } | column -t -s '|'
  # Add comment about the delimiter choice
  echo
  echo "# We use '|' as a delimiter because curl output can contain spaces"
  echo "# that confuse column formatters using tabs or spaces."
fi