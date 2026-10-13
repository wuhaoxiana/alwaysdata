@echo off
if "%~1"=="" (
    echo Usage: install.cmd account@ssh-account.alwaysdata.net
    exit /b 1
)
cd /d "%~dp0"

tar -cf - start.sh setup.sh | ssh %1 "cd ~ && { [ ! -e wuhaoxian ] || mv wuhaoxian wuhaoxian.old; } && { [ ! -e xray ] || mv xray xray.old; } && mkdir -p wuhaoxian && tar -xf - -C wuhaoxian --exclude='._*' --warning=no-unknown-keyword && bash wuhaoxian/setup.sh"
