param(
    [string]$Ip,
    [int]$Port = 8082,
    [switch]$NoPause
)

$ErrorActionPreference = "Stop"

Write-Host "=== Mise a jour de l'IP SmartConstat ===" -ForegroundColor Cyan

function Test-IPv4 {
    param([string]$Value)

    $parsed = $null
    return [System.Net.IPAddress]::TryParse($Value, [ref]$parsed) -and
        $parsed.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork
}

function Test-PrivateIPv4 {
    param([string]$Value)

    if (-not (Test-IPv4 $Value)) {
        return $false
    }

    return $Value -match "^(10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[0-1])\.)"
}

function Test-IgnoredInterface {
    param([string]$Name)

    return $Name -match "VMware|VirtualBox|vEthernet|Hyper-V|Loopback|Pseudo|Docker|WSL|Teredo|isatap"
}

function New-Candidate {
    param(
        [string]$Address,
        [string]$InterfaceAlias,
        [bool]$HasGateway,
        [string]$Source
    )

    if (-not (Test-PrivateIPv4 $Address)) {
        return $null
    }

    if (Test-IgnoredInterface $InterfaceAlias) {
        return $null
    }

    $score = 0
    if ($HasGateway) { $score += 100 }
    if ($InterfaceAlias -match "SAMSUNG|Mobile|RNDIS|USB") { $score += 35 }
    if ($InterfaceAlias -match "Wi-Fi|Wireless|WLAN") { $score += 30 }
    if ($InterfaceAlias -match "Ethernet") { $score += 20 }

    [pscustomobject]@{
        Address = $Address
        InterfaceAlias = $InterfaceAlias
        HasGateway = $HasGateway
        Source = $Source
        Score = $score
    }
}

function Get-IpCandidates {
    $items = @()

    try {
        $configs = Get-NetIPConfiguration -ErrorAction Stop
        foreach ($config in $configs) {
            foreach ($addr in @($config.IPv4Address)) {
                if (-not $addr) { continue }

                $candidate = New-Candidate `
                    -Address $addr.IPAddress `
                    -InterfaceAlias $config.InterfaceAlias `
                    -HasGateway ($null -ne $config.IPv4DefaultGateway) `
                    -Source "Get-NetIPConfiguration"

                if ($candidate) { $items += $candidate }
            }
        }
    } catch {
        Write-Host "[INFO] Get-NetIPConfiguration indisponible, fallback en cours..." -ForegroundColor Yellow
    }

    if ($items.Count -eq 0) {
        try {
            $routes = Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue |
                Select-Object -ExpandProperty InterfaceAlias -Unique

            $addresses = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop
            foreach ($addr in $addresses) {
                $candidate = New-Candidate `
                    -Address $addr.IPAddress `
                    -InterfaceAlias $addr.InterfaceAlias `
                    -HasGateway ($addr.InterfaceAlias -in $routes) `
                    -Source "Get-NetIPAddress"

                if ($candidate) { $items += $candidate }
            }
        } catch {
            Write-Host "[INFO] Get-NetIPAddress indisponible, fallback ipconfig en cours..." -ForegroundColor Yellow
        }
    }

    if ($items.Count -eq 0) {
        $raw = ipconfig | Out-String
        $matches = [regex]::Matches($raw, "IPv4[^:]*:\s*([0-9]{1,3}(?:\.[0-9]{1,3}){3})")

        foreach ($match in $matches) {
            $candidate = New-Candidate `
                -Address $match.Groups[1].Value `
                -InterfaceAlias "ipconfig" `
                -HasGateway $false `
                -Source "ipconfig"

            if ($candidate) { $items += $candidate }
        }
    }

    $seen = @{}
    foreach ($item in ($items | Sort-Object -Property Score -Descending)) {
        if (-not $seen.ContainsKey($item.Address)) {
            $seen[$item.Address] = $true
            $item
        }
    }
}

function Write-Utf8File {
    param(
        [string]$Path,
        [string]$Content
    )

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $encoding)
}

