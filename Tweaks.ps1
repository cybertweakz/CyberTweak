# CyberTweak tweak definitions.
# Texts (name, explanation, pro, contra) live in lang\<code>.json under "tweaks".<Id>.
#   Cat      : Performance | Gaming | Privacy | Debloat | Cleanup
#   Risk     : Safe | Medium | Advanced
#   Needs    : $null | 'explorer' (auto restart) | 'signout' | 'reboot'
#   MinBuild : minimum Windows build (0 = any)
#   Tech     : what exactly is changed (shown as-is, language neutral)
#   Check    : read-only, returns $true when already applied, $false when not, $null when unknown
#   Apply / Undo : scriptblocks ($null Undo = cannot be undone)

$CT_Adv = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'

$Tweaks = @(

# ---------------------------------------------------------------- PERFORMANCE
@{ Id='perf_power_plan'; Cat='Performance'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61`npowercfg -changename <guid> ""CyberTweak Ultimate""`npowercfg -setactive <guid>"
   Check={ "$(powercfg /getactivescheme)" -match 'CyberTweak' }
   Apply={
     $out = powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
     $guid = [regex]::Match("$out", '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}').Value
     if (-not $guid) { throw "Could not create power plan: $out" }
     powercfg -changename $guid "CyberTweak Ultimate" | Out-Null
     powercfg -setactive $guid
   }
   Undo={
     powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e
     powercfg /list | Where-Object { $_ -match 'CyberTweak' } | ForEach-Object {
       $g = [regex]::Match($_, '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}').Value
       if ($g) { powercfg -delete $g }
     }
   } }

@{ Id='perf_hibernate_off'; Cat='Performance'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="powercfg -h off`nHKLM\SYSTEM\CurrentControlSet\Control\Power  HibernateEnabled = 0"
   Check={ Test-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' 'HibernateEnabled' 0 }
   Apply={ powercfg -h off }
   Undo ={ powercfg -h on } }

@{ Id='perf_visual_fx'; Cat='Performance'; Risk='Safe'; Needs='signout'; MinBuild=0
   Tech="HKCU\...\Explorer\VisualEffects  VisualFXSetting = 2`nHKCU\Control Panel\Desktop  UserPreferencesMask = 90 12 03 80 10 00 00 00`nHKCU\Control Panel\Desktop\WindowMetrics  MinAnimate = 0`nHKCU\...\Explorer\Advanced  TaskbarAnimations = 0`nHKCU\Software\Microsoft\Windows\DWM  EnableAeroPeek = 0`nFontSmoothing = 2 (ClearType stays on)"
   Check={ Test-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' 'VisualFXSetting' 2 }
   Apply={
     Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' 'VisualFXSetting' 2
     Set-Reg 'HKCU:\Control Panel\Desktop' 'UserPreferencesMask' ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) 'Binary'
     Set-Reg 'HKCU:\Control Panel\Desktop' 'FontSmoothing' '2' 'String'
     Set-Reg 'HKCU:\Control Panel\Desktop\WindowMetrics' 'MinAnimate' '0' 'String'
     Set-Reg $CT_Adv 'TaskbarAnimations' 0
     Set-Reg 'HKCU:\Software\Microsoft\Windows\DWM' 'EnableAeroPeek' 0
   }
   Undo={
     Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' 'VisualFXSetting' 0
     Set-Reg 'HKCU:\Control Panel\Desktop' 'UserPreferencesMask' ([byte[]](0x9E,0x1E,0x07,0x80,0x12,0x00,0x00,0x00)) 'Binary'
     Set-Reg 'HKCU:\Control Panel\Desktop\WindowMetrics' 'MinAnimate' '1' 'String'
     Set-Reg $CT_Adv 'TaskbarAnimations' 1
     Set-Reg 'HKCU:\Software\Microsoft\Windows\DWM' 'EnableAeroPeek' 1
   } }

@{ Id='perf_menu_delay'; Cat='Performance'; Risk='Safe'; Needs='signout'; MinBuild=0
   Tech="HKCU\Control Panel\Desktop  MenuShowDelay = ""0""  (default ""400"")"
   Check={ Test-Reg 'HKCU:\Control Panel\Desktop' 'MenuShowDelay' '0' }
   Apply={ Set-Reg 'HKCU:\Control Panel\Desktop' 'MenuShowDelay' '0' 'String' }
   Undo ={ Set-Reg 'HKCU:\Control Panel\Desktop' 'MenuShowDelay' '400' 'String' } }

@{ Id='perf_startup_delay'; Cat='Performance'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize  StartupDelayInMSec = 0"
   Check={ Test-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize' 'StartupDelayInMSec' 0 }
   Apply={ Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize' 'StartupDelayInMSec' 0 }
   Undo ={ Remove-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize' 'StartupDelayInMSec' } }

@{ Id='perf_bg_apps'; Cat='Performance'; Risk='Medium'; Needs=$null; MinBuild=0
   Tech="HKCU\...\CurrentVersion\BackgroundAccessApplications  GlobalUserDisabled = 1`nHKCU\...\CurrentVersion\Search  BackgroundAppGlobalToggle = 0"
   Check={ Test-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' 'GlobalUserDisabled' 1 }
   Apply={
     Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' 'GlobalUserDisabled' 1
     Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'BackgroundAppGlobalToggle' 0
   }
   Undo={
     Remove-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' 'GlobalUserDisabled'
     Remove-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'BackgroundAppGlobalToggle'
   } }

@{ Id='perf_power_throttling'; Cat='Performance'; Risk='Safe'; Needs='reboot'; MinBuild=0
   Tech="HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling  PowerThrottlingOff = 1"
   Check={ Test-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling' 'PowerThrottlingOff' 1 }
   Apply={ Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling' 'PowerThrottlingOff' 1 }
   Undo ={ Remove-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling' 'PowerThrottlingOff' } }

@{ Id='perf_search_index'; Cat='Performance'; Risk='Medium'; Needs=$null; MinBuild=0
   Tech="Service WSearch (Windows Search): Stop + StartupType = Disabled"
   Check={ Test-SvcDisabled 'WSearch' }
   Apply={ Set-Svc 'WSearch' 'Disabled' }
   Undo ={ Set-Svc 'WSearch' 'Automatic' } }

@{ Id='perf_sysmain'; Cat='Performance'; Risk='Medium'; Needs=$null; MinBuild=0
   Tech="Service SysMain (Superfetch): Stop + StartupType = Disabled"
   Check={ Test-SvcDisabled 'SysMain' }
   Apply={ Set-Svc 'SysMain' 'Disabled' }
   Undo ={ Set-Svc 'SysMain' 'Automatic' } }

# ---------------------------------------------------------------- GAMING
@{ Id='game_mode'; Cat='Gaming'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="HKCU\Software\Microsoft\GameBar  AutoGameModeEnabled = 1, AllowAutoGameMode = 1"
   Check={ Test-Reg 'HKCU:\Software\Microsoft\GameBar' 'AutoGameModeEnabled' 1 }
   Apply={
     Set-Reg 'HKCU:\Software\Microsoft\GameBar' 'AutoGameModeEnabled' 1
     Set-Reg 'HKCU:\Software\Microsoft\GameBar' 'AllowAutoGameMode' 1
   }
   Undo={
     Remove-Reg 'HKCU:\Software\Microsoft\GameBar' 'AutoGameModeEnabled'
     Remove-Reg 'HKCU:\Software\Microsoft\GameBar' 'AllowAutoGameMode'
   } }

@{ Id='game_hags'; Cat='Gaming'; Risk='Safe'; Needs='reboot'; MinBuild=19041
   Tech="HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers  HwSchMode = 2  (1 = off)"
   Check={ Test-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'HwSchMode' 2 }
   Apply={ Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'HwSchMode' 2 }
   Undo ={ Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'HwSchMode' 1 } }

@{ Id='game_dvr_off'; Cat='Gaming'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="HKCU\System\GameConfigStore  GameDVR_Enabled = 0`nHKCU\...\CurrentVersion\GameDVR  AppCaptureEnabled = 0`nHKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR  AllowGameDVR = 0"
   Check={ Test-Reg 'HKCU:\System\GameConfigStore' 'GameDVR_Enabled' 0 }
   Apply={
     Set-Reg 'HKCU:\System\GameConfigStore' 'GameDVR_Enabled' 0
     Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR' 'AppCaptureEnabled' 0
     Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' 'AllowGameDVR' 0
   }
   Undo={
     Set-Reg 'HKCU:\System\GameConfigStore' 'GameDVR_Enabled' 1
     Remove-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR' 'AppCaptureEnabled'
     Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' 'AllowGameDVR'
   } }

@{ Id='game_mouse_accel'; Cat='Gaming'; Risk='Safe'; Needs='signout'; MinBuild=0
   Tech="HKCU\Control Panel\Mouse  MouseSpeed = ""0"", MouseThreshold1 = ""0"", MouseThreshold2 = ""0""`n(default 1 / 6 / 10)"
   Check={ Test-Reg 'HKCU:\Control Panel\Mouse' 'MouseSpeed' '0' }
   Apply={
     Set-Reg 'HKCU:\Control Panel\Mouse' 'MouseSpeed' '0' 'String'
     Set-Reg 'HKCU:\Control Panel\Mouse' 'MouseThreshold1' '0' 'String'
     Set-Reg 'HKCU:\Control Panel\Mouse' 'MouseThreshold2' '0' 'String'
   }
   Undo={
     Set-Reg 'HKCU:\Control Panel\Mouse' 'MouseSpeed' '1' 'String'
     Set-Reg 'HKCU:\Control Panel\Mouse' 'MouseThreshold1' '6' 'String'
     Set-Reg 'HKCU:\Control Panel\Mouse' 'MouseThreshold2' '10' 'String'
   } }

@{ Id='game_nagle'; Cat='Gaming'; Risk='Safe'; Needs='reboot'; MinBuild=0
   Tech="For every network adapter with an IP:`nHKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{id}`n  TcpAckFrequency = 1, TCPNoDelay = 1"
   Check={
     $hit = $false
     Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' | ForEach-Object {
       if ((Get-Reg $_.PSPath 'TcpAckFrequency') -eq 1) { $hit = $true }
     }
     $hit
   }
   Apply={
     Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' | ForEach-Object {
       $p = Get-ItemProperty $_.PSPath
       if ($p.DhcpIPAddress -or $p.IPAddress) {
         Set-Reg $_.PSPath 'TcpAckFrequency' 1
         Set-Reg $_.PSPath 'TCPNoDelay' 1
         Write-Output "Adapter $($_.PSChildName)"
       }
     }
   }
   Undo={
     Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' | ForEach-Object {
       Remove-Reg $_.PSPath 'TcpAckFrequency'
       Remove-Reg $_.PSPath 'TCPNoDelay'
     }
   } }

@{ Id='game_mmcss_network'; Cat='Gaming'; Risk='Safe'; Needs='reboot'; MinBuild=0
   Tech="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile`n  NetworkThrottlingIndex = 0xFFFFFFFF  (default 10)`n  SystemResponsiveness = 10  (default 20)"
   Check={ Test-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' 'NetworkThrottlingIndex' -1 }
   Apply={
     Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' 'NetworkThrottlingIndex' 0xffffffff
     Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' 'SystemResponsiveness' 10
   }
   Undo={
     Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' 'NetworkThrottlingIndex' 10
     Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' 'SystemResponsiveness' 20
   } }

@{ Id='game_mmcss_games'; Cat='Gaming'; Risk='Safe'; Needs='reboot'; MinBuild=0
   Tech="HKLM\...\Multimedia\SystemProfile\Tasks\Games`n  GPU Priority = 8, Priority = 6 (default 2)`n  Scheduling Category = High (default Medium)`n  SFIO Priority = High (default Normal)"
   Check={ Test-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games' 'Priority' 6 }
   Apply={
     $k = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games'
     Set-Reg $k 'GPU Priority' 8
     Set-Reg $k 'Priority' 6
     Set-Reg $k 'Scheduling Category' 'High' 'String'
     Set-Reg $k 'SFIO Priority' 'High' 'String'
   }
   Undo={
     $k = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games'
     Set-Reg $k 'GPU Priority' 8
     Set-Reg $k 'Priority' 2
     Set-Reg $k 'Scheduling Category' 'Medium' 'String'
     Set-Reg $k 'SFIO Priority' 'Normal' 'String'
   } }

@{ Id='game_fso_off'; Cat='Gaming'; Risk='Medium'; Needs='signout'; MinBuild=0
   Tech="HKCU\System\GameConfigStore`n  GameDVR_FSEBehaviorMode = 2, GameDVR_FSEBehavior = 2`n  GameDVR_HonorUserFSEBehaviorMode = 1`n  GameDVR_DXGIHonorFSEWindowsCompatible = 1"
   Check={ Test-Reg 'HKCU:\System\GameConfigStore' 'GameDVR_FSEBehaviorMode' 2 }
   Apply={
     Set-Reg 'HKCU:\System\GameConfigStore' 'GameDVR_FSEBehaviorMode' 2
     Set-Reg 'HKCU:\System\GameConfigStore' 'GameDVR_FSEBehavior' 2
     Set-Reg 'HKCU:\System\GameConfigStore' 'GameDVR_HonorUserFSEBehaviorMode' 1
     Set-Reg 'HKCU:\System\GameConfigStore' 'GameDVR_DXGIHonorFSEWindowsCompatible' 1
   }
   Undo={
     Set-Reg 'HKCU:\System\GameConfigStore' 'GameDVR_FSEBehaviorMode' 0
     Remove-Reg 'HKCU:\System\GameConfigStore' 'GameDVR_FSEBehavior'
     Set-Reg 'HKCU:\System\GameConfigStore' 'GameDVR_HonorUserFSEBehaviorMode' 0
     Set-Reg 'HKCU:\System\GameConfigStore' 'GameDVR_DXGIHonorFSEWindowsCompatible' 0
   } }

@{ Id='game_sticky_keys'; Cat='Gaming'; Risk='Safe'; Needs='signout'; MinBuild=0
   Tech="HKCU\Control Panel\Accessibility\StickyKeys  Flags = ""506""  (default ""510"")"
   Check={ Test-Reg 'HKCU:\Control Panel\Accessibility\StickyKeys' 'Flags' '506' }
   Apply={ Set-Reg 'HKCU:\Control Panel\Accessibility\StickyKeys' 'Flags' '506' 'String' }
   Undo ={ Set-Reg 'HKCU:\Control Panel\Accessibility\StickyKeys' 'Flags' '510' 'String' } }

# ---------------------------------------------------------------- PRIVACY
@{ Id='priv_telemetry'; Cat='Privacy'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection  AllowTelemetry = 0`nHKLM\...\CurrentVersion\Policies\DataCollection  AllowTelemetry = 0`nOnline speech, inking + typing personalization, Start_TrackProgs = 0`nServices DiagTrack, dmwappushservice, WerSvc = Disabled`nDefender sample submission off, POWERSHELL_TELEMETRY_OPTOUT = 1"
   Check={ Test-SvcDisabled 'DiagTrack' }
   Apply={
     Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 0
     Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' 'AllowTelemetry' 0
     Set-Reg 'HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy' 'HasAccepted' 0
     Set-Reg 'HKCU:\Software\Microsoft\Input\TIPC' 'Enabled' 0
     Set-Reg 'HKCU:\Software\Microsoft\InputPersonalization' 'RestrictImplicitInkCollection' 1
     Set-Reg 'HKCU:\Software\Microsoft\InputPersonalization' 'RestrictImplicitTextCollection' 1
     Set-Reg 'HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore' 'HarvestContacts' 0
     Set-Reg 'HKCU:\Software\Microsoft\Personalization\Settings' 'AcceptedPrivacyPolicy' 0
     Set-Reg $CT_Adv 'Start_TrackProgs' 0
     Set-Svc 'DiagTrack' 'Disabled'
     Set-Svc 'dmwappushservice' 'Disabled'
     Set-Svc 'WerSvc' 'Disabled'
     try { Set-MpPreference -SubmitSamplesConsent 2 -ErrorAction Stop } catch { Write-Output 'Defender not available - sample submission unchanged' }
     [Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', '1', 'Machine')
   }
   Undo={
     Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry'
     Remove-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' 'AllowTelemetry'
     Remove-Reg 'HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy' 'HasAccepted'
     Remove-Reg 'HKCU:\Software\Microsoft\Input\TIPC' 'Enabled'
     Remove-Reg 'HKCU:\Software\Microsoft\InputPersonalization' 'RestrictImplicitInkCollection'
     Remove-Reg 'HKCU:\Software\Microsoft\InputPersonalization' 'RestrictImplicitTextCollection'
     Remove-Reg 'HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore' 'HarvestContacts'
     Remove-Reg $CT_Adv 'Start_TrackProgs'
     Set-Svc 'DiagTrack' 'Automatic'
     Set-Svc 'dmwappushservice' 'Manual'
     Set-Svc 'WerSvc' 'Manual'
     try { Set-MpPreference -SubmitSamplesConsent 1 -ErrorAction Stop } catch {}
     [Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', $null, 'Machine')
   } }

@{ Id='priv_ad_id'; Cat='Privacy'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="HKCU\...\CurrentVersion\AdvertisingInfo  Enabled = 0`nHKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo  DisabledByGroupPolicy = 1"
   Check={ Test-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' 'Enabled' 0 }
   Apply={
     Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' 'Enabled' 0
     Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo' 'DisabledByGroupPolicy' 1
   }
   Undo={
     Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' 'Enabled' 1
     Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo' 'DisabledByGroupPolicy'
   } }

@{ Id='priv_activity'; Cat='Privacy'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="HKLM\SOFTWARE\Policies\Microsoft\Windows\System`n  EnableActivityFeed = 0, PublishUserActivities = 0, UploadUserActivities = 0"
   Check={ Test-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'PublishUserActivities' 0 }
   Apply={
     foreach ($n in 'EnableActivityFeed','PublishUserActivities','UploadUserActivities') { Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' $n 0 }
   }
   Undo={
     foreach ($n in 'EnableActivityFeed','PublishUserActivities','UploadUserActivities') { Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' $n }
   } }

@{ Id='priv_location'; Cat='Privacy'; Risk='Medium'; Needs=$null; MinBuild=0
   Tech="HKLM\...\CapabilityAccessManager\ConsentStore\location  Value = ""Deny""  (default ""Allow"")"
   Check={ Test-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location' 'Value' 'Deny' }
   Apply={ Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location' 'Value' 'Deny' 'String' }
   Undo ={ Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location' 'Value' 'Allow' 'String' } }

@{ Id='priv_tailored'; Cat='Privacy'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="HKCU\...\CurrentVersion\Privacy  TailoredExperiencesWithDiagnosticDataEnabled = 0`nHKCU\Software\Policies\Microsoft\Windows\CloudContent  DisableTailoredExperiencesWithDiagnosticData = 1"
   Check={ Test-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' 'TailoredExperiencesWithDiagnosticDataEnabled' 0 }
   Apply={
     Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' 'TailoredExperiencesWithDiagnosticDataEnabled' 0
     Set-Reg 'HKCU:\Software\Policies\Microsoft\Windows\CloudContent' 'DisableTailoredExperiencesWithDiagnosticData' 1
   }
   Undo={
     Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' 'TailoredExperiencesWithDiagnosticDataEnabled' 1
     Remove-Reg 'HKCU:\Software\Policies\Microsoft\Windows\CloudContent' 'DisableTailoredExperiencesWithDiagnosticData'
   } }

@{ Id='priv_bing_search'; Cat='Privacy'; Risk='Safe'; Needs='explorer'; MinBuild=0
   Tech="HKCU\...\CurrentVersion\Search  BingSearchEnabled = 0`nHKCU\Software\Policies\Microsoft\Windows\Explorer  DisableSearchBoxSuggestions = 1"
   Check={ Test-Reg 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' 'DisableSearchBoxSuggestions' 1 }
   Apply={
     Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'BingSearchEnabled' 0
     Set-Reg 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' 'DisableSearchBoxSuggestions' 1
   }
   Undo={
     Remove-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'BingSearchEnabled'
     Remove-Reg 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' 'DisableSearchBoxSuggestions'
   } }

@{ Id='priv_copilot'; Cat='Privacy'; Risk='Safe'; Needs='explorer'; MinBuild=22000
   Tech="HKCU + HKLM\Software\Policies\Microsoft\Windows\WindowsCopilot  TurnOffWindowsCopilot = 1`nHKCU\...\Explorer\Advanced  ShowCopilotButton = 0"
   Check={ Test-Reg 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot' 1 }
   Apply={
     Set-Reg 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot' 1
     Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot' 1
     Set-Reg $CT_Adv 'ShowCopilotButton' 0
   }
   Undo={
     Remove-Reg 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot'
     Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot'
     Remove-Reg $CT_Adv 'ShowCopilotButton'
   } }

@{ Id='priv_recall'; Cat='Privacy'; Risk='Safe'; Needs='reboot'; MinBuild=26100
   Tech="HKLM + HKCU\Software\Policies\Microsoft\Windows\WindowsAI  DisableAIDataAnalysis = 1`nHKLM\...\WindowsAI  AllowRecallEnablement = 0"
   Check={ Test-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableAIDataAnalysis' 1 }
   Apply={
     Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableAIDataAnalysis' 1
     Set-Reg 'HKCU:\Software\Policies\Microsoft\Windows\WindowsAI' 'DisableAIDataAnalysis' 1
     Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'AllowRecallEnablement' 0
   }
   Undo={
     Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableAIDataAnalysis'
     Remove-Reg 'HKCU:\Software\Policies\Microsoft\Windows\WindowsAI' 'DisableAIDataAnalysis'
     Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'AllowRecallEnablement'
   } }

@{ Id='priv_feedback'; Cat='Privacy'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="HKCU\Software\Microsoft\Siuf\Rules  NumberOfSIUFInPeriod = 0`nHKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection  DoNotShowFeedbackNotifications = 1"
   Check={ Test-Reg 'HKCU:\Software\Microsoft\Siuf\Rules' 'NumberOfSIUFInPeriod' 0 }
   Apply={
     Set-Reg 'HKCU:\Software\Microsoft\Siuf\Rules' 'NumberOfSIUFInPeriod' 0
     Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'DoNotShowFeedbackNotifications' 1
   }
   Undo={
     Remove-Reg 'HKCU:\Software\Microsoft\Siuf\Rules' 'NumberOfSIUFInPeriod'
     Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'DoNotShowFeedbackNotifications'
   } }

@{ Id='priv_start_ads'; Cat='Privacy'; Risk='Safe'; Needs='explorer'; MinBuild=0
   Tech="HKCU\...\CurrentVersion\ContentDeliveryManager`n  SystemPaneSuggestionsEnabled, SilentInstalledAppsEnabled, SoftLandingEnabled,`n  SubscribedContent-338388/338389/353694/353696Enabled = 0`nHKCU\...\Explorer\Advanced  Start_IrisRecommendations = 0"
   Check={ Test-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SilentInstalledAppsEnabled' 0 }
   Apply={
     $k = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
     foreach ($n in 'SystemPaneSuggestionsEnabled','SilentInstalledAppsEnabled','SoftLandingEnabled','SubscribedContent-338388Enabled','SubscribedContent-338389Enabled','SubscribedContent-353694Enabled','SubscribedContent-353696Enabled') { Set-Reg $k $n 0 }
     Set-Reg $CT_Adv 'Start_IrisRecommendations' 0
   }
   Undo={
     $k = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
     foreach ($n in 'SystemPaneSuggestionsEnabled','SilentInstalledAppsEnabled','SoftLandingEnabled','SubscribedContent-338388Enabled','SubscribedContent-338389Enabled','SubscribedContent-353694Enabled','SubscribedContent-353696Enabled') { Set-Reg $k $n 1 }
     Remove-Reg $CT_Adv 'Start_IrisRecommendations'
   } }

@{ Id='priv_widgets'; Cat='Privacy'; Risk='Safe'; Needs='explorer'; MinBuild=0
   Tech="HKLM\SOFTWARE\Policies\Microsoft\Dsh  AllowNewsAndInterests = 0  (Windows 11 widgets)`nHKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds  EnableFeeds = 0  (Windows 10 news)"
   Check={ Test-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh' 'AllowNewsAndInterests' 0 }
   Apply={
     Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh' 'AllowNewsAndInterests' 0
     Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds' 'EnableFeeds' 0
   }
   Undo={
     Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh' 'AllowNewsAndInterests'
     Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds' 'EnableFeeds'
   } }

# ---------------------------------------------------------------- DEBLOAT
@{ Id='bloat_clipchamp'; Cat='Debloat'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="Remove-AppxPackage -AllUsers  Clipchamp.Clipchamp`nUndo: Microsoft Store 9P1J8S7CCWWT"
   Check={ Test-BloatRemoved 'Clipchamp.Clipchamp' }
   Apply={ Remove-Bloat 'Clipchamp.Clipchamp' }
   Undo ={ Open-StoreApp '9P1J8S7CCWWT' } }

@{ Id='bloat_news'; Cat='Debloat'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="Remove-AppxPackage -AllUsers  Microsoft.BingNews`nUndo: Microsoft Store 9WZDNCRFHVFW"
   Check={ Test-BloatRemoved 'Microsoft.BingNews' }
   Apply={ Remove-Bloat 'Microsoft.BingNews' }
   Undo ={ Open-StoreApp '9WZDNCRFHVFW' } }

@{ Id='bloat_weather'; Cat='Debloat'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="Remove-AppxPackage -AllUsers  Microsoft.BingWeather`nUndo: Microsoft Store 9WZDNCRFJ3Q2"
   Check={ Test-BloatRemoved 'Microsoft.BingWeather' }
   Apply={ Remove-Bloat 'Microsoft.BingWeather' }
   Undo ={ Open-StoreApp '9WZDNCRFJ3Q2' } }

@{ Id='bloat_solitaire'; Cat='Debloat'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="Remove-AppxPackage -AllUsers  Microsoft.MicrosoftSolitaireCollection`nUndo: Microsoft Store 9WZDNCRFHWD2"
   Check={ Test-BloatRemoved 'Microsoft.MicrosoftSolitaireCollection' }
   Apply={ Remove-Bloat 'Microsoft.MicrosoftSolitaireCollection' }
   Undo ={ Open-StoreApp '9WZDNCRFHWD2' } }

@{ Id='bloat_teams'; Cat='Debloat'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="Remove-AppxPackage -AllUsers  MicrosoftTeams, MSTeams`nUndo: Microsoft Store (search: Teams)"
   Check={ Test-BloatRemoved 'MicrosoftTeams','MSTeams' }
   Apply={ Remove-Bloat 'MicrosoftTeams','MSTeams' }
   Undo ={ Start-Process 'ms-windows-store://search/?query=Microsoft%20Teams' } }

@{ Id='bloat_gethelp'; Cat='Debloat'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="Remove-AppxPackage -AllUsers  Microsoft.GetHelp, Microsoft.Getstarted (Tips)`nUndo: Microsoft Store 9PKDZBMV1H3T"
   Check={ Test-BloatRemoved 'Microsoft.GetHelp','Microsoft.Getstarted' }
   Apply={ Remove-Bloat 'Microsoft.GetHelp','Microsoft.Getstarted' }
   Undo ={ Open-StoreApp '9PKDZBMV1H3T' } }

@{ Id='bloat_feedbackhub'; Cat='Debloat'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="Remove-AppxPackage -AllUsers  Microsoft.WindowsFeedbackHub`nUndo: Microsoft Store 9NBLGGH4R32N"
   Check={ Test-BloatRemoved 'Microsoft.WindowsFeedbackHub' }
   Apply={ Remove-Bloat 'Microsoft.WindowsFeedbackHub' }
   Undo ={ Open-StoreApp '9NBLGGH4R32N' } }

@{ Id='bloat_officehub'; Cat='Debloat'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="Remove-AppxPackage -AllUsers  Microsoft.MicrosoftOfficeHub (Microsoft 365 / Office app)`nUndo: Microsoft Store (search: Microsoft 365)"
   Check={ Test-BloatRemoved 'Microsoft.MicrosoftOfficeHub' }
   Apply={ Remove-Bloat 'Microsoft.MicrosoftOfficeHub' }
   Undo ={ Start-Process 'ms-windows-store://search/?query=Microsoft%20365' } }

@{ Id='bloat_copilot'; Cat='Debloat'; Risk='Safe'; Needs=$null; MinBuild=22000
   Tech="Remove-AppxPackage -AllUsers  Microsoft.Copilot, Microsoft.Windows.Ai.Copilot.Provider`nUndo: Microsoft Store (search: Copilot)"
   Check={ Test-BloatRemoved 'Microsoft.Copilot' }
   Apply={ Remove-Bloat 'Microsoft.Copilot','Microsoft.Windows.Ai.Copilot.Provider' }
   Undo ={ Start-Process 'ms-windows-store://search/?query=Copilot' } }

@{ Id='bloat_phonelink'; Cat='Debloat'; Risk='Medium'; Needs=$null; MinBuild=0
   Tech="Remove-AppxPackage -AllUsers  Microsoft.YourPhone (Phone Link)`nUndo: Microsoft Store (search: Phone Link)"
   Check={ Test-BloatRemoved 'Microsoft.YourPhone' }
   Apply={ Remove-Bloat 'Microsoft.YourPhone' }
   Undo ={ Start-Process 'ms-windows-store://search/?query=Phone%20Link' } }

@{ Id='bloat_xbox'; Cat='Debloat'; Risk='Medium'; Needs=$null; MinBuild=0
   Tech="Remove-AppxPackage -AllUsers  Microsoft.GamingApp, Microsoft.XboxApp, Microsoft.XboxGamingOverlay`nUndo: Microsoft Store 9MV0B5HZVK9Z (Xbox) + 9NZKPSTSNW4P (Game Bar)"
   Check={ Test-BloatRemoved 'Microsoft.GamingApp','Microsoft.XboxGamingOverlay' }
   Apply={ Remove-Bloat 'Microsoft.GamingApp','Microsoft.XboxApp','Microsoft.XboxGamingOverlay' }
   Undo ={ Open-StoreApp '9MV0B5HZVK9Z'; Open-StoreApp '9NZKPSTSNW4P' } }

@{ Id='bloat_onedrive'; Cat='Debloat'; Risk='Medium'; Needs=$null; MinBuild=0
   Tech="HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive  DisableFileSyncNGSC = 1`nStop-Process OneDrive`nHKCU\...\CurrentVersion\Run  remove 'OneDrive'"
   Check={ Test-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' 'DisableFileSyncNGSC' 1 }
   Apply={
     Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' 'DisableFileSyncNGSC' 1
     Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
     Remove-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' 'OneDrive'
   }
   Undo={
     Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' 'DisableFileSyncNGSC'
     $exe = @("$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe", "$env:ProgramFiles\Microsoft OneDrive\OneDrive.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
     if ($exe) { Start-Process $exe } else { Write-Output 'OneDrive.exe not found - install it from microsoft.com/onedrive' }
   } }

@{ Id='ui_classic_menu'; Cat='Debloat'; Risk='Safe'; Needs='explorer'; MinBuild=22000
   Tech="HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32  (Default) = """""
   Check={ Test-Path 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32' }
   Apply={
     New-Item -Path 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32' -Force | Out-Null
     Set-ItemProperty -Path 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32' -Name '(Default)' -Value ''
   }
   Undo={ Remove-Item -Path 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}' -Recurse -Force -ErrorAction SilentlyContinue } }

@{ Id='ui_file_ext'; Cat='Debloat'; Risk='Safe'; Needs='explorer'; MinBuild=0
   Tech="HKCU\...\Explorer\Advanced  HideFileExt = 0"
   Check={ Test-Reg $CT_Adv 'HideFileExt' 0 }
   Apply={ Set-Reg $CT_Adv 'HideFileExt' 0 }
   Undo ={ Set-Reg $CT_Adv 'HideFileExt' 1 } }

@{ Id='ui_end_task'; Cat='Debloat'; Risk='Safe'; Needs='explorer'; MinBuild=22631
   Tech="HKCU\...\Explorer\Advanced\TaskbarDeveloperSettings  TaskbarEndTask = 1"
   Check={ Test-Reg "$CT_Adv\TaskbarDeveloperSettings" 'TaskbarEndTask' 1 }
   Apply={ Set-Reg "$CT_Adv\TaskbarDeveloperSettings" 'TaskbarEndTask' 1 }
   Undo ={ Remove-Reg "$CT_Adv\TaskbarDeveloperSettings" 'TaskbarEndTask' } }

# ---------------------------------------------------------------- CLEANUP (cannot be undone)
@{ Id='clean_temp'; Cat='Cleanup'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="Remove-Item -Recurse -Force  %TEMP%\*  and  C:\Windows\Temp\*`n(files in use are skipped)"
   Check=$null
   Apply={ Clear-Folder $env:TEMP; Clear-Folder "$env:SystemRoot\Temp" }
   Undo =$null }

@{ Id='clean_wu_cache'; Cat='Cleanup'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="Stop-Service wuauserv, bits`nRemove-Item C:\Windows\SoftwareDistribution\Download\*`nStart-Service wuauserv, bits"
   Check=$null
   Apply={
     Stop-Service wuauserv, bits -Force -ErrorAction SilentlyContinue
     Clear-Folder "$env:SystemRoot\SoftwareDistribution\Download"
     Start-Service wuauserv, bits -ErrorAction SilentlyContinue
   }
   Undo =$null }

@{ Id='clean_dns'; Cat='Cleanup'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="Clear-DnsClientCache  (= ipconfig /flushdns)"
   Check=$null
   Apply={ Clear-DnsClientCache; Write-Output 'DNS cache cleared' }
   Undo =$null }

@{ Id='clean_dism'; Cat='Cleanup'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="DISM /Online /Cleanup-Image /StartComponentCleanup`n(no /ResetBase - installed updates stay removable)"
   Check=$null
   Apply={ DISM.exe /Online /Cleanup-Image /StartComponentCleanup /NoRestart }
   Undo =$null }

@{ Id='clean_disk'; Cat='Cleanup'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="HKLM\...\Explorer\VolumeCaches\*  StateFlags0777 = 2`n(except 'DownloadsFolder' and 'Recycle Bin')`ncleanmgr.exe /sagerun:777"
   Check=$null
   Apply={
     $base = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches'
     Get-ChildItem $base | ForEach-Object {
       if ($_.PSChildName -in @('DownloadsFolder','Recycle Bin')) { Remove-Reg $_.PSPath 'StateFlags0777' }
       else { Set-Reg $_.PSPath 'StateFlags0777' 2 }
     }
     Start-Process cleanmgr.exe -ArgumentList '/sagerun:777' -Wait
     Write-Output 'Disk Cleanup finished'
   }
   Undo =$null }
)

# Presets (ids)
$Presets = @{
  # Safe everyday set: snappier UI, no ads, and Windows stops collecting/screenshotting your data
  Recommended = @('perf_menu_delay','perf_startup_delay','ess_delivery_opt','game_mode','game_dvr_off','game_sticky_keys',
                  'priv_telemetry','priv_ad_id','priv_activity','priv_tailored','priv_bing_search','priv_feedback',
                  'priv_start_ads','priv_recall','priv_copilot','priv_widgets','ess_consumer','ess_device_companion','ess_wpbt',
                  'ui_file_ext','ui_end_task','clean_temp','clean_dns')
  # Gaming: max CPU/GPU for the game, lower latency + steadier ping, privacy, and fewer background processes
  Gaming      = @('perf_power_plan','perf_power_throttling','perf_menu_delay','perf_startup_delay','perf_bg_apps',
                  'game_mode','game_hags','game_dvr_off','game_mouse_accel','game_sticky_keys','game_mmcss_games',
                  'game_nagle','game_mmcss_network','ess_delivery_opt','dns_cloudflare','clean_dns',
                  'priv_telemetry','priv_ad_id','priv_activity','priv_tailored','priv_feedback','priv_recall','priv_copilot',
                  'priv_widgets','priv_start_ads','ess_consumer','ess_services_manual','bloat_copilot')
}
