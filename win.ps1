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

Write-Host '[CyberTweak] Downloading...' -ForegroundColor Cyan
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# 1. the exe attached to the latest release, 2. the exe stored in the repo (main branch)
$sources = "https://github.com/$Repo/releases/latest/download/CyberTweak.exe",
           "https://github.com/$Repo/raw/main/CyberTweak.exe"
$ok = $false
foreach ($url in $sources) {
    try { Invoke-WebRequest $url -OutFile $exe -UseBasicParsing; $ok = $true; break } catch {}
}
if (-not $ok) {
    Write-Host "[CyberTweak] Download failed: no CyberTweak.exe found in the releases or the main branch of $Repo." -ForegroundColor Red
    return
}
Unblock-File $exe

Write-Host '[CyberTweak] Starting (confirm the admin prompt)...' -ForegroundColor Cyan
Start-Process $exe