function Update-Pattern {
    param(
        [string]$Path,
        [string]$Pattern,
        [string]$Replacement,
        [string]$Label,
        [switch]$AppendIfMissing,
        [switch]$SilentIfMissing
    )

    if (-not (Test-Path $Path)) {
        Write-Host "[ERREUR] Fichier introuvable : $Label" -ForegroundColor Red
        return $false
    }

    $content = [System.IO.File]::ReadAllText($Path)
    $regex = [regex]::new($Pattern)

    if ($regex.IsMatch($content)) {
        $newContent = $regex.Replace($content, { param($m) $Replacement })
    } elseif ($AppendIfMissing) {
        $separator = if ($content.EndsWith("`n")) { "" } else { "`r`n" }
        $newContent = $content + $separator + $Replacement + "`r`n"
    } else {
        if (-not $SilentIfMissing) {
            Write-Host "[INFO] Motif non trouve dans : $Label" -ForegroundColor Yellow
        }
        return $false
    }

    if ($newContent -eq $content) {
        Write-Host "[OK] Deja a jour : $Label" -ForegroundColor DarkGreen
        return $true
    }

    Write-Utf8File -Path $Path -Content $newContent
    Write-Host "[OK] IP mise a jour dans : $Label" -ForegroundColor Green
    return $true
}

if ([string]::IsNullOrWhiteSpace($Ip)) {
    $candidates = @(Get-IpCandidates)

    if ($candidates.Count -eq 0) {
        Write-Host "[ERREUR] Impossible de detecter une IP locale utilisable." -ForegroundColor Red
        Write-Host "Relance avec une IP forcee, par exemple :" -ForegroundColor Yellow
        Write-Host ".\setup_ip.ps1 -Ip 192.168.1.23" -ForegroundColor White
        exit 1
    }

    $selected = $candidates | Select-Object -First 1
    $Ip = $selected.Address

    Write-Host "IP detectee : $Ip ($($selected.InterfaceAlias))" -ForegroundColor Green
    if ($candidates.Count -gt 1) {
        Write-Host "Autres IP candidates :" -ForegroundColor DarkCyan
        $candidates | Select-Object -Skip 1 -First 5 | ForEach-Object {
            Write-Host "  - $($_.Address) ($($_.InterfaceAlias))"
        }
    }
} elseif (-not (Test-IPv4 $Ip)) {
    Write-Host "[ERREUR] IP invalide : $Ip" -ForegroundColor Red
    exit 1
} else {
    Write-Host "IP forcee : $Ip" -ForegroundColor Green
}

$backendUrl = "http://${Ip}:$Port"
$apiBase = "$backendUrl/api"

$flutterFile = Join-Path $PSScriptRoot "frontend_flutter\lib\core\constants\api_constants.dart"
$springFile = Join-Path $PSScriptRoot "backend\src\main\resources\application.properties"

$null = Update-Pattern `
    -Path $flutterFile `
    -Pattern "(?m)^\s*static\s+const\s+String\s+baseUrl\s*=\s*['""][^'""]+['""]\s*;" `
    -Replacement "  static const String baseUrl = '$apiBase';" `
    -Label "frontend_flutter/lib/core/constants/api_constants.dart"

$null = Update-Pattern `
    -Path $springFile `
    -Pattern "(?m)^app\.backend\.url=.*$" `
    -Replacement "app.backend.url=$backendUrl" `
    -Label "backend/src/main/resources/application.properties" `
    -AppendIfMissing

$angularFiles = @(
    "frontend_angular\src\app\core\services\auth.service.ts",
    "frontend_angular\src\app\core\services\client.service.ts",
    "frontend_angular\src\app\core\services\constat.ts",
    "frontend_angular\src\app\features\constat-detail\constat-detail.html"
)

foreach ($relativePath in $angularFiles) {
    $path = Join-Path $PSScriptRoot $relativePath
    if (-not (Test-Path $path)) {
        continue
    }

    $null = Update-Pattern `
        -Path $path `
        -Pattern "http://[A-Za-z0-9\.\-]+:$Port/api" `
        -Replacement $apiBase `
        -Label $relativePath `
        -SilentIfMissing

    $null = Update-Pattern `
        -Path $path `
        -Pattern "http://[A-Za-z0-9\.\-]+:$Port/" `
        -Replacement "$backendUrl/" `
        -Label $relativePath `
        -SilentIfMissing
}

Write-Host ""
Write-Host "Mise a jour terminee." -ForegroundColor Cyan
Write-Host "Backend/API : $apiBase" -ForegroundColor White
Write-Host "Apres changement d'IP : relance Spring Boot, puis fais un Hot Restart Flutter." -ForegroundColor White

if (-not $NoPause) {
    Write-Host ""
    Write-Host "Appuie sur Entree pour fermer..."
    Read-Host | Out-Null
}
