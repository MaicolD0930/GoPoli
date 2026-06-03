# Inicia GoPoli con ventana de navegador tamano telefono (Chrome/Opera).
# Uso: powershell -ExecutionPolicy Bypass -File .\scripts\run-celular.ps1

param(
    [ValidateSet('chrome', 'opera', 'opera-gx')]
    [string]$Browser = 'chrome'
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path $PSScriptRoot -Parent

# Reutiliza el arranque completo (DB + backend + Flutter) en ventana tipo telefono
& (Join-Path $RepoRoot 'start-gopoli.ps1') -Browser $Browser -MobileView @PSBoundParameters
