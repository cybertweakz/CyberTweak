# CyberTweak helper functions.
# Loaded by the GUI and by every background worker, so tweaks can use them.

$CT_Adv = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'

function Set-Reg {
    param([string]$Path, [string]$Name, $Value, [string]$Type = 'DWord')
    if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
}

function Remove-Reg {
    param([string]$Path, [string]$Name)
    if (Test-Path $Path) { Remove-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue }
}

function Get-Reg {
    param([string]$Path, [string]$Name)
    try { (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name } catch { $null }
}

function Test-Reg {
    param([string]$Path, [string]$Name, $Value)
    $v = Get-Reg $Path $Name
    ($null -ne $v) -and ("$v" -eq "$Value")
}

function Set-Svc {
    param([string]$Name, [string]$StartupType)
    $s = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if (-not $s) { Write-Output "Service $Name not found"; return }
    if ($StartupType -eq 'Disabled') { Stop-Service -Name $Name -Force -ErrorAction SilentlyContinue }
    Set-Service -Name $Name -StartupType $StartupType
    if ($StartupType -eq 'Automatic') { Start-Service -Name $Name -ErrorAction SilentlyContinue }
}

function Test-SvcDisabled {
    param([string]$Name)
    $s = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if (-not $s) { return $null }
    "$($s.StartType)" -eq 'Disabled'
}

function Remove-Bloat {
    param([string[]]$Names)
    foreach ($n in $Names) {
        Get-AppxPackage -AllUsers -Name $n -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Output "Removing $($_.Name)"
            Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue
        }
        Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like $n } | ForEach-Object {
            Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue | Out-Null
        }
    }
}

function Test-BloatRemoved {
    param([string[]]$Names)
    foreach ($n in $Names) { if (Get-AppxPackage -Name $n -ErrorAction SilentlyContinue) { return $false } }
    $true
}

function Open-StoreApp {
    param([string]$ProductId)
    Write-Output "Opening Microsoft Store page ($ProductId) - click Install there."
    Start-Process "ms-windows-store://pdp/?ProductId=$ProductId"
}

function Get-FolderSizeMB {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return 0 }
    $sum = (Get-ChildItem $Path -Recurse -Force -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
    [math]::Round(($sum / 1MB), 1)
}

function Clear-Folder {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return }
    $before = Get-FolderSizeMB $Path
    Get-ChildItem $Path -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    $after = Get-FolderSizeMB $Path
    Write-Output ("{0}: {1} MB freed" -f $Path, [math]::Round($before - $after, 1))
}

function Test-Winget {
    [bool](Get-Command winget -ErrorAction SilentlyContinue)
}

function Enable-Feat {
    param([string[]]$Names)
    foreach ($n in $Names) {
        Write-Output "Enabling feature $n"
        Enable-WindowsOptionalFeature -Online -FeatureName $n -All -NoRestart -ErrorAction Stop | Out-Null
    }
}

function Disable-Feat {
    param([string[]]$Names)
    foreach ($n in $Names) {
        Write-Output "Disabling feature $n"
        Disable-WindowsOptionalFeature -Online -FeatureName $n -NoRestart -ErrorAction SilentlyContinue | Out-Null
    }
}

function Test-Feat {
    param([string]$Name)
    "$((Get-WindowsOptionalFeature -Online -FeatureName $Name -ErrorAction Stop).State)" -eq 'Enabled'
}

function Set-DnsAll {
    param([string[]]$Servers)
    foreach ($a in (Get-NetAdapter | Where-Object { $_.Status -eq 'Up' })) {
        if ($Servers) {
            Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ServerAddresses $Servers
            Write-Output "$($a.Name): $($Servers -join ', ')"
        } else {
            Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ResetServerAddresses
            Write-Output "$($a.Name): DHCP"
        }
    }
    Clear-DnsClientCache
}

function Test-Dns {
    param([string]$Primary)
    [bool](Get-DnsClientServerAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.ServerAddresses -contains $Primary })
}

function Set-UpdateTasks {
    param([bool]$Enabled)
    foreach ($p in '\Microsoft\Windows\WindowsUpdate\', '\Microsoft\Windows\UpdateOrchestrator\') {
        Get-ScheduledTask -TaskPath $p -ErrorAction SilentlyContinue | ForEach-Object {
            if ($Enabled) { Enable-ScheduledTask -InputObject $_ -ErrorAction SilentlyContinue | Out-Null }
            else { Disable-ScheduledTask -InputObject $_ -ErrorAction SilentlyContinue | Out-Null }
        }
    }
}

function Get-DownloadFile {
    param([string]$Url, [string]$Name)
    $dir = Join-Path $env:LOCALAPPDATA 'CyberTweak'
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
    $file = Join-Path $dir $Name
    Invoke-WebRequest -Uri $Url -OutFile $file -UseBasicParsing
    $file
}
