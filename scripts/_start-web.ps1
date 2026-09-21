$host.UI.RawUI.WindowTitle = 'GoPoli Web'
Set-Location -LiteralPath 'D:\jorge\Projects\GoPoli\web'
Write-Host 'Iniciando Next.js en http://localhost:3000 ...' -ForegroundColor Cyan
Write-Host 'API esperada: http://localhost:8080' -ForegroundColor DarkGray
& npm run dev
