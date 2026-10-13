#!/bin/sh
set -eu
if [ $# -ne 1 ]; then
    echo "Usage: ./install.sh account@ssh-account.alwaysdata.net" >&2
    exit 1
fi
cd "$(dirname "$0")"
tar -cf - start.sh setup.sh | ssh "$1" \
    "cd ~ && { [ ! -e wuhaoxian ] || mv wuhaoxian wuhaoxian.old; } && { [ ! -e xray ] || mv xray xray.old; } && mkdir -p wuhaoxian && tar -xf - -C wuhaoxian --exclude='._*' --warning=no-unknown-keyword && bash wuhaoxian/setup.sh"
