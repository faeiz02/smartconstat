# Script de renommage des composants Angular vers la convention .component.*
$base = "src/app"

# Liste des composants a renommer (chemin relatif depuis frontend_angular)
$components = @(
    "$base/features/login/login",
    "$base/features/dashboard/dashboard",
    "$base/features/constat-detail/constat-detail",
    "$base/features/clients/clients",
    "$base/features/employees/employees",
    "$base/features/factures/factures",
    "$base/features/assistance/assistance",
    "$base/features/partenaires/partenaires",
    "$base/features/assurances/assurances",
    "$base/features/avis/avis",
    "$base/core/layout/admin-layout/admin-layout"
)

foreach ($comp in $components) {
    # Copier .html -> .component.html
    $htmlSrc = "$comp.html"
    $htmlDst = "$comp.component.html"
    if (Test-Path $htmlSrc) {
        Copy-Item $htmlSrc $htmlDst -Force
        Write-Host "OK: $htmlDst" -ForegroundColor Green
    }

    # Copier .css -> .component.css
    $cssSrc = "$comp.css"
    $cssDst = "$comp.component.css"
    if (Test-Path $cssSrc) {
        Copy-Item $cssSrc $cssDst -Force
        Write-Host "OK: $cssDst" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Renommage termine ! 22 fichiers copies." -ForegroundColor Cyan
