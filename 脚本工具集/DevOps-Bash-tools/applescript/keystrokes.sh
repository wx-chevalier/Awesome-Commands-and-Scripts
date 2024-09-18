#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-06-14 17:16:31 +0100 (Sun, 14 Jun 2020)
#
#  https://github.com/HariSekhon/DevOps-Bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/HariSekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090,SC1091
. "$srcdir/../lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Automates Keyboard strokes to automate tedious UI actions

Performs N keyboard key code presses

    https://eastmanreference.com/complete-list-of-applescript-key-codes

Sleeps for \$SLEEP_SECS (default: 1) between clicks to allow UIs to update and perform the next keystroke

Starts each keystroke after \$START_DELAYS seconds (default: 5) to give time to alt-tab back to your UI application and position the cursor

If given num is negative, will run indefinitely until Control-C'd
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<num> [<keycode> <keycode> <keycode> ...]"

help_usage "$@"

min_args 1 "$@"

num="$1"
start_delay="${START_DELAY:-5}"
sleep_secs="${SLEEP_SECS:-1}"

if ! [[ "$num" =~ ^-?[[:digit:]]+$ ]]; then
    usage "invalid non-integer '$num' given for first argument"
fi

if ! is_float "$start_delay"; then
    usage "invalid non-float '$START_DELAY' found in environment for \$START_DELAY"
fi

if ! is_float "$sleep_secs"; then
    usage "invalid non-float '$SLEEP_SECS' found in environment for \$SLEEP_SECS"
fi

shift || :

read -r -a keys <<< "$@"

timestamp "waiting for $start_delay secs before starting"
sleep "$start_delay"
timestamp "starting $num keystrokes"
echo

for ((i=1; ; i++)); do
    # if given num is negative, will run for infinity until Control-C'd
    if [ "$num" -ge 0 ] &&
       [ "$i" -gt "$num" ]; then
        break
    fi
    for key in "${keys[@]}"; do
        if [[ "$key" =~ ^[[:digit:]][[:digit:]]+$ ]]; then
            timestamp "keystroke $i/$num keycode $key"
            osascript -e "tell application \"System Events\" to key code $key" || :
        else
            timestamp "keystroke $i/$num key $key"
            osascript -e "tell application \"System Events\" to keystroke \"$key\""
        fi
        sleep "$sleep_secs.$RANDOM"  # add $RANDOM up to 1 second jitter to make it harder to spot that this is perfectly automated clicking
    done
done
