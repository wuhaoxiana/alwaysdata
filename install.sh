#!/bin/sh
# 本机执行：把 start.sh / setup.sh 传到服务器并安装（macOS / Linux）。
#
#   ./install.sh <账号>@ssh-<账号>.alwaysdata.net
set -eu
if [ $# -ne 1 ]; then
    echo "用法: ./install.sh <账号>@ssh-<账号>.alwaysdata.net" >&2
    exit 1
fi
cd "$(dirname "$0")"

tar -cf - start.sh setup.sh | ssh "$1" \
    "tar -xf - -C ~ --exclude='._*' --warning=no-unknown-keyword && bash ~/setup.sh"
