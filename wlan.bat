@echo off
chcp 65001 > nul
echo ===================================================
echo             INFORMATIONS RESEAU EN COURS
echo ===================================================
echo.

:: Récupérer le nom du Wi-Fi (SSID)
set "ssid="
for /f "tokens=2 delims=:" %%a in ('netsh wlan show interfaces ^| findstr /c:" SSID"') do (
    set "ssid=%%a"
)

:: Supprimer l'espace au début du SSID
if defined ssid set "ssid=%ssid:~1%"

if not defined ssid (
    echo [!] Aucun réseau Wi-Fi connecté.
    echo.
    pause
    exit /b
)

echo [-] Wi-Fi connecte : %ssid%

:: Récupérer le mot de passe Wi-Fi
for /f "tokens=2 delims=:" %%a in ('netsh wlan show profile name^="%ssid%" key^=clear ^| findstr /c:"Contenu de la clé" /c:"Key Content"') do (
    set "wifipass=%%a"
)

if defined wifipass (
    set "wifipass=%wifipass:~1%"
    echo [-] Mot de passe   : %wifipass%
) else (
    echo [-] Mot de passe   : Impossible de récupérer la clé ou réseau ouvert
)

echo.
echo ---------------------------------------------------

:: Récupérer l'adresse IP v4
echo [-] Adresse IP (IPv4) :
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
    echo    %%a
)

echo.
echo ===================================================
pause