Write-Host "=== Script de Mise a Jour de l'IP du Serveur SmartConstat ===" -ForegroundColor Cyan

# Trouver l'interface active avec une passerelle par défaut
$gateways = Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty InterfaceAlias

# Filtrer les adresses IPv4, en priorisant les interfaces réelles (Wi-Fi/Ethernet) avec une passerelle
$ipInfo = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
    (($_.InterfaceAlias -in $gateways) -or ($_.InterfaceAlias -match "Wi-Fi|Ethernet")) -and 
    ($_.InterfaceAlias -notmatch "VMware|VirtualBox|vEthernet|Hyper-V|Loopback|Pseudo") -and
    ($_.IPAddress -like "192.168.*" -or $_.IPAddress -like "10.*" -or $_.IPAddress -like "172.1[6-9].*" -or $_.IPAddress -like "172.2[0-9].*" -or $_.IPAddress -like "172.3[0-1].*")
} | Sort-Object { $_.InterfaceAlias -match "Wi-Fi" } -Descending | Select-Object -First 1

if (-not $ipInfo) {
    Write-Host "Erreur: Impossible de trouver l'adresse IP locale (Wi-Fi ou Ethernet)." -ForegroundColor Red
    Pause
    exit
}

$currentIp = $ipInfo.IPAddress
Write-Host "Nouvelle adresse IP detectee : $currentIp`n" -ForegroundColor Green

$flutterFile = "$PSScriptRoot\frontend_flutter\lib\core\constants\api_constants.dart"
$springFile = "$PSScriptRoot\backend\src\main\resources\application.properties"

function Update-FileIP {
    param (
        [string]$filePath,
        [string]$regexPattern,
        [string]$replacementText,
        [string]$fileName
    )
    
    if (Test-Path $filePath) {
        $content = Get-Content -Path $filePath -Raw
        if ($content -match $regexPattern) {
            $newContent = $content -replace $regexPattern, $replacementText
            [System.IO.File]::WriteAllText($filePath, $newContent)
            Write-Host "[OK] IP mise a jour dans : $fileName" -ForegroundColor Green
        } else {
            Write-Host "[INFO] Motif non trouve ou IP deja a jour dans : $fileName" -ForegroundColor Yellow
        }
    } else {
        Write-Host "[ERREUR] Fichier introuvable : $filePath" -ForegroundColor Red
    }
}

$flutterRegex = "http://[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:8082/api"
$flutterReplacement = "http://${currentIp}:8082/api"
Update-FileIP -filePath $flutterFile -regexPattern $flutterRegex -replacementText $flutterReplacement -fileName "api_constants.dart"

$springRegex = "app\.backend\.url=http://[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:8082"
$springReplacement = "app.backend.url=http://${currentIp}:8082"
Update-FileIP -filePath $springFile -regexPattern $springRegex -replacementText $springReplacement -fileName "application.properties"

Write-Host "`nMise a jour terminee ! N'oubliez pas de :" -ForegroundColor Cyan
Write-Host "1. Relancer le serveur Spring Boot." -ForegroundColor White
Write-Host "2. Faire un Hot Restart de l'application Flutter." -ForegroundColor White
Write-Host "`nAppuyez sur une touche pour fermer..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
