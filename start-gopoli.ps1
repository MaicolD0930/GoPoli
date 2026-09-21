# Inicia PostgreSQL (Docker), backend Spring Boot y PWA Next.js (web/).
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
$WebDir = Join-Path $RepoRoot 'web'
$ApiUrl = 'http://localhost:8080'
$WebUrl = 'http://localhost:3000'
$DbPort = 5432
$DockerName = 'gopoli-postgres'

function Write-Step {
    param([string]$Tag, [string]$Message, [string]$Color = 'White')
    Write-Host "[$Tag] $Message" -ForegroundColor $Color
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

function Test-WebReady {
    try {
        $null = Invoke-WebRequest -Uri $WebUrl -UseBasicParsing -TimeoutSec 3
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
        $published = docker ps --filter "name=$DockerName" --filter "status=running" --format '{{.Ports}}'
        Write-Step 'DB' "Contenedor gopoli-postgres ya esta en ejecucion ($published)." 'Green'
        return
    }

    $exists = docker ps -a --filter "name=$DockerName" -q 2>$null
    if (-not $exists) {
        Write-Step 'DB' "Creando PostgreSQL en puerto $DbPort (docker compose)..." 'Cyan'
        docker compose up -d
        Start-Sleep -Seconds 5
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
`$env:SPRING_DATASOURCE_USERNAME = 'gopoli'
`$env:SPRING_DATASOURCE_PASSWORD = 'gopoli'
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

function Ensure-WebEnv {
    if (-not (Test-Path $WebDir)) {
        throw "No se encontro la carpeta web/ en $RepoRoot"
    }

    $envFile = Join-Path $WebDir '.env'
    $envExample = Join-Path $WebDir '.env.example'
    if (-not (Test-Path $envFile) -and (Test-Path $envExample)) {
        Copy-Item $envExample $envFile
        Write-Step 'WEB' 'Creado web/.env desde .env.example' 'Yellow'
    }
}

function Start-WebWindow {
    if (Test-WebReady) {
        Write-Step 'WEB' "PWA ya responde en $WebUrl" 'Green'
        return
    }

    $npm = Get-Command npm -ErrorAction SilentlyContinue
    if (-not $npm) {
        throw 'No se encontro npm. Instala Node.js LTS e intenta de nuevo.'
    }

    $nodeModules = Join-Path $WebDir 'node_modules'
    if (-not (Test-Path $nodeModules)) {
        Write-Step 'WEB' 'Instalando dependencias (npm install)...' 'Cyan'
        Push-Location $WebDir
        try {
            & npm install
            if ($LASTEXITCODE -ne 0) {
                throw 'npm install fallo.'
            }
        } finally {
            Pop-Location
        }
    }

    $runnerScript = Join-Path $RepoRoot 'scripts\_start-web.ps1'
    @"
`$host.UI.RawUI.WindowTitle = 'GoPoli Web'
Set-Location -LiteralPath '$WebDir'
Write-Host 'Iniciando Next.js en $WebUrl ...' -ForegroundColor Cyan
Write-Host 'API esperada: $ApiUrl' -ForegroundColor DarkGray
& npm run dev
"@ | Set-Content -Path $runnerScript -Encoding UTF8

    Start-Process powershell -ArgumentList @(
        '-NoExit',
        '-ExecutionPolicy', 'Bypass',
        '-File', $runnerScript
    ) | Out-Null

    Write-Step 'WEB' 'Ventana de la PWA abierta. Esperando respuesta...' 'Cyan'

    $deadline = (Get-Date).AddMinutes(3)
    while ((Get-Date) -lt $deadline) {
        if (Test-WebReady) {
            Write-Step 'WEB' 'PWA lista.' 'Green'
            return
        }
        Start-Sleep -Seconds 2
    }
    throw 'La PWA no respondio en 3 minutos. Revisa la ventana GoPoli Web.'
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
    Ensure-WebEnv
    Start-WebWindow

    $browserExe = Resolve-BrowserExecutable -Choice $Browser
    $browserName = [System.IO.Path]::GetFileName($browserExe)
    Write-Step 'WEB' "Abriendo $WebUrl en $browserName ..."
    Start-Process -FilePath $browserExe -ArgumentList $WebUrl | Out-Null

    Write-Step 'OK' "Backend: $ApiUrl | PWA: $WebUrl" 'Green'
}
catch {
    Write-Host ''
    Write-Host 'ERROR:' $_.Exception.Message -ForegroundColor Red
    if ($_.ScriptStackTrace) {
        Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
    }
    exit 1
}
