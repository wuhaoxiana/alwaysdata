#!/bin/sh
set -eu
cd "$(dirname "$0")"
[ "${1:-}" = --check ] && IP=:: PORT=1
. ./secrets.env
: "${UUID:?}"
: "${XHTTP_PATH:?}"
: "${IP:?}"
: "${PORT:?}"
_d() { printf %s "$1" | base64 -d; }
_p=$(_d dmxlc3M=)
_n=$(_d eGh0dHA=)
_c() {
    cat <<EOF
{
  "log": { "loglevel": "warning", "access": "none" },
  "inbounds": [{
    "listen": "$IP",
    "port": $PORT,
    "protocol": "$_p",
    "settings": { "users": [{ "id": "$UUID" }], "decryption": "none" },
    "streamSettings": {
      "network": "$_n",
      "xhttpSettings": { "path": "$XHTTP_PATH", "mode": "auto" },
      "sockopt": { "trustedXForwardedFor": ["X-Forwarded-For"] }
    }
  }],
  "outbounds": [{ "protocol": "freedom" }]
}
EOF
}
if [ "${1:-}" = --check ]; then
    _c | ./wuhaoxian run -test -c stdin:
else
    umask 077
    _c > config.json
    exec ./wuhaoxian run -c config.json
fi
