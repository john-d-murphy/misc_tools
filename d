#!/usr/bin/env bash
# def - colorized dictionary lookup via dict.org WordNet
#
# Usage:
#   def <word>          - look up a word
#   def <word> thes     - thesaurus lookup (moby-thesaurus)
#   def <word> all      - search all dictionaries
#
# Requirements: dict (dictd client), or curl as fallback
#
# Installation:
#   chmod +x def
#   cp def ~/.local/bin/   # or anywhere on your $PATH
#

set -euo pipefail

readonly DICT_HOST="dict.org"

# Colors
readonly DIM='\x1b[2m'
readonly BOLD='\x1b[1m'
readonly BOLD_CYAN='\x1b[1;36m'
readonly BOLD_YELLOW='\x1b[1;33m'
readonly GREEN='\x1b[32m'
readonly ITALIC='\x1b[3m'
readonly RESET='\x1b[0m'
readonly BOLD_MAGENTA='\x1b[1;35m'

usage() {
    echo "Usage: $(basename "$0") <word> [thes|all|<database>]"
    echo ""
    echo "  def <word>          Dictionary definition (WordNet)"
    echo "  def <word> thes     Thesaurus lookup (Moby)"
    echo "  def <word> all      Search all dictionaries"
    echo "  def <word> gcide    Use a specific database"
    echo ""
    echo "  def --dbs           List available databases"
    exit 1
}

colorize() {
    sed -E \
        -e "s/^(From .*)$/${DIM}\1${RESET}/" \
	-e "s/^  ([a-z][-a-z_]*)$/${BOLD_MAGENTA}\U\1\E${RESET}\n${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n/" \
        -e "s/^( *)(n|v|adj|adv)( )([0-9]+)/${BOLD_CYAN}\2\n${RESET}${BOLD_YELLOW}\4${RESET}/" \
        -e "s/^( *)([0-9]+):/${BOLD_YELLOW}\2:${RESET}/" \
        -e "s/\{([^}]+)\}/${GREEN}\1${RESET}/g" \
        -e "s/\"([^\"]+)\"/${ITALIC}\"\1\"${RESET}/g" \
        -e "s/\[syn: /[${DIM}syn: /g" \
        -e "s/\[ant: /[${DIM}ant: /g" \
        -e "s/^(  [a-z]+$)/${BOLD_CYAN}\1${RESET}/"
}

lookup() {
    local word="$1"
    local db="${2:-wn}"

    if command -v dict &>/dev/null; then
        dict -h "$DICT_HOST" -d "$db" "$word" 2>/dev/null
    else
        # curl fallback
        curl -s "dict://${DICT_HOST}/d:${word}:${db}" |
            sed '/^[0-9]\{3\} /d; s/^\.\r*$//'
    fi
}

list_dbs() {
    if command -v dict &>/dev/null; then
        dict -h "$DICT_HOST" -D 2>/dev/null
    else
        curl -s "dict://${DICT_HOST}/show:db" |
            sed '/^[0-9]\{3\} /d; s/^\.\r*$//'
    fi
}

# --- Main ---

[[ $# -lt 1 ]] && usage

case "$1" in
    -h|--help) usage ;;
    --dbs)     list_dbs; exit 0 ;;
esac

if [[ "$1" == "--dbs" ]]; then
    list_dbs
    exit 0
fi

word="$1"
db="${2:-wn}"

# Friendly aliases
case "$db" in
    thes|thesaurus) db="moby-thesaurus" ;;
    webster|web)    db="gcide" ;;
esac

result=$(lookup "$word" "$db" || true)

if [[ -z "$result" ]]; then
    echo -e "${BOLD_YELLOW}No definition found for '${word}'${RESET}" >&2
    echo -e "Try: $(basename "$0") ${word} all" >&2
    exit 1
fi

echo "$result" | colorize
