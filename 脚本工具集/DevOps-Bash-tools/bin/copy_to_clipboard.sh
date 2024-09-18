#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2024-02-24 01:51:08 +0000 (Sat, 24 Feb 2024)
#
#  https///github.com/HariSekhon/DevOps-Bash-tools
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
. "$srcdir/lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Copies the first argument string or standard input to the system clipboard on Linux or Mac
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="[<string>]"

help_usage "$@"

max_args 1 "$@"

if [ $# -gt 0 ]; then
    cat <<< "$1"
else
    # pass through stdin
    cat
fi |
if is_mac; then
    pbcopy
elif is_linux; then
    xclip
else
    echo "ERROR: OS is not Darwin/Linux"
    return 1
fi
