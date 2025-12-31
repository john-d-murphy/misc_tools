#!/usr/bin/env bash
set -euo pipefail

next_run_epoch() {
    local now next_hour
    now=$(date +%s)

    # Next top-of-hour (e.g., if it's 10:23, schedule 11:00:00; if 10:00:01, still 11:00:00)
    next_hour=$(date -d "next hour" +%Y-%m-%d\ %H:00:00)
    date -d "$next_hour" +%s
}

run_cal() {
    clear
    gcalcli calw
}

run_cal

while true; do
    now=$(date +%s)
    target=$(next_run_epoch)
    sleep_secs=$(( target - now ))

    if (( sleep_secs > 0 )); then
        sleep "$sleep_secs"
    fi

    # Don't let a failed run kill the script under `set -e`
    if ! run_cal; then
        :
    fi
done

