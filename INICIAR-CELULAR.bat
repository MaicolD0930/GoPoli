@echo off
title GoPoli (vista celular)
cd /d "%~dp0"
echo Preparando dependencias...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\setup-local.ps1"
if errorlevel 1 (
    echo.
    echo La preparacion fallo. Revisa los mensajes arriba.
    pause
    exit /b 1
)
echo.
echo Iniciando GoPoli en ventana tipo telefono...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\run-celular.ps1" %*
if errorlevel 1 pause
