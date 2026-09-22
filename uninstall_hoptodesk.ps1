# 1. Arrêt du service s'il est encore en cours d'exécution
$serviceName = "HopToDesk" # Ajustez si le nom exact du service diffère
if (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) {
    Write-Host "Arrêt du service $serviceName..." -ForegroundColor Cyan
    Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
    
    # Suppression définitive du service de Windows
    Write-Host "Suppression du service Windows..." -ForegroundColor Cyan
    sc.exe delete $serviceName | Out-Null
}

# 2. Désinstallation des fichiers existants
$uninstallPaths = @(
    "$env:ProgramFiles\HopToDesk\uninstall.exe",
    "${env:ProgramFiles(x86)}\HopToDesk\uninstall.exe",
    "$env:LOCALAPPDATA\HopToDesk\uninstall.exe"
)

foreach ($path in $uninstallPaths) {
    if (Test-Path $path) {
        Write-Host "Exécution du désinstalleur : $path" -ForegroundColor Cyan
        Start-Process $path -ArgumentList "--silent" -Wait -NoNewWindow
    }
}

# 3. Nettoyage agressif des dossiers résiduels
$foldersToRemove = @(
    "$env:ProgramFiles\HopToDesk",
    "${env:ProgramFiles(x86)}\HopToDesk",
    "$env:LOCALAPPDATA\HopToDesk",
    "$env:ProgramData\HopToDesk"
)

foreach ($folder in $foldersToRemove) {
    if (Test-Path $folder) {
        Write-Host "Suppression du dossier résiduel : $folder" -ForegroundColor Yellow
        Remove-Item -Path $folder -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# ==========================================
# 4. VÉRIFICATION FINALE
# ==========================================
Write-Host "`n--- RAPPORT DE VÉRIFICATION ---" -ForegroundColor Green

# A. Vérification du service Windows
$checkService = Get-CimInstance Win32_Service -Filter "Name LIKE '%HopToDesk%'" -ErrorAction SilentlyContinue
if ($checkService) {
    Write-Host "[X] Le service Windows est encore présent !" -ForegroundColor Red
} else {
    Write-Host "[OK] Aucun service HopToDesk trouvé." -ForegroundColor Green
}

# B. Vérification des dossiers
$foldersStillExist = $false
foreach ($folder in $foldersToRemove) {
    if (Test-Path $folder) {
        Write-Host "[X] Le dossier existe encore : $folder" -ForegroundColor Red
        $foldersStillExist = $true
    }
}
if (-not $foldersStillExist) {
    Write-Host "[OK] Tous les dossiers ont été supprimés." -ForegroundColor Green
}

# C. Vérification dans les programmes installés (Registre)
$regCheck = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*HopToDesk*" }
if ($regCheck) {
    Write-Host "[X] Des traces subsistent dans le Registre Windows." -ForegroundColor Red
} else {
    Write-Host "[OK] Aucune trace dans le Registre." -ForegroundColor Green
}