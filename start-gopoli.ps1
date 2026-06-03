# Inicia PostgreSQL (Docker), backend Spring Boot y frontend Flutter.
#
# Si PowerShell bloquea scripts, NO ejecutes este archivo directo.
# Usa una de estas opciones:
#   - Doble clic en start-gopoli.bat
#   - powershell -ExecutionPolicy Bypass -File .\start-gopoli.ps1
#
# Uso:
#   .\start-gopoli.ps1 -Browser opera-gx  (solo si ya tienes ExecutionPolicy permitido)

param(
    [ValidateSet('chrome', 'opera', 'opera-gx')]
    [string]$Browser = 'chrome',

    [switch]$SkipDocker,
    [switch]$SkipDbRestore
)

$ErrorActionPreference = 'Stop'
$RepoRoot = $PSScriptRoot
$BackendDir = Join-Path $RepoRoot 'backend'
$FrontendDir = Join-Path $RepoRoot 'frontend'
$ApiUrl = 'http://localhost:8080'
$DbPort = 5433
$DockerName = 'gopoli-postgres'

function Write-Step {
    param([string]$Tag, [string]$Message, [string]$Color = 'White')
    Write-Host "[$Tag] $Message" -ForegroundColor $Color
}

function Resolve-Flutter {
    if ($env:FLUTTER_ROOT -and (Test-Path (Join-Path $env:FLUTTER_ROOT 'bin\flutter.bat'))) {
        return Join-Path $env:FLUTTER_ROOT 'bin\flutter.bat'
    }
    $candidates = @(
        (Join-Path $env:USERPROFILE 'flutter\bin\flutter.bat'),
        'C:\flutter\bin\flutter.bat',
        'C:\src\flutter\bin\flutter.bat'
    )
    foreach ($path in $candidates) {
        if (Test-Path $path) { return $path }
    }
    $cmd = Get-Command flutter -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    throw 'No se encontro Flutter. Instalalo o define FLUTTER_ROOT (ej. C:\Users\maico\flutter).'
}

function Resolve-BrowserExecutable {
    param([string]$Choice)
    $paths = @()
    switch ($Choice) {
        'chrome' {
            $paths = @(
                "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
                "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
                (Join-Path $env:LOCALAPPDATA 'Google\Chrome\Application\chrome.exe')
            )
        }
        default {
            $paths = @(
                (Join-Path $env:LOCALAPPDATA 'Programs\Opera GX\opera.exe'),
                "${env:ProgramFiles}\Opera GX\opera.exe",
                (Join-Path $env:LOCALAPPDATA 'Programs\Opera\opera.exe'),
                "${env:ProgramFiles}\Opera\opera.exe"
            )
        }
    }
    foreach ($p in $paths) {
        if ($p -and (Test-Path $p)) { return $p }
    }
    throw "No se encontro el navegador '$Choice'. Usa -Browser chrome o instala Opera GX."
}

function Test-BackendReady {
    try {
        $null = Invoke-WebRequest -Uri "$ApiUrl/ubicaciones" -UseBasicParsing -TimeoutSec 3
        return $true
    } catch {
        return $false
    }
}

