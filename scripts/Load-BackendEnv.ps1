# Carga backend/.env en variables de proceso (Spring Boot las lee como SPRING_DATASOURCE_*).
function Import-BackendEnv {
    param(
        [string]$BackendDir = (Join-Path (Split-Path $PSScriptRoot -Parent) 'backend')
    )

    $envFile = Join-Path $BackendDir '.env'
    if (-not (Test-Path $envFile)) {
        return $false
    }

    Get-Content $envFile -Encoding UTF8 | ForEach-Object {
        $line = $_.Trim()
        if ($line.Length -eq 0 -or $line.StartsWith('#')) { return }
        $eq = $line.IndexOf('=')
        if ($eq -lt 1) { return }
        $name = $line.Substring(0, $eq).Trim()
        $value = $line.Substring($eq + 1).Trim()
        if ($value.StartsWith('"') -and $value.EndsWith('"')) {
            $value = $value.Substring(1, $value.Length - 2)
        }
        [Environment]::SetEnvironmentVariable($name, $value, 'Process')
    }
    return $true
}

function Test-BackendEnvReady {
    param([string]$BackendDir)

    if (-not (Import-BackendEnv -BackendDir $BackendDir)) {
        return $false
    }
    $url = $env:SPRING_DATASOURCE_URL
    $pass = $env:SPRING_DATASOURCE_PASSWORD
    if ([string]::IsNullOrWhiteSpace($url)) { return $false }
    if ($url -notmatch 'neon\.tech') { return $true }
    if ([string]::IsNullOrWhiteSpace($pass)) { return $false }
    if ($pass -match 'cambiar|PEGA_|XXXX') { return $false }
    if ($pass -match '^postgresql://') { return $false }
    return $true
}

function Get-BackendDbLabel {
    $url = $env:SPRING_DATASOURCE_URL
    if ($url -match 'neon\.tech') {
        if ($url -match '@([^/]+)/') { return "Neon ($($matches[1]))" }
        return 'Neon (PostgreSQL en la nube)'
    }
    if ($url -match 'localhost') { return "PostgreSQL local ($url)" }
    return $url
}
