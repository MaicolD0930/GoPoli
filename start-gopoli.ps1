# Inicia backend Spring Boot y frontend Flutter.
# Por defecto usa backend/.env (Neon) si existe; si no, PostgreSQL local en Docker.
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
    [switch]$SkipDbRestore,

    # Forzar BD local en Docker (ignora backend/.env de Neon)
    [switch]$UseLocalDb,

    # Ventana del navegador ~ tamano iPhone (vista celular en Chrome/Opera)
    [switch]$MobileView
)

$ErrorActionPreference = 'Stop'
$RepoRoot = $PSScriptRoot
$BackendDir = Join-Path $RepoRoot 'backend'
$FrontendDir = Join-Path $RepoRoot 'frontend'
$ApiUrl = 'http://localhost:8080'
$DbPort = 5433
$DockerName = 'gopoli-postgres'
$LoadEnvScript = Join-Path $RepoRoot 'scripts\Load-BackendEnv.ps1'
. $LoadEnvScript

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
    param([bool]$UseNeon)

    if (Test-BackendReady) {
        Write-Step 'API' "Backend ya responde en $ApiUrl" 'Green'
        return
    }

    $runnerScript = Join-Path $RepoRoot 'scripts\_start-backend.ps1'
    $runnerDir = Split-Path $runnerScript -Parent
    if (-not (Test-Path $runnerDir)) {
        New-Item -ItemType Directory -Path $runnerDir -Force | Out-Null
    }

    if ($UseNeon) {
        if (-not (Test-BackendEnvReady -BackendDir $BackendDir)) {
            throw @"
backend/.env incompleto para Neon.
1. Abre Neon -> Connect -> copia la contraseña de neondb_owner
2. Edita backend/.env y reemplaza cambiar_por_password_neon
"@
        }
        Import-BackendEnv -BackendDir $BackendDir | Out-Null
        $dbLabel = Get-BackendDbLabel
        @"
`$host.UI.RawUI.WindowTitle = 'GoPoli Backend (Neon)'
. '$LoadEnvScript'
Import-BackendEnv -BackendDir '$BackendDir' | Out-Null
Write-Host 'BD: $dbLabel' -ForegroundColor Green
Write-Host 'Iniciando Spring Boot en $ApiUrl ...' -ForegroundColor Cyan
Set-Location -LiteralPath '$BackendDir'
& .\mvnw.cmd spring-boot:run
"@ | Set-Content -Path $runnerScript -Encoding UTF8
    } else {
        @"
`$host.UI.RawUI.WindowTitle = 'GoPoli Backend (local)'
Set-Location -LiteralPath '$BackendDir'
`$env:SPRING_DATASOURCE_URL = 'jdbc:postgresql://localhost:$DbPort/gopoli'
`$env:SPRING_DATASOURCE_USERNAME = 'postgres'
`$env:SPRING_DATASOURCE_PASSWORD = '123456789'
Write-Host 'BD: PostgreSQL local (Docker puerto $DbPort)' -ForegroundColor Yellow
Write-Host 'Iniciando Spring Boot en $ApiUrl ...' -ForegroundColor Cyan
& .\mvnw.cmd spring-boot:run
"@ | Set-Content -Path $runnerScript -Encoding UTF8
    }

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
    $syncScript = Join-Path $RepoRoot 'scripts\Sync-GoogleMapsKey.ps1'
    if (Test-Path $syncScript) {
        . $syncScript
        if (Sync-GoogleMapsKey) {
            Write-Step 'APP' 'Clave Maps sincronizada a web/index.html' 'Green'
        }
    }
}

# --- Main ---
Write-Host ''
Write-Host '=== GoPoli ===' -ForegroundColor Magenta
Write-Host "Navegador: $Browser"
Write-Host ''

try {
    $useNeon = (-not $UseLocalDb) -and (Test-BackendEnvReady -BackendDir $BackendDir)
    if ($useNeon) {
        Write-Step 'DB' (Get-BackendDbLabel) 'Green'
        Write-Step 'DB' 'Rama Neon puede estar archivada; al conectar se reactiva sola.' 'Cyan'
        $SkipDocker = $true
    } elseif (-not $UseLocalDb -and (Test-Path (Join-Path $BackendDir '.env'))) {
        throw 'backend/.env existe pero falta la contraseña de Neon. Edita SPRING_DATASOURCE_PASSWORD.'
    } else {
        Write-Step 'DB' 'Sin backend/.env valido: usando PostgreSQL local (Docker).' 'Yellow'
    }

    if (-not $SkipDocker) {
        Start-PostgresDocker
    }

    Start-BackendWindow -UseNeon:$useNeon
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
    & $flutter config --enable-web 2>&1 | Out-Null

    $pubResult = & $flutter pub get 2>&1
    if ($LASTEXITCODE -ne 0) {
        $pubText = $pubResult -join "`n"
        if ($pubText -match 'symlink') {
            Write-Step 'APP' 'Activa Modo de desarrollador en Windows (symlinks): start ms-settings:developers' 'Yellow'
        }
        Write-Host $pubText
        throw 'flutter pub get fallo.'
    }

    $deviceList = & $flutter devices 2>&1 | Out-String
    $flutterDevice = 'chrome'
    if ($deviceList -notmatch '\bchrome\b') {
        if ($deviceList -match '\bedge\b') {
            $flutterDevice = 'edge'
            Write-Step 'APP' 'Chrome no detectado; usando Microsoft Edge.' 'Yellow'
        } else {
            throw 'No hay navegador web para Flutter (chrome ni edge). Instala Chrome o Edge.'
        }
    }

    $flutterArgs = @(
        'run',
        '-d', $flutterDevice,
        '--dart-define=API_URL=' + $ApiUrl
    )
    if ($MobileView) {
        Write-Step 'APP' 'Vista celular: ventana 390x844 px' 'Cyan'
        $flutterArgs += @(
            '--web-browser-flag=--window-size=390,844',
            '--web-browser-flag=--window-position=120,40',
            '--web-browser-flag=--disable-extensions'
        )
    }

    & $flutter @flutterArgs
}
catch {
    Write-Host ''
    Write-Host 'ERROR:' $_.Exception.Message -ForegroundColor Red
    if ($_.ScriptStackTrace) {
        Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
    }
    exit 1
}
