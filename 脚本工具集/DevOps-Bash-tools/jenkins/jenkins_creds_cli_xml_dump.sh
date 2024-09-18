#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2022-06-28 19:27:21 +0100 (Tue, 28 Jun 2022)
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

# shellcheck disable=SC2034,SC2154
usage_description="
Dumps the XML configs of all credentials in the global system store using jenkins_cli.sh

Tested on Jenkins 2.319 with Credentials plugin 2.5

Uses adjacent jenkins_cli.sh - see there for more details on required connection settings / environment variables
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

help_usage "$@"

#min_args 1 "$@"

store="${1:-system::system::jenkins}"

# -webSocket is needed if Jenkins is behind a reverse proxy such as Kubernetes Ingress, otherwise Jenkins CLI hangs
#"$srcdir/jenkins_cli.sh" -webSocket list-credentials-as-xml system::system::jenkins
"$srcdir/jenkins_cli.sh" list-credentials-as-xml "$store"
