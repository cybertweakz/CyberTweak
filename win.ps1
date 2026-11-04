# CyberTweak web launcher
#   irm https://raw.githubusercontent.com/cybertweakz/CyberTweak/main/win.ps1 | iex
# Downloads CyberTweak.exe from the latest GitHub release and starts it.
# The exe contains everything (scripts, languages, fonts, logos) and asks for admin itself.
# Your settings in %LOCALAPPDATA%\CyberTweak\app are kept between updates.

$Repo = 'cybertweakz/CyberTweak'

$ErrorActionPreference = 'Stop'
$base = Join-Path $env:LOCALAPPDATA 'CyberTweak'
$exe  = Join-Path $base 'CyberTweak.exe'
New-Item -ItemType Directory -Force $base | Out-Null

Write-Host '[CyberTweak] Downloading latest release...' -ForegroundColor Cyan
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
try {
    Invoke-WebRequest "https://github.com/$Repo/releases/latest/download/CyberTweak.exe" -OutFile $exe -UseBasicParsing
} catch {
    Write-Host "[CyberTweak] Download failed: no CyberTweak.exe in the latest release of $Repo." -ForegroundColor Red
    Write-Host "             $($_.Exception.Message)" -ForegroundColor DarkGray
    return
}
Unblock-File $exe

Write-Host '[CyberTweak] Starting (confirm the admin prompt)...' -ForegroundColor Cyan
Start-Process $exe
