#!/usr/bin/env bash
# 服务器端安装脚本（由 install.sh 上传后执行）：安装/更新运行时、生成密钥、输出订阅内容。
# 用法：bash setup.sh [--plain]   --plain 只打印明文链接
set -euo pipefail
cd "$(dirname "$0")"
umask 077

if [ "${1:-}" = --plain ]; then
    [ -f link.txt ] && { base64 -d link.txt; echo; }
    exit 0
fi

M=packet-up          # 平台的转发不支持 stream-up / stream-one
N=$(id -un)
H=$N.alwaysdata.net

d() { printf '%s' "$1" | base64 -d; }

# 最新版本（含预发布）
A=$(d 'aHR0cHM6Ly9naXRodWIuY29tL1hUTFMvWHJheS1jb3JlL3JlbGVhc2VzLmF0b20=')
[[ $(curl -fsSL "$A") =~ releases/tag/(v[0-9.]+) ]] ||
    { echo "无法确定最新版本" >&2; exit 1; }
V=${BASH_REMATCH[1]}

if [[ $(./wuhaoxian version 2>/dev/null) != *" ${V#v} "* ]]; then
    Z=$(d 'WHJheS1saW51eC02NC56aXA=')
    F=$(d 'eHJheQ==')
    U=$(d 'aHR0cHM6Ly9naXRodWIuY29tL1hUTFMvWHJheS1jb3JlL3JlbGVhc2VzL2Rvd25sb2FkL0BWQC8=')
    U=${U//@V@/$V}
    curl -fsSL -o "$Z" "$U$Z"
    curl -fsSL -o "$Z.dgst" "$U$Z.dgst"
    echo "$(sed -n 's/^SHA2-256= //p' "$Z.dgst")  $Z" | sha256sum -c --quiet
    unzip -oq "$Z" "$F"
    mv -f "$F" wuhaoxian
    chmod 700 wuhaoxian
    rm -f "$Z" "$Z.dgst"
fi

[ -f secrets.env ] || printf 'UUID=%s\nXHTTP_PATH=/%s\n' "$(./wuhaoxian uuid)" "$(./wuhaoxian uuid | tr -d -)" > secrets.env
grep -q '^QUIET=' secrets.env || printf 'QUIET=1\n' >> secrets.env
. ./secrets.env

chmod 700 start.sh
./start.sh --check | tail -1
echo "Site: User program, command $PWD/start.sh (restart the site after updates)"

L=$(d 'dmxlc3M6Ly8lVSVAJUglOjQ0Mz9lbmNyeXB0aW9uPW5vbmUmc2VjdXJpdHk9dGxzJnNuaT0lSCUmdHlwZT14aHR0cCZob3N0PSVIJSZwYXRoPSVSJSZtb2RlPSVNJSMlTiU=')
L=${L//%U%/$UUID}
L=${L//%H%/$H}
L=${L//%R%/${XHTTP_PATH//\//%2F}}
L=${L//%M%/$M}
L=${L//%N%/$N}
printf '%s' "$L" | base64 | tr -d '\n' > link.txt
echo "订阅内容（base64，已存 link.txt）："
cat link.txt; echo
echo "明文链接：bash setup.sh --plain"
