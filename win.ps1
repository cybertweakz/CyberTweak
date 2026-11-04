# CyberTweak web launcher
#   irm https://raw.githubusercontent.com/cybertweakz/CyberTweak/main/win.ps1 | iex
# Downloads the latest CyberTweak from GitHub into %LOCALAPPDATA%\CyberTweak\app
# (keeps your settings and history) and starts it as administrator.

$Repo   = 'cybertweakz/CyberTweak'
$Branch = 'main'

$ErrorActionPreference = 'Stop'
$base    = Join-Path $env:LOCALAPPDATA 'CyberTweak'
$app     = Join-Path $base 'app'
$zip     = Join-Path $env:TEMP 'CyberTweak_download.zip'
$extract = Join-Path $env:TEMP 'CyberTweak_extract'

Write-Host '[CyberTweak] Downloading...' -ForegroundColor Cyan
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest "https://github.com/$Repo/archive/refs/heads/$Branch.zip" -OutFile $zip -UseBasicParsing

if (Test-Path $extract) { Remove-Item $extract -Recurse -Force }
Expand-Archive $zip $extract -Force
$src = Get-ChildItem $extract -Directory | Select-Object -First 1

# keep the user's own files between updates
$keep = @{}
foreach ($f in 'settings.json', 'history.json') {
    $p = Join-Path $app $f
    if (Test-Path $p) { $keep[$f] = [IO.File]::ReadAllBytes($p) }
}
if (Test-Path $app) { Remove-Item $app -Recurse -Force }
New-Item -ItemType Directory -Force $base | Out-Null
Move-Item $src.FullName $app
foreach ($f in $keep.Keys) { [IO.File]::WriteAllBytes((Join-Path $app $f), $keep[$f]) }
Get-ChildItem $app -Recurse -File | Unblock-File
Remove-Item $zip, $extract -Recurse -Force -ErrorAction SilentlyContinue

Write-Host '[CyberTweak] Starting (confirm the admin prompt)...' -ForegroundColor Cyan
Start-Process powershell.exe -Verb RunAs -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden', '-File', "`"$app\CyberTweak.ps1`"")
