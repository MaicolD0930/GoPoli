$host.UI.RawUI.WindowTitle = 'GoPoli Backend'
Set-Location -LiteralPath 'D:\jorge\Projects\GoPoli\backend'
$env:SPRING_DATASOURCE_URL = 'jdbc:postgresql://localhost:5432/gopoli'
$env:SPRING_DATASOURCE_USERNAME = 'gopoli'
$env:SPRING_DATASOURCE_PASSWORD = 'gopoli'
Write-Host 'Iniciando Spring Boot en http://localhost:8080 ...' -ForegroundColor Cyan
& .\mvnw.cmd spring-boot:run
