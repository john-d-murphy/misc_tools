#!/usr/bin/env bash
# Tool that lets you pick a license for your repo if you forgot to do it
# during repo creation. I always do this, so I needed the script.

#!/usr/bin/env bash
set -euo pipefail

OUTFILE="LICENSE"

echo "Fetching license list from GitHub..."
mapfile -t LICENSES < <(
  gh api /licenses -q '.[] | "\(.key)::\(.name)"'
)

if [[ ${#LICENSES[@]} -eq 0 ]]; then
  echo "No licenses returned from GitHub API."
  exit 1
fi

echo
echo "Choose a license:"
select choice in "${LICENSES[@]}"; do
  if [[ -n "${choice:-}" ]]; then
    license_key="${choice%%::*}"
    license_name="${choice#*::}"
    break
  else
    echo "Invalid choice, try again."
  fi
done

echo
echo "Fetching license body for: $license_name ($license_key)..."
template=$(gh api "/licenses/$license_key" -q .body)

# ----- Fill in [year] and [fullname] -----
current_year=$(date +%Y)
printf "Copyright year [%s]: " "$current_year"
read -r year
year=${year:-$current_year}

default_name="$(git config user.name 2>/dev/null || true)"
if [[ -n "$default_name" ]]; then
  printf "Copyright holder name [%s]: " "$default_name"
else
  printf "Copyright holder name: "
fi
read -r name
if [[ -z "$name" && -n "$default_name" ]]; then
  name="$default_name"
fi

# Replace placeholders used by GitHub templates, e.g. MIT uses [year] and [fullname]
license_text="${template//\[year\]/$year}"
license_text="${license_text//\[fullname\]/$name}"

printf '%s\n' "$license_text" > "$OUTFILE"

echo
echo "Wrote $license_name license to: $OUTFILE"

