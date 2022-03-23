#!/bin/bash
#
# auto sudo, based on wg-quick implementation
#

SELF="$(readlink -f "${BASH_SOURCE[0]}")"
export PATH="${SELF%/*}:$PATH"
ARGS=( "$@" )

[[ $UID == 0 ]] || exec sudo -p "Script must be run as root. \
Please enter the password for %u to continue: " -- "$BASH" -- \
"$SELF" "${ARGS[@]}"

ORIG_USER=$(logname)

echo "Hello, $ORIG_USER, from $USER"
