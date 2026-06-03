# Guia / automatizacion del deploy en Render.
# Uso:
#   .\scripts\deploy-render.ps1
#   .\scripts\deploy-render.ps1 -ApiUrl https://gopoli-backend.onrender.com
# Con API key (backend/.env): RENDER_API_KEY=rnd_...

param(
    [string]$ApiUrl,
    [switch]$SkipOpenDashboard
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path $PSScriptRoot -Parent
$BackendDir = Join-Path $RepoRoot 'backend'
$RenderUrlFile = Join-Path $RepoRoot 'render.url'
$LoadEnvScript = Join-Path $RepoRoot 'scripts\Load-BackendEnv.ps1'
. $LoadEnvScript

function Write-Step($msg, $color = 'White') {
    Write-Host $msg -ForegroundColor $color
}

function Mask-Secret([string]$value) {
    if ([string]::IsNullOrWhiteSpace($value)) { return '(vacio)' }
    if ($value.Length -le 6) { return '******' }
    return ($value.Substring(0, 3) + '...' + $value.Substring($value.Length - 3))
}

function Save-RenderUrl([string]$url) {
    $clean = $url.Trim().TrimEnd('/')
    Set-Content -Path $RenderUrlFile -Value $clean -Encoding UTF8 -NoNewline
    Write-Step "Guardado en render.url: $clean" Green
}

function Test-BackendUrl {
    param([string]$Url)
    try {
        $r = Invoke-WebRequest -Uri "$Url/ubicaciones" -UseBasicParsing -TimeoutSec 60
        return ($r.StatusCode -eq 200)
    } catch {
        return $false
    }
}

function Show-EnvBlock {
    Import-BackendEnv -BackendDir $BackendDir | Out-Null
    if (-not (Test-BackendEnvReady -BackendDir $BackendDir)) {
        throw 'backend/.env incompleto. Copia .env.example y configura Neon.'
    }

    Write-Host ''
    Write-Step 'Variables para pegar en Render (Environment):' Cyan
    Write-Host "SPRING_DATASOURCE_URL=$($env:SPRING_DATASOURCE_URL)"
    Write-Host "SPRING_DATASOURCE_USERNAME=$($env:SPRING_DATASOURCE_USERNAME)"
    Write-Host "SPRING_DATASOURCE_PASSWORD=$(Mask-Secret $env:SPRING_DATASOURCE_PASSWORD)"
    Write-Host "GOOGLE_MAPS_API_KEY=$(Mask-Secret $env:GOOGLE_MAPS_API_KEY)"
    Write-Host 'GOPOLI_JWT_SECRET=(genera una clave larga aleatoria)'
    Write-Host 'SPRING_JPA_SHOW_SQL=false'
    Write-Host ''

    $block = @"
SPRING_DATASOURCE_URL=$($env:SPRING_DATASOURCE_URL)
SPRING_DATASOURCE_USERNAME=$($env:SPRING_DATASOURCE_USERNAME)
SPRING_DATASOURCE_PASSWORD=$($env:SPRING_DATASOURCE_PASSWORD)
GOOGLE_MAPS_API_KEY=$($env:GOOGLE_MAPS_API_KEY)
GOPOLI_JWT_SECRET=GoPoliProdSecretMinimo32Caracteres!!
SPRING_JPA_SHOW_SQL=false
"@
    try {
        Set-Clipboard -Value $block
        Write-Step 'Bloque completo copiado al portapapeles (incluye contraseñas).' Green
    } catch {
        Write-Step 'No se pudo copiar al portapapeles; copia manualmente desde arriba.' Yellow
    }
}

function Invoke-RenderApiDeploy {
    param([string]$ApiKey)

    $headers = @{
        Authorization = "Bearer $ApiKey"
        Accept        = 'application/json'
        'Content-Type' = 'application/json'
    }

    $owners = Invoke-RestMethod -Uri 'https://api.render.com/v1/owners' -Headers $headers -Method Get
    if (-not $owners -or $owners.Count -eq 0) {
        throw 'No se encontraron owners en Render.'
    }
    $ownerId = $owners[0].owner.id

    Import-BackendEnv -BackendDir $BackendDir | Out-Null
    $body = @{
        type             = 'web_service'
        name             = 'gopoli-backend'
        ownerId          = $ownerId
        repo             = 'https://github.com/MaicolD0930/GoPoli'
        branch           = 'jorge'
        rootDir          = 'backend'
        runtime          = 'docker'
        plan             = 'free'
        region           = 'ohio'
        healthCheckPath  = '/ubicaciones'
        autoDeploy       = 'yes'
        envVars          = @(
            @{ key = 'SPRING_DATASOURCE_URL'; value = $env:SPRING_DATASOURCE_URL },
            @{ key = 'SPRING_DATASOURCE_USERNAME'; value = $env:SPRING_DATASOURCE_USERNAME },
            @{ key = 'SPRING_DATASOURCE_PASSWORD'; value = $env:SPRING_DATASOURCE_PASSWORD },
            @{ key = 'GOOGLE_MAPS_API_KEY'; value = $env:GOOGLE_MAPS_API_KEY },
            @{ key = 'GOPOLI_JWT_SECRET'; value = 'GoPoliProdSecretMinimo32Caracteres!!' },
            @{ key = 'SPRING_JPA_SHOW_SQL'; value = 'false' }
        )
    } | ConvertTo-Json -Depth 6

    Write-Step 'Creando servicio en Render via API...' Cyan
    $service = Invoke-RestMethod -Uri 'https://api.render.com/v1/services' -Headers $headers -Method Post -Body $body
    $serviceId = $service.service.id
    Write-Step "Servicio creado: $serviceId" Green

    Start-Sleep -Seconds 5
    $detail = Invoke-RestMethod -Uri "https://api.render.com/v1/services/$serviceId" -Headers $headers -Method Get
    return $detail.service.serviceDetails.url
}

Write-Host ''
Write-Host '=== GoPoli: deploy Render ===' -ForegroundColor Magenta
Write-Host ''

if ($ApiUrl) {
    Save-RenderUrl $ApiUrl
    if (Test-BackendUrl -Url $ApiUrl.Trim().TrimEnd('/')) {
        Write-Step 'Backend en Render respondiendo.' Green
    } else {
        Write-Step 'URL guardada pero /ubicaciones aun no responde. Espera el deploy en Render.' Yellow
    }
    exit 0
}

if (Test-Path $RenderUrlFile) {
    $existing = (Get-Content $RenderUrlFile -Raw).Trim().TrimEnd('/')
    if ($existing -match '^https://' -and (Test-BackendUrl -Url $existing)) {
        Write-Step "Backend ya activo: $existing" Green
        Write-Step 'Siguiente paso: .\scripts\run-android.ps1' Cyan
        exit 0
    }
}

Import-BackendEnv -BackendDir $BackendDir | Out-Null
$renderKey = $env:RENDER_API_KEY

if ($renderKey -and $renderKey -notmatch 'cambiar|rnd_XXXX') {
    try {
        $url = Invoke-RenderApiDeploy -ApiKey $renderKey
        if ($url) {
            Save-RenderUrl $url
            Write-Step 'Esperando primer deploy (2-5 min)...' Cyan
            $deadline = (Get-Date).AddMinutes(8)
            while ((Get-Date) -lt $deadline) {
                if (Test-BackendUrl -Url $url) {
                    Write-Step "Backend listo: $url" Green
                    Write-Step 'Ejecuta: .\scripts\run-android.ps1' Cyan
                    exit 0
                }
                Start-Sleep -Seconds 15
            }
            Write-Step "Servicio creado ($url) pero aun no responde. Revisa logs en Render." Yellow
            exit 0
        }
    } catch {
        Write-Step "API Render fallo: $($_.Exception.Message)" Yellow
    }
}

Show-EnvBlock

Write-Step 'Pasos manuales en Render:' Cyan
Write-Step '  1. New > Web Service > repo GoPoli' White
Write-Step '  2. Root Directory: backend | Runtime: Docker' White
Write-Step '  3. Plan Free | Health check: /ubicaciones' White
Write-Step '  4. Pega las variables de entorno (portapapeles)' White
Write-Step '  5. Deploy — copia la URL publica' White
Write-Step '  6. .\scripts\deploy-render.ps1 -ApiUrl https://TU-SERVICIO.onrender.com' White
Write-Host ''

if (-not $SkipOpenDashboard) {
    Start-Process 'https://dashboard.render.com/web/new'
}

Write-Step 'Alternativa: New > Blueprint con render.yaml en el repo.' Yellow
Write-Host ''
