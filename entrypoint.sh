#!/bin/ash
set -e

# If thrown flags immediately,
# assume they want to run the electrs daemon
if [ "${1:0:1}" = '-' ]; then
	set -- electrs "$@"
fi

# If they are running the electrs daemon,
# make efficient use of memory
if [ "$1" = 'electrs' ]; then
	numa='numactl --interleave=all'
	if $numa true &> /dev/null; then
		set -- $numa "$@"
	fi
fi

# Let's go already!
exec "$@"
