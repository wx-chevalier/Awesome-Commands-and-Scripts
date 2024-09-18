#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-03-24 15:36:53 +0000 (Tue, 24 Mar 2020)
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
. "$srcdir/lib/utils.sh"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_description="Returns recent Shippable build results

Caveat: this API endpoint only works for paid accounts :-(

https://github.com/Shippable/support/issues/5068
"

if [ -z "${SHIPPABLE_ACCOUNT_ID:-}" ]; then
    usage "SHIPPABLE_ACCOUNT_ID environment variable is not set

Get this value from your Web UI Dashboard - it's in your dashboard url:

https://app.shippable.com/accounts/<THIS_BIT_IS_YOUR_ACCOUNT_ID>/dashboard
"
fi

help_usage "$@"

"$srcdir/shippable_api.sh" "/accounts/$SHIPPABLE_ACCOUNT_ID/runStatus" "$@"
#jq -r "$jq_query"
