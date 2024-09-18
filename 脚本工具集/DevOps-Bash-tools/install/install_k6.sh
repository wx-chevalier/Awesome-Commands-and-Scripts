#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2022-07-08 15:17:15 +0100 (Fri, 08 Jul 2022)
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
Installs the K6 load testing CLI by Grafana Labs
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="[<version>]"

export PATH="$PATH:$HOME/bin"

help_usage "$@"

#version="${1:-0.39.0}"
version="${1:-latest}"

# Mac packages has both macos instead of darwin, and zip instead of tarball
export OS_DARWIN=macos
ext="tar.gz"

if is_mac; then
    ext="zip"
fi

package="k6-v{version}-{os}-{arch}.$ext"

export RUN_VERSION_ARG=1

"$srcdir/../github/github_install_binary.sh" grafana/k6 "$package" "$version" "k6-v{version}-{os}-{arch}/k6" k6
