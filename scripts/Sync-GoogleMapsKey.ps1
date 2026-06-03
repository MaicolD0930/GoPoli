# Sincroniza la clave de lib/config/google_maps_config.dart -> web/index.html (requerido en Flutter Web).
param(
    [string]$FrontendDir = (Join-Path (Split-Path $PSScriptRoot -Parent) 'frontend')
)

$configDart = Join-Path $FrontendDir 'lib\config\google_maps_config.dart'
$indexHtml = Join-Path $FrontendDir 'web\index.html'

if (-not (Test-Path $configDart)) {
    Write-Warning 'No existe google_maps_config.dart'
    return $false
}
if (-not (Test-Path $indexHtml)) {
    Write-Warning 'No existe web/index.html'
    return $false
}

$content = Get-Content $configDart -Raw -Encoding UTF8
if ($content -notmatch "kGoogleMapsApiKey\s*=\s*'([^']*)'") {
    Write-Warning 'No se encontro kGoogleMapsApiKey en google_maps_config.dart'
    return $false
}

$key = $matches[1].Trim()
$html = Get-Content $indexHtml -Raw -Encoding UTF8

if ($html -notmatch 'maps\.googleapis\.com/maps/api/js') {
    Write-Warning 'index.html no tiene el script de Google Maps'
    return $false
}

$updated = $html -replace '(?<=maps/api/js\?key=)[^"''&\s]+', $key
if ($updated -eq $html -and $key -match 'YOUR_GOOGLE') {
    Write-Warning 'Pon una API key real en google_maps_config.dart (sigue el placeholder).'
    return $false
}

if ($updated -ne $html) {
    Set-Content -Path $indexHtml -Value $updated -Encoding UTF8 -NoNewline
}

# Backend Directions API (misma clave)
$backendEnv = Join-Path (Split-Path $FrontendDir -Parent) 'backend\.env'
if (Test-Path $backendEnv) {
    $envLines = Get-Content $backendEnv -Encoding UTF8
    $filtered = @($envLines | Where-Object { $_ -notmatch '^\s*GOOGLE_MAPS_API_KEY=' })
    $filtered += "GOOGLE_MAPS_API_KEY=$key"
    Set-Content -Path $backendEnv -Value $filtered -Encoding UTF8
}

return $true
