#!/usr/bin/env bash
set -euo pipefail

# Times of day to run (24h format, local time)
RUN_TIMES=("06:00" "09:00" "12:00" "15:00" "18:00")
COMMAND="curl wttr.in?nq2"

next_run_epoch() {
    local now ts
    now=$(date +%s)

    # Try each time *today* in order
    for t in "${RUN_TIMES[@]}"; do
        ts=$(date -d "today $t" +%s)
        if (( ts > now )); then
            echo "$ts"
            return
        fi
    done

    # If all have passed, use the first one *tomorrow*
    date -d "tomorrow ${RUN_TIMES[0]}" +%s
}

clear
$COMMAND

while true; do
    now=$(date +%s)
    target=$(next_run_epoch)
    sleep_secs=$(( target - now ))

    # Just in case clock skew makes this negative
    if (( sleep_secs > 0 )); then
        sleep "$sleep_secs"
    fi

    clear         # or: printf '\033c'
    $COMMAND
done
