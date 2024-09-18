#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2024-08-12 14:41:48 +0200 (Mon, 12 Aug 2024)
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
Lists the pods of a deployment by querying the deployment's spec.selector.matchLabels
and then querying pods with matching selectors

Requires kubectl to be installed and configured, as well as jq installed
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<deployment_name> [-n <namespace>]"

help_usage "$@"

min_args 1 "$@"

deployment="$1"
shift || :

read -r -a label_args < <(
    kubectl get deployment "$deployment" "$@" -o jsonpath='{.spec.selector.matchLabels}' |
    jq -r 'to_entries[] | "-l \(.key)=\(.value)"'
)

kubectl get pods "${label_args[@]}" "$@" -o name
