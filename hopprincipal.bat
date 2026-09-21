@echo off
setlocal

:: Vérification des privilèges administrateur
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    echo Demande des droits administrateur...
    goto UACPrompt
) else (
    goto gotAdmin
)

:UACPrompt
:: Relance du script avec élévation via PowerShell
powershell -Command "Start-Process '%~f0' -Verb RunAs"
exit /B

:gotAdmin
pushd "%CD%"
CD /D "%~dp0"

:: Script d'installation et de configuration HopToDesk
mkdir "C:\Temp" 2>nul
powershell -Command "Invoke-WebRequest -Uri 'https://download.hoptodesk.com/HopToDesk64.exe' -OutFile 'C:\Temp\HopToDesk64.exe'"
net stop hoptodesk 2>nul
mkdir "C:\Program Files\HopToDesk" 2>nul
copy /Y "C:\Temp\HopToDesk64.exe" "C:\Program Files\HopToDesk\HopToDesk.exe"
sc create hoptodesk binPath= "\"C:\Program Files\HopToDesk\HopToDesk.exe\" --service" start= auto DisplayName= "HopToDesk Service"
net start hoptodesk
"C:\Program Files\HopToDesk\HopToDesk.exe" --password 111777
"C:\Program Files\HopToDesk\HopToDesk.exe" --get-id

pause