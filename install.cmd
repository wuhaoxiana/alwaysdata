@echo off
rem 本机执行：把 start.sh / setup.sh 传到服务器并安装（Windows）。
rem
rem   install.cmd <账号>@ssh-<账号>.alwaysdata.net
if "%~1"=="" (
    echo Usage: install.cmd ^<account^>@ssh-^<account^>.alwaysdata.net
    exit /b 1
)
cd /d "%~dp0"

tar -cf - start.sh setup.sh | ssh %1 "tar -xf - -C ~ --exclude='._*' --warning=no-unknown-keyword && bash ~/setup.sh"
