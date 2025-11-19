#!/usr/bin/env bash
#
# summarize_code.sh - summarize a code file via OpenAI and emit Markdown.
#
# The script:
#   1. Sends the contents of a small code file to the OpenAI API.
#   2. Asks for a short JSON object: { "summary": "...", "usage": "..." }.
#   3. Renders that into a Markdown snippet.
#
# Usage:
#   summarize_code.sh <code-file> [markdown-output-file]
#
# If markdown-output-file is provided, a Markdown section is appended to it.
# Otherwise, the Markdown is written to stdout.
#
# Requirements:
#   - Environment variable OPENAI_API_KEY must be set.
#   - `curl` and `jq` must be installed.

set -euo pipefail

usage() {
  cat <<EOF
summarize_code.sh - summarize a code file via OpenAI and emit Markdown.

Usage:
  $(basename "$0") <code-file> [markdown-output-file]

Options:
  -h, --help      Show this help message and exit.

Behavior:
  - Sends the code file to the OpenAI API.
  - Receives JSON: { "summary": "<short paragraph>", "usage": "<one-line command>" }.
  - Renders this as Markdown:
        ### <filename>

        **Summary**
        <summary>

        **Usage**
        \`\`\`bash
        <usage>
        \`\`\`
  - If markdown-output-file is given, appends the Markdown snippet to that file.
    Otherwise, prints it to stdout.

Environment:
  OPENAI_API_KEY   Your OpenAI API key (required).

EOF
}

# --- argument parsing ---

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Error: wrong number of arguments." >&2
  usage
  exit 1
fi

CODE_FILE="$1"
OUTFILE="${2:-}"

if [[ ! -f "$CODE_FILE" ]]; then
  echo "Error: file not found: $CODE_FILE" >&2
  exit 1
fi

# --- sanity checks ---

if [[ -z "${OPENAI_API_KEY:-}" ]]; then
  echo "Error: OPENAI_API_KEY is not set in the environment." >&2
  exit 1
fi

for cmd in curl jq; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: required command not found: $cmd" >&2
    exit 1
  fi
done

# --- build request body ---

CODE_CONTENT=$(<"$CODE_FILE")

SYSTEM_PROMPT=$'You are a code assistant.\n\nYou will be given the full contents of a small code file.\n\nReturn a JSON object with exactly two keys:\n  - "summary": a single short paragraph (< 80 words) describing what the script/program does.\n  - "usage": a *single line* showing how to run it from a terminal (just one command example).\n\nConstraints:\n- Do NOT include backticks or markdown formatting.\n- Do NOT include any extra keys.\n- Do NOT explain your reasoning.'

USER_CONTENT=$'Here is the code file:\n\n'"$CODE_CONTENT"

REQUEST_BODY=$(jq -n \
  --arg system "$SYSTEM_PROMPT" \
  --arg user "$USER_CONTENT" \
  '{
     model: "gpt-5.1",
     messages: [
       { "role": "system", "content": $system },
       { "role": "user", "content": $user }
     ],
     temperature: 0.2
   }')

# --- call OpenAI API ---

RESPONSE=$(curl -sS https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer ${OPENAI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$REQUEST_BODY")

# Check for API-level error
if echo "$RESPONSE" | jq -e '.error' >/dev/null 2>&1; then
  echo "OpenAI API error:" >&2
  echo "$RESPONSE" | jq -r '.error.message' >&2
  exit 1
fi

CONTENT=$(echo "$RESPONSE" | jq -r '.choices[0].message.content')

# Ensure the content is valid JSON
if ! echo "$CONTENT" | jq -e . >/dev/null 2>&1; then
  echo "Error: model response was not valid JSON:" >&2
  echo "$CONTENT" >&2
  exit 1
fi

SUMMARY=$(echo "$CONTENT" | jq -r '.summary')
USAGE_LINE=$(echo "$CONTENT" | jq -r '.usage')

# --- render Markdown ---

BASENAME=$(basename "$CODE_FILE")

MARKDOWN_SNIPPET=$(cat <<EOF
### $BASENAME

**Summary**
$SUMMARY

**Usage**
\`\`\`bash
$USAGE_LINE
\`\`\`

EOF
)

# --- output: stdout or append to file ---

if [[ -n "$OUTFILE" ]]; then
  # add a blank line separator if file already has content
  if [[ -s "$OUTFILE" ]]; then
    printf '\n' >> "$OUTFILE"
  fi
  printf '%s\n' "$MARKDOWN_SNIPPET" >> "$OUTFILE"
  echo "Appended Markdown summary for '$CODE_FILE' to '$OUTFILE'." >&2
else
  printf '%s\n' "$MARKDOWN_SNIPPET"
fi

