#!/usr/bin/env bash
set -euo pipefail

# Times of day to run (24h format, local time)
RUN_TIMES=("06:00" "09:00" "12:00" "15:00" "18:00")

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

run_weather() {
    local attempt max_attempts=3
    local sleep_between=90
    local output

    for (( attempt=1; attempt<=max_attempts; attempt++ )); do
        # -f: fail on HTTP errors, -sS: quiet but show errors
        if output=$(curl -fsS "wttr.in?nq2"); then
            clear
            printf '%s\n' "$output"
            return 0
        fi

        if (( attempt < max_attempts )); then
            # Wait 90s before trying again, but keep current screen content
            sleep "$sleep_between"
        fi
    done

    # All attempts failed: keep whatever is currently on screen
    printf '(%s) wttr.in unreachable after %d attempts; keeping previous display.\n' \
        "$(date)" "$max_attempts" >&2
    return 1
}

run_weather

while true; do
    now=$(date +%s)
    target=$(next_run_epoch)
    sleep_secs=$(( target - now ))

    if (( sleep_secs > 0 )); then
        sleep "$sleep_secs"
    fi

    # Don't let a failed run kill the script under `set -e`
    if ! run_weather; then
        :
    fi
done
