#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#  args: yaml git
#
#  Author: Hari Sekhon
#  Date: 2019-02-19 01:55:24 +0000 (Tue, 19 Feb 2019)
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
Translates Python import statement module names to pip module names

Used by python_pip_install_for_script.sh to parse import statements to pip modules to check they're installed


Reads from standard input if no args are given
"

# shellcheck disable=SC2034
usage_args="[<module1> <module2> ...]"

help_usage "$@"


mappings="$srcdir/../resources/pipreqs_mapping.txt"

if ! [ -f "$mappings" ]; then
    wget -O "$mappings" https://raw.githubusercontent.com/bndr/pipreqs/master/pipreqs/mapping
fi

sed_script="$(
    tr ':' ' ' < "$mappings" |
    while read -r import_name module_name rest; do
        if ! [[ "$import_name" =~ ^[A-Za-z0-9/_.-]+$ ]]; then
            echo "import name '$import_name' did not match expected alphanumeric regex!" >&2
            continue
        fi
        if ! [[ "$module_name" =~ ^[A-Za-z0-9_.-]+$ ]]; then
            echo "import module name '$module_name' did not match expected alphanumeric regex!" >&2
            continue
        fi
        echo "s|^$import_name$|$module_name|;"
    done
)"

if [ $# -gt 0 ]; then
    for x in "$@"; do
        if [ -f "$x" ]; then
            cat "$x"
        else
            echo "$x"
        fi
    done
else
    cat
fi |
sed "$sed_script" |
    # - import names replace dashes with underscores
sed '
    s/_/-/g;
'
