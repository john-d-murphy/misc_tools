#!/bin/bash

usage() {
    cat <<EOF
Usage: c <language> <query...>

Query cheat.sh from the command line.

Examples:
    c bash "add two numbers"
    c python reverse a list
    c cpp read file line by line
    c go sort a slice

With no arguments, opens the cheat.sh main page.
EOF
    exit 0
}

[[ "$1" == "-h" || "$1" == "--help" ]] && usage

if [[ $# -eq 0 ]]; then
    curl -s cheat.sh
    exit
fi

lang="$1"
shift
query=$(IFS=+; echo "$*")
curl -s "cheat.sh/${lang}/${query}"
