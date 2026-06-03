@echo off
title GoPoli
cd /d "%~dp0"
echo Iniciando GoPoli...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-gopoli.ps1" %*
if errorlevel 1 pause
