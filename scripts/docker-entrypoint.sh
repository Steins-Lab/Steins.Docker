#!/bin/sh
set -eu

if [ "$(id -u)" -eq 0 ]; then
    # Bind mounts hide the image's directory ownership. Repair existing state
    # too, without following symlinks or descending into other filesystems.
    find /data -xdev \( ! -uid 10001 -o ! -gid 10001 \) \
        -exec chown --no-dereference 10001:10001 {} +
    exec setpriv --reuid=10001 --regid=10001 --init-groups \
        /opt/steins/Steins-Onebot "$@"
fi

# An explicit docker --user override keeps the caller's chosen identity.
exec /opt/steins/Steins-Onebot "$@"
