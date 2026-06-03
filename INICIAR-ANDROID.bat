@echo off
title GoPoli Android
cd /d "%~dp0"
echo Preparando Android...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\setup-android.ps1"
if errorlevel 1 (
    echo.
    echo La preparacion fallo.
    pause
    exit /b 1
)
echo.
echo Desplegando backend en Render (si hace falta)...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\deploy-render.ps1"
if errorlevel 1 (
    echo.
    echo Revisa el deploy en Render y vuelve a ejecutar run-android.
    pause
    exit /b 1
)
echo.
echo Iniciando app en el celular...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\run-android.ps1"
if errorlevel 1 pause
