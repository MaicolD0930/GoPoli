# Ejecuta GoPoli en Android apuntando al backend en Render.
# Uso:
#   .\scripts\run-android.ps1
#   .\scripts\run-android.ps1 -ApiUrl https://gopoli-backend.onrender.com
#   .\scripts\run-android.ps1 -BuildApk

param(
    [string]$ApiUrl,
    [switch]$BuildApk
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path $PSScriptRoot -Parent
$FrontendDir = Join-Path $RepoRoot 'frontend'
$RenderUrlFile = Join-Path $RepoRoot 'render.url'

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

function Get-RenderApiUrl {
    param([string]$Override)

    if ($Override) {
        return $Override.Trim().TrimEnd('/')
    }
    if (Test-Path $RenderUrlFile) {
        $fromFile = (Get-Content $RenderUrlFile -Raw).Trim().TrimEnd('/')
        if ($fromFile -match '^https://') {
            return $fromFile
        }
    }
    return $null
}

function Test-BackendUrl {
    param([string]$Url)
    try {
        $null = Invoke-WebRequest -Uri "$Url/ubicaciones" -UseBasicParsing -TimeoutSec 45
        return $true
    } catch {
        return $false
    }
}

function Pick-AndroidDevice {
    param([string]$FlutterExe)

    $out = & $FlutterExe devices 2>&1 | Out-String
    if ($out -match '(?<id>[0-9A-Za-z._-]+)\s+•\s+.*\s+•\s+android') {
        return $Matches['id']
    }
    return $null
}

Write-Host ''
Write-Host '=== GoPoli Android (Render) ===' -ForegroundColor Magenta
Write-Host ''

$api = Get-RenderApiUrl -Override $ApiUrl
if (-not $api) {
    Write-Step 'No hay URL de Render. Ejecuta primero deploy-render.ps1 o crea render.url' Red
    Write-Step '  copy render.url.example render.url' Yellow
    exit 1
}

Write-Step "API: $api" Cyan
Write-Step 'Comprobando backend (puede tardar si Render estaba dormido)...' Cyan
if (-not (Test-BackendUrl -Url $api)) {
    Write-Step "El backend no respondio en $api/ubicaciones" Red
    Write-Step 'Revisa el deploy en Render o espera unos segundos y reintenta.' Yellow
    exit 1
}
Write-Step 'Backend OK' Green

$flutter = Resolve-Flutter
if (-not $flutter) {
    Write-Step 'Flutter no encontrado.' Red
    exit 1
}

$flutterDir = Split-Path $flutter -Parent
$env:PATH = "$flutterDir;$env:PATH"

$sdk = $env:ANDROID_HOME
if (-not $sdk) { $sdk = Join-Path $env:LOCALAPPDATA 'Android\sdk' }
$pt = Join-Path $sdk 'platform-tools'
if (Test-Path $pt) { $env:PATH = "$pt;$env:PATH" }

Set-Location $FrontendDir

$defineArgs = @('--dart-define=API_URL=' + $api)

if ($BuildApk) {
    Write-Step 'Generando APK release...' Cyan
    & $flutter build apk --release @defineArgs
    if ($LASTEXITCODE -ne 0) { throw 'flutter build apk fallo' }
    $apk = Join-Path $FrontendDir 'build\app\outputs\flutter-apk\app-release.apk'
    Write-Step "APK listo: $apk" Green
    Write-Step 'Copialo al celular e instalalo, o usa: adb install -r app-release.apk' Cyan
    exit 0
}

$deviceId = Pick-AndroidDevice -FlutterExe $flutter
if (-not $deviceId) {
    Write-Step 'No hay dispositivo Android conectado.' Red
    Write-Step 'Conecta el celular por USB (depuracion USB) o abre un emulador.' Yellow
    Write-Step 'Alternativa: .\scripts\run-android.ps1 -BuildApk' Yellow
    & $flutter devices
    exit 1
}

Write-Step "Dispositivo: $deviceId" Green
Write-Step 'Iniciando app...' Cyan
& $flutter run -d $deviceId @defineArgs
