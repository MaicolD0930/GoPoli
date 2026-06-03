$host.UI.RawUI.WindowTitle = 'GoPoli Backend'
Set-Location -LiteralPath 'C:\Users\maico\Documents\Programing\Cursor\GoPoli\backend'
$env:SPRING_DATASOURCE_URL = 'jdbc:postgresql://localhost:5433/gopoli'
$env:SPRING_DATASOURCE_USERNAME = 'postgres'
$env:SPRING_DATASOURCE_PASSWORD = '123456789'
Write-Host 'Iniciando Spring Boot en http://localhost:8080 ...' -ForegroundColor Cyan
& .\mvnw.cmd spring-boot:run
