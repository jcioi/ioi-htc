#!/bin/bash
set -x

tmp=/tmp/passwd_crypt

cat "$tmp" | while read l ; do
    username=$(echo $l | cut -d: -f1)
    getent passwd "$username" || useradd -g contestant -s /bin/bash "$username"
done

cat "$tmp" | chpasswd -e
