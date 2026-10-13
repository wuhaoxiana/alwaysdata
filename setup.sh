#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
umask 077
_d() { printf %s "$1" | base64 -d; }
_u=$(_d aHR0cHM6Ly9naXRodWIuY29tL1hUTFMvWHJheS1jb3Jl)
_p=$(_d dmxlc3M=)
_n=$(_d eGh0dHA=)
_z=$(_d WHJheS1saW51eC02NC56aXA=)
_m=packet-up
_a=$(id -un)
_s=$_a.alwaysdata.net

[ ! -f xray ] || { [ -f wuhaoxian ] || mv xray wuhaoxian; }
[[ $(curl -fsSL "$_u/releases.atom") =~ releases/tag/(v[0-9.]+) ]] || exit 1
_v=${BASH_REMATCH[1]}
if [[ $(./wuhaoxian version 2>/dev/null) != *" ${_v#v} "* ]]; then
    curl -fsSLO "$_u/releases/download/$_v/$_z{,.dgst}"
    echo "$(sed -n 's/^SHA2-256= //p' $_z.dgst)  $_z" | sha256sum -c --quiet
    unzip -oq $_z xray
    mv xray wuhaoxian
    rm $_z $_z.dgst
fi

m=
for d in ../wuhaoxian.old ../xray.old; do
    if [ -f "$d/secrets.env" ]; then
        if [ ! -f secrets.env ]; then mv "$d/secrets.env" . 2>/dev/null || true; fi
        m=1
    fi
done
if [ -f ../secrets.env ]; then
    if [ ! -f secrets.env ]; then mv ../secrets.env . 2>/dev/null || true; fi
    m=1
fi
if [ -n "$m" ]; then
    rm -rf ../xray.old ../wuhaoxian.old ../start.sh ../setup.sh ../config.json ../secrets.env ../link.txt ../cache.txt
fi

if [ ! -f secrets.env ]; then
    printf 'UUID=%s\nXHTTP_PATH=/%s\n' "$(./wuhaoxian uuid)" "$(./wuhaoxian uuid | tr -d -)" > secrets.env
fi
. ./secrets.env

chmod 700 start.sh
./start.sh --check | tail -1
echo "Site: User program, command $PWD/start.sh, working directory $PWD (restart the site after updates)"
if [ -n "$m" ]; then
    echo "Moved: update the site's command and working directory to the above now"
fi
printf '%s://%s@%s:443?encryption=none&security=tls&sni=%s&type=%s&host=%s&path=%s&mode=%s#%s' \
    "$_p" "$UUID" "$_s" "$_s" "$_n" "$_s" "${XHTTP_PATH//\//%2F}" "$_m" "$_a" |
    base64 | tr -d '\n' | tee cache.txt
echo
