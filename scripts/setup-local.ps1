# Descarga dependencias y prepara el entorno local de GoPoli.
# Uso: powershell -ExecutionPolicy Bypass -File .\scripts\setup-local.ps1

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path $PSScriptRoot -Parent
$BackendDir = Join-Path $RepoRoot 'backend'
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
        'C:\flutter\bin\flutter.bat',
        'C:\src\flutter\bin\flutter.bat'
    )
    foreach ($path in $candidates) {
        if (Test-Path $path) { return $path }
    }
    $cmd = Get-Command flutter -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return $null
}

Write-Host ''
Write-Host '=== GoPoli: preparacion local ===' -ForegroundColor Magenta
Write-Host ''

# Java
$javaCmd = Get-Command java -ErrorAction SilentlyContinue
if (-not $javaCmd) {
    Write-Step 'FALTA Java 21 (JDK). Instala desde https://adoptium.net/' Red
    exit 1
}
$javaVer = (cmd /c "java -version 2>&1") | Select-Object -First 1
Write-Step "OK Java: $javaVer" Green

# Docker (opcional pero recomendado para BD local)
$docker = Get-Command docker -ErrorAction SilentlyContinue
if ($docker) {
    try {
        docker info 2>&1 | Out-Null
        Write-Step 'OK Docker en ejecucion' Green
    } catch {
        Write-Step 'Docker instalado pero no esta corriendo. Abre Docker Desktop y vuelve a ejecutar.' Yellow
    }
} else {
    Write-Step 'Docker no encontrado. Usa Neon (backend/.env) o instala Docker Desktop.' Yellow
}

# Google Maps config local
$mapsConfig = Join-Path $FrontendDir 'lib\config\google_maps_config.dart'
$mapsExample = Join-Path $FrontendDir 'lib\config\google_maps_config.example.dart'
if (-not (Test-Path $mapsConfig)) {
    Copy-Item $mapsExample $mapsConfig
    Write-Step 'Creado google_maps_config.dart (pon tu API key para mapas)' Yellow
} else {
    Write-Step 'OK google_maps_config.dart' Green
}
$syncMaps = Join-Path (Split-Path $PSScriptRoot -Parent) 'scripts\Sync-GoogleMapsKey.ps1'
if (Test-Path $syncMaps) {
    . $syncMaps
    if (Sync-GoogleMapsKey) {
        Write-Step 'OK clave Maps sincronizada a web/index.html' Green
    } elseif ((Get-Content $mapsConfig -Raw) -match 'YOUR_GOOGLE') {
        Write-Step 'Maps Web: falta API key real en google_maps_config.dart' Yellow
    }
}

# Backend: Maven
Write-Step 'Descargando dependencias Maven (backend)...' Cyan
Set-Location $BackendDir
& .\mvnw.cmd dependency:resolve -q
if ($LASTEXITCODE -ne 0) { throw 'mvnw dependency:resolve fallo' }
Write-Step 'OK dependencias backend' Green

# Frontend: Flutter pub get
$flutter = Resolve-Flutter
if (-not $flutter) {
    Write-Step 'Flutter no encontrado. Instala SDK o define FLUTTER_ROOT.' Red
    Write-Step '  Ejemplo: $env:FLUTTER_ROOT = "C:\Users\TU\devMovil\flutter_windows_3.41.4-stable\flutter"' Yellow
    exit 1
}

Write-Step "Flutter: $flutter" Cyan
$flutterDir = Split-Path $flutter -Parent
$env:PATH = "$flutterDir;$env:PATH"

Set-Location $FrontendDir
Write-Step 'Descargando paquetes Flutter (pub get)...' Cyan
& $flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Step 'flutter pub get fallo. Si menciona symlinks, activa Modo desarrollador:' Yellow
    Write-Step '  start ms-settings:developers' Yellow
    exit 1
}
Write-Step 'OK dependencias frontend' Green

# Web + Chrome (vista celular en navegador)
& $flutter config --enable-web 2>&1 | Out-Null

Write-Host ''
Write-Step 'Listo. Para ver la app como celular:' Green
Write-Step '  .\INICIAR-CELULAR.bat' Cyan
Write-Step '  o: powershell -ExecutionPolicy Bypass -File .\scripts\run-celular.ps1' Cyan
Write-Host ''
