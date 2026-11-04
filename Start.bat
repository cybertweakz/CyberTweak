@echo off
rem CyberTweak launcher - asks for admin rights, then opens the GUI.
rem Optional: Start.bat -DryRun  (only shows what would run, changes nothing)
cd /d "%~dp0"
start "" powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0CyberTweak.ps1" %*
