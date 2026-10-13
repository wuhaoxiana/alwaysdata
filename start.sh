#!/usr/bin/env bash
# 站点入口脚本，由平台的 User program 调用（IP / PORT 由平台注入）。
# 用法：./start.sh [--check]     --check 只校验配置，不启动
set -eu
cd "$(dirname "$0")"

[ "${1:-}" = --check ] && IP=:: PORT=1 # 占位值，校验时不会真的监听

. ./secrets.env
: "${UUID:?secrets.env 里缺少 UUID}"
: "${XHTTP_PATH:?secrets.env 里缺少 XHTTP_PATH}"
: "${IP:?未设置 IP：本脚本由平台调用}"
: "${PORT:?未设置 PORT：本脚本由平台调用}"

# 站点进程的 PATH 可能很窄，base64 优先用绝对路径
B=/usr/bin/base64
[ -x "$B" ] || B=base64

# 运行时配置模板（base64，占位符 @I@ @P@ @U@ @R@ 在运行时替换）
T='ewogICJsb2ciOiB7ICJsb2dsZXZlbCI6ICJ3YXJuaW5nIiwgImFjY2VzcyI6ICJub25lIiB9LAogICJpbmJvdW5kcyI6IFt7CiAgICAibGlzdGVuIjogIkBJQCIsCiAgICAicG9ydCI6IEBQQCwKICAgICJwcm90b2NvbCI6ICJ2bGVzcyIsCiAgICAic2V0dGluZ3MiOiB7ICJ1c2VycyI6IFt7ICJpZCI6ICJAVUAiIH1dLCAiZGVjcnlwdGlvbiI6ICJub25lIiB9LAogICAgInN0cmVhbVNldHRpbmdzIjogewogICAgICAibmV0d29yayI6ICJ4aHR0cCIsCiAgICAgICJ4aHR0cFNldHRpbmdzIjogeyAicGF0aCI6ICJAUkAiLCAibW9kZSI6ICJhdXRvIiB9LAogICAgICAic29ja29wdCI6IHsgInRydXN0ZWRYRm9yd2FyZGVkRm9yIjogWyJYLUZvcndhcmRlZC1Gb3IiXSB9CiAgICB9CiAgfV0sCiAgIm91dGJvdW5kcyI6IFt7ICJwcm90b2NvbCI6ICJmcmVlZG9tIiB9XQp9'

gen() {
    local t
    t=$(printf '%s' "$T" | "$B" -d)
    t=${t//@I@/$IP}
    t=${t//@P@/$PORT}
    t=${t//@U@/$UUID}
    t=${t//@R@/$XHTTP_PATH}
    printf '%s\n' "$t"
}

if [ "${1:-}" = --check ]; then
    gen | ./wuhaoxian run -test -c stdin:
else
    umask 077
    # 配置走 here-string 从 stdin 喂进去，不落盘；QUIET=1（默认）丢弃运行日志，
    # 想排查问题就把 secrets.env 里的 QUIET 改成 0，重启站点后在面板日志里看。
    if [ "${QUIET:-1}" = 1 ]; then
        exec -a wuhaoxian ./wuhaoxian run -c stdin: >/dev/null <<<"$(gen)"
    else
        exec -a wuhaoxian ./wuhaoxian run -c stdin: <<<"$(gen)"
    fi
fi