function Start-PostgresDocker {
    $dockerCmd = Get-Command docker -ErrorAction SilentlyContinue
    if (-not $dockerCmd) {
        throw 'Docker no esta instalado o no esta en el PATH. Instala Docker Desktop e intenta de nuevo.'
    }

    $running = docker ps --filter "name=$DockerName" --filter "status=running" -q 2>$null
    if ($running) {
        Write-Step 'DB' 'Contenedor gopoli-postgres ya esta en ejecucion.' 'Green'
        return
    }

    $exists = docker ps -a --filter "name=$DockerName" -q 2>$null
    if (-not $exists) {
        Write-Step 'DB' "Creando PostgreSQL en puerto $DbPort..." 'Cyan'
        docker run -d --name $DockerName `
            -e POSTGRES_USER=postgres `
            -e POSTGRES_PASSWORD=123456789 `
            -e POSTGRES_DB=gopoli `
            -p "${DbPort}:5432" `
            postgres:16-alpine | Out-Null
        Start-Sleep -Seconds 5

        if (-not $SkipDbRestore) {
            $dump = Join-Path $RepoRoot 'gopoli.dump'
            $pgRestore = 'C:\Program Files\PostgreSQL\18\bin\pg_restore.exe'
            if ((Test-Path $dump) -and (Test-Path $pgRestore)) {
                Write-Step 'DB' 'Restaurando gopoli.dump...' 'Cyan'
                $env:PGPASSWORD = '123456789'
                & $pgRestore --no-owner --no-privileges -h localhost -p $DbPort -U postgres -d gopoli $dump 2>&1 | Out-Null
            }
        }
    } else {
        Write-Step 'DB' 'Iniciando contenedor gopoli-postgres...' 'Cyan'
        docker start $DockerName | Out-Null
        Start-Sleep -Seconds 3
    }
}

function Start-BackendWindow {
    if (Test-BackendReady) {
        Write-Step 'API' "Backend ya responde en $ApiUrl" 'Green'
        return
    }

    $runnerScript = Join-Path $RepoRoot 'scripts\_start-backend.ps1'
    $runnerDir = Split-Path $runnerScript -Parent
    if (-not (Test-Path $runnerDir)) {
        New-Item -ItemType Directory -Path $runnerDir -Force | Out-Null
    }

    @"
`$host.UI.RawUI.WindowTitle = 'GoPoli Backend'
Set-Location -LiteralPath '$BackendDir'
`$env:SPRING_DATASOURCE_URL = 'jdbc:postgresql://localhost:$DbPort/gopoli'
`$env:SPRING_DATASOURCE_USERNAME = 'postgres'
`$env:SPRING_DATASOURCE_PASSWORD = '123456789'
Write-Host 'Iniciando Spring Boot en $ApiUrl ...' -ForegroundColor Cyan
& .\mvnw.cmd spring-boot:run
"@ | Set-Content -Path $runnerScript -Encoding UTF8

    Start-Process powershell -ArgumentList @(
        '-NoExit',
        '-ExecutionPolicy', 'Bypass',
        '-File', $runnerScript
    ) | Out-Null

    Write-Step 'API' 'Ventana del backend abierta. Esperando respuesta...' 'Cyan'

    $deadline = (Get-Date).AddMinutes(4)
    while ((Get-Date) -lt $deadline) {
        if (Test-BackendReady) {
            Write-Step 'API' 'Backend listo.' 'Green'
            return
        }
        Start-Sleep -Seconds 2
    }
    throw 'El backend no respondio en 4 minutos. Revisa la ventana GoPoli Backend.'
}

function Ensure-FrontendConfig {
    $mapsConfig = Join-Path $FrontendDir 'lib\config\google_maps_config.dart'
    $mapsExample = Join-Path $FrontendDir 'lib\config\google_maps_config.example.dart'
    if (-not (Test-Path $mapsConfig)) {
        Copy-Item $mapsExample $mapsConfig
        Write-Step 'APP' 'Creado google_maps_config.dart. Agrega tu clave de Google Maps.' 'Yellow'
    }
}

# --- Main ---
Write-Host ''
Write-Host '=== GoPoli ===' -ForegroundColor Magenta
Write-Host "Navegador: $Browser"
Write-Host ''

try {
    if (-not $SkipDocker) {
        Start-PostgresDocker
    }

    Start-BackendWindow
    Ensure-FrontendConfig

    $flutter = Resolve-Flutter
    $browserExe = Resolve-BrowserExecutable -Choice $Browser
    $flutterDir = Split-Path $flutter -Parent
    $env:PATH = $flutterDir + ';' + $env:PATH
    $env:CHROME_EXECUTABLE = $browserExe

    $browserName = [System.IO.Path]::GetFileName($browserExe)
    Write-Step 'APP' "Iniciando Flutter con $browserName ..."
    Write-Step 'APP' "API: $ApiUrl"

    Set-Location $FrontendDir

    $pubResult = & $flutter pub get 2>&1
    if ($LASTEXITCODE -ne 0) {
        $pubText = $pubResult -join "`n"
        if ($pubText -match 'symlink') {
            Write-Step 'APP' 'Activa Modo de desarrollador en Windows (symlinks): start ms-settings:developers' 'Yellow'
        }
        Write-Host $pubText
        throw 'flutter pub get fallo.'
    }

    & $flutter run -d chrome --dart-define=API_URL=$ApiUrl
}
catch {
    Write-Host ''
    Write-Host 'ERROR:' $_.Exception.Message -ForegroundColor Red
    if ($_.ScriptStackTrace) {
        Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
    }
    exit 1
}
