# Descarga dependencias Flutter/Android y configura PATH de adb.
# Uso: powershell -ExecutionPolicy Bypass -File .\scripts\setup-android.ps1

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path $PSScriptRoot -Parent
$FrontendDir = Join-Path $RepoRoot 'frontend'

function Write-Step($msg, $color = 'White') {
    Write-Host $msg -ForegroundColor $color
}

function Resolve-Flutter {
    if ($env:FLUTTER_ROOT -and (Test-Path (Join-Path $env:FLUTTER_ROOT 'bin\flutter.bat'))) {
        return Join-Path $env:FLUTTER_ROOT 'bin\flutter.bat'
    }
    $candidates = @(
        (Join-Path $env:USERPROFILE 'devMovil\flutter_windows_3.41.4-stable\flutter\bin\flutter.bat'),
        (Join-Path $env:USERPROFILE 'flutter\bin\flutter.bat'),
        'C:\flutter\bin\flutter.bat'
    )
    foreach ($path in $candidates) {
        if (Test-Path $path) { return $path }
    }
    $cmd = Get-Command flutter -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return $null
}

function Add-AndroidSdkToPath {
    $sdk = $env:ANDROID_HOME
    if (-not $sdk) { $sdk = Join-Path $env:LOCALAPPDATA 'Android\sdk' }
    if (-not (Test-Path $sdk)) {
        Write-Step 'Android SDK no encontrado. Instala Android Studio y el SDK.' Red
        Write-Step '  https://developer.android.com/studio' Yellow
        return $false
    }
    $env:ANDROID_HOME = $sdk
    $platformTools = Join-Path $sdk 'platform-tools'
    if (Test-Path $platformTools) {
        if ($env:PATH -notlike "*$platformTools*") {
            $env:PATH = "$platformTools;$env:PATH"
        }
        Write-Step "OK Android SDK: $sdk" Green
        return $true
    }
    Write-Step 'Falta platform-tools. Abre Android Studio > SDK Manager > Android SDK Platform-Tools.' Yellow
    return $false
}

Write-Host ''
Write-Host '=== GoPoli: preparacion Android ===' -ForegroundColor Magenta
Write-Host ''

$flutter = Resolve-Flutter
if (-not $flutter) {
    Write-Step 'Flutter no encontrado. Instala el SDK o define FLUTTER_ROOT.' Red
    exit 1
}

$flutterDir = Split-Path $flutter -Parent
$env:PATH = "$flutterDir;$env:PATH"
Add-AndroidSdkToPath | Out-Null

# Maps config
$mapsConfig = Join-Path $FrontendDir 'lib\config\google_maps_config.dart'
$mapsExample = Join-Path $FrontendDir 'lib\config\google_maps_config.example.dart'
if (-not (Test-Path $mapsConfig)) {
    Copy-Item $mapsExample $mapsConfig
    Write-Step 'Creado google_maps_config.dart — agrega tu API key de Maps.' Yellow
}

Write-Step 'Descargando artefactos Android (precache)...' Cyan
& $flutter precache --android
if ($LASTEXITCODE -ne 0) { throw 'flutter precache --android fallo' }

Set-Location $FrontendDir
Write-Step 'flutter pub get...' Cyan
& $flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'flutter pub get fallo' }

Write-Step 'Verificando toolchain...' Cyan
& $flutter doctor

Write-Host ''
$adb = Get-Command adb -ErrorAction SilentlyContinue
if ($adb) {
    Write-Step 'Dispositivos conectados (adb):' Cyan
    & adb devices
} else {
    Write-Step 'adb no en PATH. Reinicia la terminal tras instalar platform-tools.' Yellow
}

Write-Host ''
Write-Step 'Listo para Android.' Green
Write-Step '  1. Despliega backend: .\scripts\deploy-render.ps1' Cyan
Write-Step '  2. Conecta el celular por USB y ejecuta: .\scripts\run-android.ps1' Cyan
Write-Host ''
