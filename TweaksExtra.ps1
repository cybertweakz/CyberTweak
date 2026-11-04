# CyberTweak extra tweaks: everything from Chris Titus Tech's winutil (MIT license,
# github.com/ChrisTitusTech/winutil) that Tweaks.ps1 does not already cover.
# Same fields as Tweaks.ps1. Track = $false means: no check mark after running (panels).

$Tweaks += @(

# ---------------------------------------------------------------- ESSENTIAL (winutil)
@{ Id='ess_consumer'; Cat='Privacy'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent  DisableWindowsConsumerFeatures = 1"
   Check={ Test-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsConsumerFeatures' 1 }
   Apply={ Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsConsumerFeatures' 1 }
   Undo ={ Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsConsumerFeatures' } }

@{ Id='ess_delivery_opt'; Cat='Performance'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization  DODownloadMode = 0"
   Check={ Test-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' 'DODownloadMode' 0 }
   Apply={ Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' 'DODownloadMode' 0 }
   Undo ={ Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' 'DODownloadMode' } }

@{ Id='ess_services_manual'; Cat='Performance'; Risk='Medium'; Needs=$null; MinBuild=0
   Tech="CscService = Disabled (Offline Files)`nDiagTrack = Disabled`nMapsBroker = Manual`nStorSvc = Manual`nSharedAccess = Disabled (Internet Connection Sharing)"
   Check={ (Test-SvcDisabled 'CscService') -and (Test-SvcDisabled 'SharedAccess') }
   Apply={ Set-Svc 'CscService' 'Disabled'; Set-Svc 'DiagTrack' 'Disabled'; Set-Svc 'MapsBroker' 'Manual'; Set-Svc 'StorSvc' 'Manual'; Set-Svc 'SharedAccess' 'Disabled' }
   Undo ={ Set-Svc 'CscService' 'Manual'; Set-Svc 'DiagTrack' 'Automatic'; Set-Svc 'MapsBroker' 'Automatic'; Set-Svc 'StorSvc' 'Automatic'; Set-Svc 'SharedAccess' 'Automatic' } }

@{ Id='ess_store_search'; Cat='Privacy'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="icacls %LOCALAPPDATA%\Packages\Microsoft.WindowsStore_8wekyb3d8bbwe\LocalState\store.db /deny *S-1-1-0:F"
   Check=$null
   Apply={ icacls "$env:LOCALAPPDATA\Packages\Microsoft.WindowsStore_8wekyb3d8bbwe\LocalState\store.db" /deny '*S-1-1-0:F' }
   Undo ={ icacls "$env:LOCALAPPDATA\Packages\Microsoft.WindowsStore_8wekyb3d8bbwe\LocalState\store.db" /grant '*S-1-1-0:F' } }

@{ Id='ess_device_companion'; Cat='Privacy'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="HKLM\SOFTWARE\Policies\Microsoft\Windows\Device Metadata  PreventDeviceMetadataFromNetwork = 1"
   Check={ Test-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata' 'PreventDeviceMetadataFromNetwork' 1 }
   Apply={ Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata' 'PreventDeviceMetadataFromNetwork' 1 }
   Undo ={ Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata' 'PreventDeviceMetadataFromNetwork' } }

@{ Id='ess_wpbt'; Cat='Privacy'; Risk='Safe'; Needs='reboot'; MinBuild=0
   Tech="HKLM\SYSTEM\CurrentControlSet\Control\Session Manager  DisableWpbtExecution = 1"
   Check={ Test-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' 'DisableWpbtExecution' 1 }
   Apply={ Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' 'DisableWpbtExecution' 1 }
   Undo ={ Remove-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' 'DisableWpbtExecution' } }

@{ Id='ess_explorer_discovery'; Cat='Debloat'; Risk='Medium'; Needs='signout'; MinBuild=0
   Tech="Delete HKCU\...\Windows\Shell\Bags + BagMRU`nHKCU\...\Shell\Bags\AllFolders\Shell  FolderType = ""NotSpecified"""
   Check={ Test-Reg 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell' 'FolderType' 'NotSpecified' }
   Apply={
     $base = 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell'
     Remove-Item "$base\Bags" -Recurse -Force -ErrorAction SilentlyContinue
     Remove-Item "$base\BagMRU" -Recurse -Force -ErrorAction SilentlyContinue
     Set-Reg "$base\Bags\AllFolders\Shell" 'FolderType' 'NotSpecified' 'String'
   }
   Undo={
     $base = 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell'
     Remove-Item "$base\Bags" -Recurse -Force -ErrorAction SilentlyContinue
     Remove-Item "$base\BagMRU" -Recurse -Force -ErrorAction SilentlyContinue
   } }

@{ Id='ess_start_old'; Cat='Debloat'; Risk='Medium'; Needs='reboot'; MinBuild=26100
   Tech="HKLM\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\3036241548  EnabledState = 1"
   Check={ Test-Reg 'HKLM:\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\3036241548' 'EnabledState' 1 }
   Apply={ Set-Reg 'HKLM:\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\3036241548' 'EnabledState' 1 }
   Undo ={ Remove-Reg 'HKLM:\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\3036241548' 'EnabledState' } }

@{ Id='bloat_widgets'; Cat='Debloat'; Risk='Medium'; Needs='explorer'; MinBuild=22000
   Tech="Stop-Process *Widget*`nRemove-AppxPackage -AllUsers  Microsoft.WidgetsPlatformRuntime, MicrosoftWindows.Client.WebExperience"
   Check={ Test-BloatRemoved 'MicrosoftWindows.Client.WebExperience' }
   Apply={ Get-Process *Widget* -ErrorAction SilentlyContinue | Stop-Process -Force; Remove-Bloat 'Microsoft.WidgetsPlatformRuntime','MicrosoftWindows.Client.WebExperience' }
   Undo ={ Open-StoreApp '9MSSGKG348SP' } }

# ---------------------------------------------------------------- PREFERENCES (winutil "Customize Preferences")
@{ Id='pref_dark_mode'; Cat='Preferences'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="HKCU\...\Themes\Personalize  AppsUseLightTheme = 0, SystemUsesLightTheme = 0"
   Check={ Test-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'AppsUseLightTheme' 0 }
   Apply={ Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'AppsUseLightTheme' 0; Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'SystemUsesLightTheme' 0 }
   Undo ={ Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'AppsUseLightTheme' 1; Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'SystemUsesLightTheme' 1 } }

@{ Id='pref_bsod_verbose'; Cat='Preferences'; Risk='Safe'; Needs='reboot'; MinBuild=0
   Tech="HKLM\SYSTEM\CurrentControlSet\Control\CrashControl  DisplayParameters = 1, DisableEmoticon = 1"
   Check={ Test-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' 'DisplayParameters' 1 }
   Apply={ Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' 'DisplayParameters' 1; Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' 'DisableEmoticon' 1 }
   Undo ={ Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' 'DisplayParameters' 0; Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' 'DisableEmoticon' 0 } }

@{ Id='pref_long_paths'; Cat='Preferences'; Risk='Safe'; Needs='reboot'; MinBuild=0
   Tech="HKLM\SYSTEM\CurrentControlSet\Control\FileSystem  LongPathsEnabled = 1"
   Check={ Test-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' 'LongPathsEnabled' 1 }
   Apply={ Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' 'LongPathsEnabled' 1 }
   Undo ={ Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' 'LongPathsEnabled' 0 } }

@{ Id='pref_hidden_files'; Cat='Preferences'; Risk='Safe'; Needs='explorer'; MinBuild=0
   Tech="HKCU\...\Explorer\Advanced  Hidden = 1  (default 2)"
   Check={ Test-Reg $CT_Adv 'Hidden' 1 }
   Apply={ Set-Reg $CT_Adv 'Hidden' 1 }
   Undo ={ Set-Reg $CT_Adv 'Hidden' 2 } }

@{ Id='pref_lockscreen_off'; Cat='Preferences'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization  NoLockScreen = 1"
   Check={ Test-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization' 'NoLockScreen' 1 }
   Apply={ Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization' 'NoLockScreen' 1 }
   Undo ={ Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization' 'NoLockScreen' } }

@{ Id='pref_logon_blur_off'; Cat='Preferences'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="HKLM\SOFTWARE\Policies\Microsoft\Windows\System  DisableAcrylicBackgroundOnLogon = 1"
   Check={ Test-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'DisableAcrylicBackgroundOnLogon' 1 }
   Apply={ Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'DisableAcrylicBackgroundOnLogon' 1 }
   Undo ={ Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'DisableAcrylicBackgroundOnLogon' } }

@{ Id='pref_verbose_logon'; Cat='Preferences'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System  VerboseStatus = 1"
   Check={ Test-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'VerboseStatus' 1 }
   Apply={ Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'VerboseStatus' 1 }
   Undo ={ Remove-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'VerboseStatus' } }

@{ Id='pref_outlook_classic'; Cat='Preferences'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="HKCU\SOFTWARE\Microsoft\Office\16.0\Outlook\Preferences  UseNewOutlook = 0`nHKCU\...\Outlook\Options\General  HideNewOutlookToggle = 1`nHKCU\Software\Policies\...\Outlook\Options\General  DoNewOutlookAutoMigration = 0"
   Check={ Test-Reg 'HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\General' 'HideNewOutlookToggle' 1 }
   Apply={
     Set-Reg 'HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Preferences' 'UseNewOutlook' 0
     Set-Reg 'HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\General' 'HideNewOutlookToggle' 1
     Set-Reg 'HKCU:\Software\Policies\Microsoft\Office\16.0\Outlook\Options\General' 'DoNewOutlookAutoMigration' 0
     Set-Reg 'HKCU:\Software\Policies\Microsoft\Office\16.0\Outlook\Preferences' 'NewOutlookMigrationUserSetting' 0
   }
   Undo={
     Remove-Reg 'HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\General' 'HideNewOutlookToggle'
     Remove-Reg 'HKCU:\Software\Policies\Microsoft\Office\16.0\Outlook\Options\General' 'DoNewOutlookAutoMigration'
     Remove-Reg 'HKCU:\Software\Policies\Microsoft\Office\16.0\Outlook\Preferences' 'NewOutlookMigrationUserSetting'
   } }

@{ Id='pref_numlock'; Cat='Preferences'; Risk='Safe'; Needs='reboot'; MinBuild=0
   Tech="HKU\.DEFAULT\Control Panel\Keyboard + HKCU\Control Panel\Keyboard  InitialKeyboardIndicators = ""2"""
   Check={ Test-Reg 'HKCU:\Control Panel\Keyboard' 'InitialKeyboardIndicators' '2' }
   Apply={ Set-Reg 'Registry::HKEY_USERS\.DEFAULT\Control Panel\Keyboard' 'InitialKeyboardIndicators' '2' 'String'; Set-Reg 'HKCU:\Control Panel\Keyboard' 'InitialKeyboardIndicators' '2' 'String' }
   Undo ={ Set-Reg 'Registry::HKEY_USERS\.DEFAULT\Control Panel\Keyboard' 'InitialKeyboardIndicators' '0' 'String'; Set-Reg 'HKCU:\Control Panel\Keyboard' 'InitialKeyboardIndicators' '0' 'String' } }

@{ Id='pref_s0_network_off'; Cat='Preferences'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="HKCU\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9`n  ACSettingIndex = 0, DCSettingIndex = 0"
   Check={ Test-Reg 'HKCU:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9' 'ACSettingIndex' 0 }
   Apply={ $k='HKCU:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9'; Set-Reg $k 'ACSettingIndex' 0; Set-Reg $k 'DCSettingIndex' 0 }
   Undo ={ $k='HKCU:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9'; Remove-Reg $k 'ACSettingIndex'; Remove-Reg $k 'DCSettingIndex' } }

@{ Id='pref_s3_sleep'; Cat='Preferences'; Risk='Medium'; Needs='reboot'; MinBuild=0
   Tech="HKLM\SYSTEM\CurrentControlSet\Control\Power  PlatformAoAcOverride = 0"
   Check={ Test-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' 'PlatformAoAcOverride' 0 }
   Apply={ Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' 'PlatformAoAcOverride' 0 }
   Undo ={ Remove-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' 'PlatformAoAcOverride' } }

@{ Id='pref_scrollbars'; Cat='Preferences'; Risk='Safe'; Needs='signout'; MinBuild=0
   Tech="HKCU\Control Panel\Accessibility  DynamicScrollbars = 0"
   Check={ Test-Reg 'HKCU:\Control Panel\Accessibility' 'DynamicScrollbars' 0 }
   Apply={ Set-Reg 'HKCU:\Control Panel\Accessibility' 'DynamicScrollbars' 0 }
   Undo ={ Set-Reg 'HKCU:\Control Panel\Accessibility' 'DynamicScrollbars' 1 } }

@{ Id='pref_settings_home_off'; Cat='Preferences'; Risk='Safe'; Needs=$null; MinBuild=22000
   Tech="HKCU\...\CurrentVersion\Policies\Explorer  SettingsPageVisibility = ""hide:home"""
   Check={ Test-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'SettingsPageVisibility' 'hide:home' }
   Apply={ Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'SettingsPageVisibility' 'hide:home' 'String' }
   Undo ={ Remove-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'SettingsPageVisibility' } }

@{ Id='pref_start_recs_off'; Cat='Preferences'; Risk='Medium'; Needs='explorer'; MinBuild=22000
   Tech="HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start  HideRecommendedSection = 1`nHKLM\...\PolicyManager\current\device\Education  IsEducationEnvironment = 1`nHKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer  HideRecommendedSection = 1"
   Check={ Test-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'HideRecommendedSection' 1 }
   Apply={
     Set-Reg 'HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start' 'HideRecommendedSection' 1
     Set-Reg 'HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Education' 'IsEducationEnvironment' 1
     Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'HideRecommendedSection' 1
   }
   Undo={
     Remove-Reg 'HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start' 'HideRecommendedSection'
     Remove-Reg 'HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Education' 'IsEducationEnvironment'
     Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'HideRecommendedSection'
   } }

@{ Id='pref_battery_percent'; Cat='Preferences'; Risk='Safe'; Needs='explorer'; MinBuild=22000
   Tech="HKCU\...\Explorer\Advanced  IsBatteryPercentageEnabled = 1"
   Check={ Test-Reg $CT_Adv 'IsBatteryPercentageEnabled' 1 }
   Apply={ Set-Reg $CT_Adv 'IsBatteryPercentageEnabled' 1 }
   Undo ={ Remove-Reg $CT_Adv 'IsBatteryPercentageEnabled' } }

@{ Id='pref_taskbar_left'; Cat='Preferences'; Risk='Safe'; Needs='explorer'; MinBuild=22000
   Tech="HKCU\...\Explorer\Advanced  TaskbarAl = 0  (1 = centered)"
   Check={ Test-Reg $CT_Adv 'TaskbarAl' 0 }
   Apply={ Set-Reg $CT_Adv 'TaskbarAl' 0 }
   Undo ={ Set-Reg $CT_Adv 'TaskbarAl' 1 } }

@{ Id='pref_taskbar_search_off'; Cat='Preferences'; Risk='Safe'; Needs='explorer'; MinBuild=0
   Tech="HKCU\...\CurrentVersion\Search  SearchboxTaskbarMode = 0"
   Check={ Test-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'SearchboxTaskbarMode' 0 }
   Apply={ Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'SearchboxTaskbarMode' 0 }
   Undo ={ Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'SearchboxTaskbarMode' 1 } }

@{ Id='pref_taskview_off'; Cat='Preferences'; Risk='Safe'; Needs='explorer'; MinBuild=0
   Tech="HKCU\...\Explorer\Advanced  ShowTaskViewButton = 0"
   Check={ Test-Reg $CT_Adv 'ShowTaskViewButton' 0 }
   Apply={ Set-Reg $CT_Adv 'ShowTaskViewButton' 0 }
   Undo ={ Set-Reg $CT_Adv 'ShowTaskViewButton' 1 } }

@{ Id='pref_snapping_off'; Cat='Preferences'; Risk='Safe'; Needs='signout'; MinBuild=0
   Tech="HKCU\Control Panel\Desktop  WindowArrangementActive = ""0"""
   Check={ Test-Reg 'HKCU:\Control Panel\Desktop' 'WindowArrangementActive' '0' }
   Apply={ Set-Reg 'HKCU:\Control Panel\Desktop' 'WindowArrangementActive' '0' 'String' }
   Undo ={ Set-Reg 'HKCU:\Control Panel\Desktop' 'WindowArrangementActive' '1' 'String' } }

@{ Id='pref_mpo_off'; Cat='Preferences'; Risk='Medium'; Needs='reboot'; MinBuild=0
   Tech="HKLM\SOFTWARE\Microsoft\Windows\Dwm  OverlayTestMode = 5"
   Check={ Test-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\Dwm' 'OverlayTestMode' 5 }
   Apply={ Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\Dwm' 'OverlayTestMode' 5 }
   Undo ={ Remove-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\Dwm' 'OverlayTestMode' } }

# ---------------------------------------------------------------- ADVANCED (winutil "Advanced Tweaks - CAUTION")
@{ Id='adv_bitlocker_off'; Cat='Advanced'; Risk='Advanced'; Needs=$null; MinBuild=0
   Tech="Disable-BitLocker -MountPoint C:  (decrypts the system drive)"
   Check={ "$((Get-BitLockerVolume -MountPoint $env:SystemDrive -ErrorAction Stop).VolumeStatus)" -eq 'FullyDecrypted' }
   Apply={
     $v = Get-BitLockerVolume -MountPoint $env:SystemDrive -ErrorAction Stop
     if ("$($v.VolumeStatus)" -eq 'FullyDecrypted') { Write-Output "BitLocker is already off on $env:SystemDrive" }
     else { Disable-BitLocker -MountPoint $env:SystemDrive -ErrorAction Stop | Out-Null; Write-Output 'Decryption started (runs in the background)' }
   }
   Undo ={ Enable-BitLocker -MountPoint $env:SystemDrive -TpmProtector -ErrorAction Stop | Out-Null } }

@{ Id='adv_adobe_block'; Cat='Advanced'; Risk='Medium'; Needs=$null; MinBuild=0
   Tech="Appends github.com/Ruddernation-Designs/Adobe-URL-Block-List to C:\Windows\System32\drivers\etc\hosts"
   Check={ (Get-Content "$env:SystemRoot\System32\drivers\etc\hosts" -Raw -ErrorAction Stop) -match '#New Ver' }
   Apply={
     $list = Invoke-RestMethod -Uri 'https://github.com/Ruddernation-Designs/Adobe-URL-Block-List/raw/refs/heads/master/hosts'
     Add-Content -Path "$env:SystemRoot\System32\drivers\etc\hosts" -Value $list
     ipconfig /flushdns | Out-Null
     Write-Output 'Adobe block list added to hosts file'
   }
   Undo={
     $h = "$env:SystemRoot\System32\drivers\etc\hosts"
     Set-Content $h (((Get-Content $h) -join "`n") -replace '(?s)#New Ver.*', '')
     ipconfig /flushdns | Out-Null
   } }

@{ Id='adv_brave_debloat'; Cat='Advanced'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="HKLM\SOFTWARE\Policies\BraveSoftware\Brave`n  BraveRewardsDisabled, BraveWalletDisabled, BraveVPNDisabled, BraveNewsDisabled, BraveTalkDisabled, TorDisabled = 1`n  BraveAIChatEnabled, BraveStatsPingEnabled, BraveP3AEnabled, MetricsReportingEnabled = 0"
   Check={ Test-Reg 'HKLM:\SOFTWARE\Policies\BraveSoftware\Brave' 'BraveRewardsDisabled' 1 }
   Apply={
     $k = 'HKLM:\SOFTWARE\Policies\BraveSoftware\Brave'
     foreach ($n in 'BraveRewardsDisabled','BraveWalletDisabled','BraveVPNDisabled','BraveNewsDisabled','BraveTalkDisabled','TorDisabled') { Set-Reg $k $n 1 }
     foreach ($n in 'BraveAIChatEnabled','BraveStatsPingEnabled','BraveP3AEnabled','UrlKeyedAnonymizedDataCollectionEnabled','SafeBrowsingExtendedReportingEnabled','MetricsReportingEnabled') { Set-Reg $k $n 0 }
   }
   Undo ={ Remove-Item 'HKLM:\SOFTWARE\Policies\BraveSoftware\Brave' -Recurse -Force -ErrorAction SilentlyContinue } }

@{ Id='adv_edge_debloat'; Cat='Advanced'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="HKLM\SOFTWARE\Policies\Microsoft\Edge  (16 policies: recommendations, shopping, rewards, collections, first run, diagnostic data ...)`nHKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate  CreateDesktopShortcutDefault = 0"
   Check={ Test-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' 'HideFirstRunExperience' 1 }
   Apply={
     $k = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
     Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate' 'CreateDesktopShortcutDefault' 0
     Set-Reg "$k\ExtensionInstallBlocklist" '1' 'ofefcgjbeghpigppfmkologfjadafddi' 'String'
     foreach ($n in 'PersonalizationReportingEnabled','ShowRecommendationsEnabled','UserFeedbackAllowed','AlternateErrorPagesEnabled','EdgeCollectionsEnabled','EdgeShoppingAssistantEnabled','MicrosoftEdgeInsiderPromotionEnabled','ShowMicrosoftRewards','WebWidgetAllowed','DiagnosticData','EdgeAssetDeliveryServiceEnabled','WalletDonationEnabled','DefaultBrowserSettingsCampaignEnabled') { Set-Reg $k $n 0 }
     Set-Reg $k 'HideFirstRunExperience' 1
     Set-Reg $k 'ConfigureDoNotTrack' 1
   }
   Undo={
     Remove-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Recurse -Force -ErrorAction SilentlyContinue
     Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate' 'CreateDesktopShortcutDefault'
   } }

@{ Id='adv_edge_remove'; Cat='Advanced'; Risk='Advanced'; Needs=$null; MinBuild=0
   Tech="Creates dummy %SystemRoot%\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\MicrosoftEdge.exe`nsetup.exe --uninstall --system-level --force-uninstall --delete-profile`nUndo: winget install Microsoft.Edge"
   Check={ -not (Test-Path "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe") }
   Apply={
     $dir = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application"
     $setup = if (Test-Path $dir) { Resolve-Path (Join-Path $dir '*\Installer\setup.exe') -ErrorAction SilentlyContinue | Select-Object -Last 1 }
     if ($setup) {
       New-Item -Path "$env:SystemRoot\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\MicrosoftEdge.exe" -Force | Out-Null
       Start-Process -FilePath $setup -ArgumentList '--uninstall --system-level --force-uninstall --delete-profile' -Wait
       Write-Output 'Microsoft Edge was removed'
     } else { Write-Output 'Microsoft Edge is not installed' }
   }
   Undo ={ winget install --id Microsoft.Edge -e --source winget --accept-source-agreements --accept-package-agreements } }

@{ Id='adv_onedrive_remove'; Cat='Advanced'; Risk='Advanced'; Needs='explorer'; MinBuild=0
   Tech="Protects your OneDrive folder (icacls deny delete), runs OneDriveSetup.exe /uninstall,`nremoves leftovers in %LOCALAPPDATA%\Microsoft\OneDrive and %PROGRAMDATA%\Microsoft OneDrive,`nrestores the folder permissions, OneSyncSvc = Disabled`nUndo: winget install Microsoft.OneDrive"
   Check={ -not (Test-Path "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe") -and -not (Test-Path "$env:ProgramFiles\Microsoft OneDrive\OneDrive.exe") }
   Apply={
     $od = $env:OneDrive
     $hasFolder = $od -and (Test-Path -LiteralPath $od -PathType Container)
     if ($hasFolder) { $acl = Get-Acl -LiteralPath $od; icacls $od /deny '*S-1-5-32-544:(D,DC)' | Out-Null }
     try {
       Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
       $setup = Join-Path $env:SystemRoot 'System32\OneDriveSetup.exe'
       if (Test-Path $setup) { Start-Process -FilePath $setup -ArgumentList '/uninstall' -Wait }
       else { winget uninstall --id Microsoft.OneDrive -e --silent --accept-source-agreements }
       Stop-Process -Name FileCoAuth -Force -ErrorAction SilentlyContinue
       foreach ($p in "$env:LOCALAPPDATA\Microsoft\OneDrive", "$env:ProgramData\Microsoft OneDrive") { Remove-Item -LiteralPath $p -Recurse -Force -ErrorAction SilentlyContinue }
     } finally { if ($hasFolder) { Set-Acl -LiteralPath $od -AclObject $acl } }
     if (Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Services\OneSyncSvc') { Set-Service -Name OneSyncSvc -StartupType Disabled -ErrorAction SilentlyContinue }
     Write-Output 'OneDrive removed. Your files in the OneDrive folder were kept.'
   }
   Undo={
     winget install --id Microsoft.OneDrive -e --source winget --accept-source-agreements --accept-package-agreements
     if (Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Services\OneSyncSvc') { Set-Service -Name OneSyncSvc -StartupType Automatic -ErrorAction SilentlyContinue }
   } }

@{ Id='adv_utc_time'; Cat='Advanced'; Risk='Medium'; Needs='reboot'; MinBuild=0
   Tech="HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation  RealTimeIsUniversal = 1 (QWord)"
   Check={ Test-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation' 'RealTimeIsUniversal' 1 }
   Apply={ Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation' 'RealTimeIsUniversal' 1 'QWord' }
   Undo ={ Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation' 'RealTimeIsUniversal' 0 'QWord' } }

@{ Id='adv_reserved_storage'; Cat='Advanced'; Risk='Medium'; Needs=$null; MinBuild=0
   Tech="DISM /Online /Set-ReservedStorageState /State:Disabled"
   Check=$null
   Apply={ DISM.exe /Online /Set-ReservedStorageState /State:Disabled }
   Undo ={ DISM.exe /Online /Set-ReservedStorageState /State:Enabled } }

@{ Id='adv_home_gallery_off'; Cat='Advanced'; Risk='Safe'; Needs='explorer'; MinBuild=22000
   Tech="HKCU\Software\Classes\CLSID\{f874310e-...} + {e88865ea-...}  System.IsPinnedToNameSpaceTree = 0`nHKCU\...\Explorer\Advanced  LaunchTo = 1 (This PC)"
   Check={ Test-Reg $CT_Adv 'LaunchTo' 1 }
   Apply={
     Set-Reg 'HKCU:\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}' 'System.IsPinnedToNameSpaceTree' 0
     Set-Reg 'HKCU:\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}' 'System.IsPinnedToNameSpaceTree' 0
     Set-Reg $CT_Adv 'LaunchTo' 1
   }
   Undo={
     Remove-Reg 'HKCU:\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}' 'System.IsPinnedToNameSpaceTree'
     Remove-Reg 'HKCU:\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}' 'System.IsPinnedToNameSpaceTree'
     Remove-Reg $CT_Adv 'LaunchTo'
   } }

@{ Id='adv_logi_block'; Cat='Advanced'; Risk='Medium'; Needs=$null; MinBuild=0
   Tech="Stop logi_download_assistant, empty %ProgramFiles%\LogiDownloadAssistant`nicacls ... /deny *S-1-1-0:(W)"
   Check=$null
   Apply={
     Stop-Process -Name 'logi_download_assistant' -Force -ErrorAction SilentlyContinue
     $pf = if ($env:ProgramW6432) { $env:ProgramW6432 } else { $env:ProgramFiles }
     $p = "$pf\LogiDownloadAssistant"
     if (Test-Path $p) { Remove-Item "$p\*" -Recurse -Force -ErrorAction SilentlyContinue } else { New-Item -Path $p -ItemType Directory | Out-Null }
     icacls $p /deny '*S-1-1-0:(W)'
   }
   Undo={
     $pf = if ($env:ProgramW6432) { $env:ProgramW6432 } else { $env:ProgramFiles }
     if (Test-Path "$pf\LogiDownloadAssistant") { icacls "$pf\LogiDownloadAssistant" /remove:d '*S-1-1-0' }
   } }

@{ Id='adv_razer_block'; Cat='Advanced'; Risk='Medium'; Needs=$null; MinBuild=0
   Tech="HKLM\...\DriverSearching  SearchOrderConfig = 0`nHKLM\...\Device Installer  DisableCoInstallers = 1`nicacls C:\Windows\Installer\Razer /deny *S-1-1-0:(W)"
   Check={ Test-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Installer' 'DisableCoInstallers' 1 }
   Apply={
     Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching' 'SearchOrderConfig' 0
     Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Installer' 'DisableCoInstallers' 1
     $p = "$env:SystemRoot\Installer\Razer"
     if (Test-Path $p) { Remove-Item "$p\*" -Recurse -Force -ErrorAction SilentlyContinue } else { New-Item -Path $p -ItemType Directory | Out-Null }
     icacls $p /deny '*S-1-1-0:(W)'
   }
   Undo={
     Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching' 'SearchOrderConfig' 1
     Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Installer' 'DisableCoInstallers' 0
     icacls "$env:SystemRoot\Installer\Razer" /remove:d '*S-1-1-0'
   } }

@{ Id='adv_rdp_warning_off'; Cat='Advanced'; Risk='Medium'; Needs=$null; MinBuild=0
   Tech="HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client  RedirectionWarningDialogVersion = 1`nHKCU\SOFTWARE\Microsoft\Terminal Server Client  RdpLaunchConsentAccepted = 1"
   Check={ Test-Reg 'HKCU:\SOFTWARE\Microsoft\Terminal Server Client' 'RdpLaunchConsentAccepted' 1 }
   Apply={ Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client' 'RedirectionWarningDialogVersion' 1; Set-Reg 'HKCU:\SOFTWARE\Microsoft\Terminal Server Client' 'RdpLaunchConsentAccepted' 1 }
   Undo ={ Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client' 'RedirectionWarningDialogVersion'; Remove-Reg 'HKCU:\SOFTWARE\Microsoft\Terminal Server Client' 'RdpLaunchConsentAccepted' } }

@{ Id='adv_storage_sense_off'; Cat='Advanced'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="HKCU\...\StorageSense\Parameters\StoragePolicy  01 = 0"
   Check={ Test-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' '01' 0 }
   Apply={ Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' '01' 0 }
   Undo ={ Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' '01' 1 } }

@{ Id='adv_svchost_split_off'; Cat='Advanced'; Risk='Medium'; Needs='reboot'; MinBuild=0
   Tech="HKLM\SYSTEM\CurrentControlSet\Control  SvcHostSplitThresholdInKB = <installed RAM in KB>  (default 3670016)"
   Check={ (Get-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control' 'SvcHostSplitThresholdInKB') -gt 3670016 }
   Apply={
     $kb = [int]((Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum / 1KB)
     Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control' 'SvcHostSplitThresholdInKB' $kb
     Write-Output "Threshold set to $kb KB"
   }
   Undo ={ Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control' 'SvcHostSplitThresholdInKB' 3670016 } }

@{ Id='adv_notifications_off'; Cat='Advanced'; Risk='Medium'; Needs='signout'; MinBuild=0
   Tech="HKCU\Software\Policies\Microsoft\Windows\Explorer  DisableNotificationCenter = 1`nHKCU\...\CurrentVersion\PushNotifications  ToastEnabled = 0"
   Check={ Test-Reg 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' 'DisableNotificationCenter' 1 }
   Apply={ Set-Reg 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' 'DisableNotificationCenter' 1; Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications' 'ToastEnabled' 0 }
   Undo ={ Remove-Reg 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' 'DisableNotificationCenter'; Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications' 'ToastEnabled' 1 } }

@{ Id='adv_windows_ai'; Cat='Advanced'; Risk='Advanced'; Needs='reboot'; MinBuild=22000
   Tech="Remove-AppxPackage *Copilot*, Microsoft.MicrosoftOfficeHub, MicrosoftWindows.Client.CoreAI`nWSAIFabricSvc = Disabled, Disable-WindowsOptionalFeature Recall`nHKLM\...\Policies\Explorer  SettingsPageVisibility = hide:aicomponents`nHKLM\SOFTWARE\Policies\WindowsNotepad  DisableAIFeatures = 1"
   Check={ Test-Reg 'HKLM:\SOFTWARE\Policies\WindowsNotepad' 'DisableAIFeatures' 1 }
   Apply={
     Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'SettingsPageVisibility' 'hide:aicomponents' 'String'
     Set-Reg 'HKLM:\SOFTWARE\Policies\WindowsNotepad' 'DisableAIFeatures' 1
     $core = (Get-AppxPackage MicrosoftWindows.Client.CoreAI -ErrorAction SilentlyContinue).PackageFullName
     if ($core) {
       $sid = ([Security.Principal.WindowsIdentity]::GetCurrent()).User.Value
       New-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\EndOfLife\$sid\$core" -Force | Out-Null
       Remove-AppxPackage $core -ErrorAction SilentlyContinue
     }
     Get-AppxPackage -AllUsers '*Copilot*' -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
     Get-AppxPackage -AllUsers Microsoft.MicrosoftOfficeHub -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
     if (Get-Service -Name WSAIFabricSvc -ErrorAction SilentlyContinue) { Set-Service -Name WSAIFabricSvc -StartupType Disabled }
     Disable-WindowsOptionalFeature -FeatureName Recall -Online -NoRestart -ErrorAction SilentlyContinue | Out-Null
     Write-Output 'Windows AI disabled'
   }
   Undo={
     Remove-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'SettingsPageVisibility'
     Remove-Reg 'HKLM:\SOFTWARE\Policies\WindowsNotepad' 'DisableAIFeatures'
     if (Get-Service -Name WSAIFabricSvc -ErrorAction SilentlyContinue) { Set-Service -Name WSAIFabricSvc -StartupType Manual }
     Write-Output 'Policies removed. Removed AI apps can be reinstalled from the Microsoft Store.'
   } }

@{ Id='adv_oosu'; Cat='Advanced'; Risk='Medium'; Needs=$null; MinBuild=0
   Tech="Downloads https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe to %LOCALAPPDATA%\CyberTweak and starts it (nothing is installed)"
   Check=$null; Track=$false
   Apply={ $f = Get-DownloadFile 'https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe' 'OOSU10.exe'; Write-Output "Starting $f"; Start-Process $f }
   Undo =$null }

# ---------------------------------------------------------------- NETWORK (IPv6, Teredo, DNS)
@{ Id='net_ipv4_pref'; Cat='Network'; Risk='Medium'; Needs='reboot'; MinBuild=0
   Tech="HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters  DisabledComponents = 32"
   Check={ Test-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters' 'DisabledComponents' 32 }
   Apply={ Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters' 'DisabledComponents' 32 }
   Undo ={ Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters' 'DisabledComponents' 0 } }

@{ Id='net_ipv6_off'; Cat='Network'; Risk='Advanced'; Needs='reboot'; MinBuild=0
   Tech="HKLM\...\Tcpip6\Parameters  DisabledComponents = 255`nDisable-NetAdapterBinding -Name * -ComponentID ms_tcpip6"
   Check={ Test-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters' 'DisabledComponents' 255 }
   Apply={ Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters' 'DisabledComponents' 255; Disable-NetAdapterBinding -Name * -ComponentID ms_tcpip6 }
   Undo ={ Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters' 'DisabledComponents' 0; Enable-NetAdapterBinding -Name * -ComponentID ms_tcpip6 } }

@{ Id='net_teredo_off'; Cat='Network'; Risk='Medium'; Needs='reboot'; MinBuild=0
   Tech="netsh interface teredo set state disabled`nHKLM\...\Tcpip6\Parameters  DisabledComponents = 1"
   Check={ Test-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters' 'DisabledComponents' 1 }
   Apply={ Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters' 'DisabledComponents' 1; netsh interface teredo set state disabled }
   Undo ={ Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters' 'DisabledComponents' 0; netsh interface teredo set state default } }

# ---------------------------------------------------------------- FEATURES
@{ Id='feat_dotnet'; Cat='Features'; Risk='Safe'; Needs='reboot'; MinBuild=0
   Tech="Enable-WindowsOptionalFeature  NetFx3, NetFx4-AdvSrvs"
   Check={ Test-Feat 'NetFx3' }
   Apply={ Enable-Feat 'NetFx4-AdvSrvs','NetFx3' }
   Undo ={ Disable-Feat 'NetFx3' } }

@{ Id='feat_hyperv'; Cat='Features'; Risk='Medium'; Needs='reboot'; MinBuild=0
   Tech="Enable-WindowsOptionalFeature  Microsoft-Hyper-V-All  (Pro/Enterprise only)"
   Check={ Test-Feat 'Microsoft-Hyper-V-All' }
   Apply={ Enable-Feat 'Microsoft-Hyper-V-All' }
   Undo ={ Disable-Feat 'Microsoft-Hyper-V-All' } }

@{ Id='feat_legacy_media'; Cat='Features'; Risk='Safe'; Needs='reboot'; MinBuild=0
   Tech="Enable-WindowsOptionalFeature  WindowsMediaPlayer, MediaPlayback, DirectPlay, LegacyComponents"
   Check={ Test-Feat 'DirectPlay' }
   Apply={ Enable-Feat 'WindowsMediaPlayer','MediaPlayback','DirectPlay','LegacyComponents' }
   Undo ={ Disable-Feat 'DirectPlay','LegacyComponents' } }

@{ Id='feat_wsl'; Cat='Features'; Risk='Safe'; Needs='reboot'; MinBuild=0
   Tech="Enable-WindowsOptionalFeature  VirtualMachinePlatform, Microsoft-Windows-Subsystem-Linux"
   Check={ Test-Feat 'Microsoft-Windows-Subsystem-Linux' }
   Apply={ Enable-Feat 'VirtualMachinePlatform','Microsoft-Windows-Subsystem-Linux' }
   Undo ={ Disable-Feat 'Microsoft-Windows-Subsystem-Linux','VirtualMachinePlatform' } }

@{ Id='feat_sandbox'; Cat='Features'; Risk='Safe'; Needs='reboot'; MinBuild=0
   Tech="Enable-WindowsOptionalFeature  Containers-DisposableClientVM  (Pro/Enterprise only)"
   Check={ Test-Feat 'Containers-DisposableClientVM' }
   Apply={ Enable-Feat 'Containers-DisposableClientVM' }
   Undo ={ Disable-Feat 'Containers-DisposableClientVM' } }

@{ Id='feat_nfs'; Cat='Features'; Risk='Safe'; Needs='reboot'; MinBuild=0
   Tech="Enable-WindowsOptionalFeature  ServicesForNFS-ClientOnly, ClientForNFS-Infrastructure, NFS-Administration`nAnonymousUID/GID = 0, fileaccess=755"
   Check={ Test-Feat 'ServicesForNFS-ClientOnly' }
   Apply={
     Enable-Feat 'ServicesForNFS-ClientOnly','ClientForNFS-Infrastructure','NFS-Administration'
     nfsadmin client stop
     Set-Reg 'HKLM:\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default' 'AnonymousUID' 0
     Set-Reg 'HKLM:\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default' 'AnonymousGID' 0
     nfsadmin client start
     nfsadmin client localhost config fileaccess=755 SecFlavors=+sys -krb5 -krb5i
   }
   Undo ={ Disable-Feat 'NFS-Administration','ClientForNFS-Infrastructure','ServicesForNFS-ClientOnly' } }

@{ Id='feat_regbackup'; Cat='Features'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="HKLM\...\Session Manager\Configuration Manager  EnablePeriodicBackup = 1, BackupCount = 2`nScheduled task 'AutoRegBackup' daily 00:30"
   Check={ [bool](Get-ScheduledTask -TaskName 'AutoRegBackup' -ErrorAction SilentlyContinue) }
   Apply={
     $k = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager'
     Set-Reg $k 'EnablePeriodicBackup' 1; Set-Reg $k 'BackupCount' 2
     $action = New-ScheduledTaskAction -Execute 'schtasks' -Argument '/run /i /tn "\Microsoft\Windows\Registry\RegIdleBackup"'
     $trigger = New-ScheduledTaskTrigger -Daily -At 00:30
     Register-ScheduledTask -Action $action -Trigger $trigger -TaskName 'AutoRegBackup' -Description 'Create System Registry Backups' -User 'System' -Force | Out-Null
   }
   Undo={
     Unregister-ScheduledTask -TaskName 'AutoRegBackup' -Confirm:$false -ErrorAction SilentlyContinue
     Remove-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager' 'EnablePeriodicBackup'
   } }

@{ Id='feat_f8_boot'; Cat='Features'; Risk='Medium'; Needs='reboot'; MinBuild=0
   Tech="bcdedit /set bootmenupolicy legacy  (Undo: standard)"
   Check={ "$(bcdedit /enum '{current}' 2>$null)" -match 'bootmenupolicy\s+Legacy' }
   Apply={ bcdedit /set bootmenupolicy legacy }
   Undo ={ bcdedit /set bootmenupolicy standard } }

# ---------------------------------------------------------------- FIXES
@{ Id='fix_sfc'; Cat='Fixes'; Risk='Safe'; Needs='reboot'; MinBuild=0
   Tech="DISM /Online /Cleanup-Image /RestoreHealth`nsfc /scannow"
   Check=$null
   Apply={ DISM.exe /Online /Cleanup-Image /RestoreHealth; sfc.exe /scannow }
   Undo =$null }

@{ Id='fix_network_reset'; Cat='Fixes'; Risk='Medium'; Needs='reboot'; MinBuild=0
   Tech="netsh winsock reset`nnetsh int ip reset`nipconfig /release, /renew, /flushdns"
   Check=$null
   Apply={ netsh winsock reset; netsh int ip reset; ipconfig /release | Out-Null; ipconfig /renew | Out-Null; ipconfig /flushdns }
   Undo =$null }

@{ Id='fix_wu_reset'; Cat='Fixes'; Risk='Safe'; Needs='reboot'; MinBuild=0
   Tech="Stop wuauserv, bits, cryptsvc, msiserver`nRename SoftwareDistribution and System32\catroot2 to .old`nStart the services again"
   Check=$null
   Apply={
     $svcs = 'wuauserv','bits','cryptsvc','msiserver'
     Stop-Service $svcs -Force -ErrorAction SilentlyContinue
     foreach ($p in "$env:SystemRoot\SoftwareDistribution", "$env:SystemRoot\System32\catroot2") {
       if (Test-Path "$p.old") { Remove-Item "$p.old" -Recurse -Force -ErrorAction SilentlyContinue }
       if (Test-Path $p) { Rename-Item $p "$(Split-Path $p -Leaf).old" -ErrorAction SilentlyContinue }
     }
     Start-Service $svcs -ErrorAction SilentlyContinue
     Write-Output 'Windows Update components reset'
   }
   Undo =$null }

@{ Id='fix_winget'; Cat='Fixes'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="Add-AppxPackage -RegisterByFamilyName Microsoft.DesktopAppInstaller_8wekyb3d8bbwe`nFallback: download https://aka.ms/getwinget and install"
   Check=$null
   Apply={
     try { Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction Stop; Write-Output 'winget re-registered' }
     catch { $f = Get-DownloadFile 'https://aka.ms/getwinget' 'winget.msixbundle'; Add-AppxPackage -Path $f -ForceApplicationShutdown; Write-Output 'winget reinstalled' }
   }
   Undo =$null }

@{ Id='fix_ntp'; Cat='Fixes'; Risk='Safe'; Needs=$null; MinBuild=0
   Tech="w32tm /config /manualpeerlist:pool.ntp.org /syncfromflags:manual /update`nRestart w32time, w32tm /resync"
   Check={ (Get-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters' 'NtpServer') -match 'pool\.ntp\.org' }
   Apply={ w32tm /config /manualpeerlist:"pool.ntp.org,0x8" /syncfromflags:manual /update; Restart-Service w32time -ErrorAction SilentlyContinue; w32tm /resync }
   Undo ={ w32tm /config /manualpeerlist:"time.windows.com,0x9" /syncfromflags:manual /update; Restart-Service w32time -ErrorAction SilentlyContinue } }

@{ Id='fix_autologon'; Cat='Fixes'; Risk='Medium'; Needs=$null; MinBuild=0
   Tech="Downloads Sysinternals Autologon (live.sysinternals.com/Autologon64.exe) and starts it"
   Check=$null; Track=$false
   Apply={ $f = Get-DownloadFile 'https://live.sysinternals.com/Autologon64.exe' 'Autologon64.exe'; Write-Output "Starting $f"; Start-Process $f }
   Undo =$null }

# ---------------------------------------------------------------- REMOTE / PROFILE (in Panels)
@{ Id='rem_ssh'; Cat='Panels'; Risk='Medium'; Needs=$null; MinBuild=0
   Tech="Add-WindowsCapability OpenSSH.Server~~~~0.0.1.0`nsshd = Automatic + Start`nFirewall rule TCP 22 inbound"
   Check={ "$((Get-Service sshd -ErrorAction Stop).StartType)" -eq 'Automatic' }
   Apply={
     Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 | Out-Null
     Set-Service -Name sshd -StartupType Automatic
     Start-Service sshd
     if (-not (Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue)) {
       New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 | Out-Null
     }
     Write-Output 'OpenSSH Server is running on port 22'
   }
   Undo={
     Stop-Service sshd -ErrorAction SilentlyContinue
     Set-Service -Name sshd -StartupType Disabled -ErrorAction SilentlyContinue
     Remove-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue
   } }

@{ Id='rem_ctt_profile'; Cat='Panels'; Risk='Advanced'; Needs=$null; MinBuild=0
   Tech="Needs PowerShell 7 (pwsh). Runs:`nirm https://github.com/ChrisTitusTech/powershell-profile/raw/main/setup.ps1 | iex`nUndo: deletes the pwsh `$PROFILE file"
   Check={ (Get-Command pwsh -ErrorAction Stop) -and (Test-Path "$([Environment]::GetFolderPath('MyDocuments'))\PowerShell\Microsoft.PowerShell_profile.ps1") }
   Apply={
     if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) { throw 'PowerShell 7 is not installed. Install it under Apps > Microsoft Tools > PowerShell.' }
     pwsh -NoProfile -ExecutionPolicy Bypass -Command "irm 'https://github.com/ChrisTitusTech/powershell-profile/raw/main/setup.ps1' | iex"
   }
   Undo={
     if (Get-Command pwsh -ErrorAction SilentlyContinue) { pwsh -NoProfile -Command 'if (Test-Path $PROFILE) { Remove-Item $PROFILE -Force; "Profile removed" }' }
   } }
)

# DNS providers (data from winutil config/dns.json)
$CT_Dns = @(
  @('google',             'Google',                  '8.8.8.8',        '8.8.4.4',         '2001:4860:4860::8888', '2001:4860:4860::8844'),
  @('cloudflare',         'Cloudflare',              '1.1.1.1',        '1.0.0.1',         '2606:4700:4700::1111', '2606:4700:4700::1001'),
  @('cloudflare_malware', 'Cloudflare Malware',      '1.1.1.2',        '1.0.0.2',         '2606:4700:4700::1112', '2606:4700:4700::1002'),
  @('cloudflare_family',  'Cloudflare Family',       '1.1.1.3',        '1.0.0.3',         '2606:4700:4700::1113', '2606:4700:4700::1003'),
  @('opendns',            'OpenDNS',                 '208.67.222.222', '208.67.220.220',  '2620:119:35::35',      '2620:119:53::53'),
  @('quad9',              'Quad9',                   '9.9.9.9',        '149.112.112.112', '2620:fe::fe',          '2620:fe::9'),
  @('adguard',            'AdGuard',                 '94.140.14.14',   '94.140.15.15',    '2a10:50c0::ad1:ff',    '2a10:50c0::ad2:ff'),
  @('adguard_family',     'AdGuard Family',          '94.140.14.15',   '94.140.15.16',    '2a10:50c0::bad1:ff',   '2a10:50c0::bad2:ff')
)
foreach ($d in $CT_Dns) {
  $servers = "'{0}','{1}','{2}','{3}'" -f $d[2], $d[3], $d[4], $d[5]
  $Tweaks += @{ Id = "dns_$($d[0])"; Cat = 'Network'; Risk = 'Safe'; Needs = $null; MinBuild = 0; DnsName = $d[1]
    Tech  = "Set-DnsClientServerAddress (all active adapters)`nIPv4: $($d[2]), $($d[3])`nIPv6: $($d[4]), $($d[5])`nUndo: back to automatic (DHCP)"
    Check = [scriptblock]::Create("Test-Dns '$($d[2])'")
    Apply = [scriptblock]::Create("Set-DnsAll $servers")
    Undo  = [scriptblock]::Create('Set-DnsAll $null') }
}

# Legacy Windows panels: Apply just opens them
$CT_Panels = @(
  @('panel_compmgmt', 'compmgmt.msc'), @('panel_control', 'control.exe'), @('panel_mouse', 'main.cpl'),
  @('panel_network', 'ncpa.cpl'), @('panel_power', 'powercfg.cpl'), @('panel_printer', 'shell:::{A8A91A66-3A7D-4424-8D24-04E180695C7A}'),
  @('panel_programs', 'appwiz.cpl'), @('panel_region', 'intl.cpl'), @('panel_security', 'wscui.cpl'),
  @('panel_sound', 'mmsys.cpl'), @('panel_system', 'sysdm.cpl'), @('panel_timedate', 'timedate.cpl'),
  @('panel_firewall', 'firewall.cpl'), @('panel_restore', 'rstrui.exe')
)
foreach ($p in $CT_Panels) {
  $Tweaks += @{ Id = $p[0]; Cat = 'Panels'; Risk = 'Safe'; Needs = $null; MinBuild = 0; Track = $false
    Tech = "Start-Process $($p[1])"; Check = $null; Undo = $null
    Apply = [scriptblock]::Create("Start-Process '$($p[1])'") }
}

# Windows Update profiles (Updates tab, not shown in lists)
$CT_WU = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
$UpdateProfiles = @{
  rec = {
    $k = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
    Set-Reg $k 'DeferFeatureUpdates' 1; Set-Reg $k 'DeferFeatureUpdatesPeriodInDays' 365
    Set-Reg $k 'DeferQualityUpdates' 1; Set-Reg $k 'DeferQualityUpdatesPeriodInDays' 4
    Set-Reg $k 'ExcludeWUDriversInQualityUpdate' 1
    Set-Reg "$k\AU" 'NoAutoUpdate' 0; Set-Reg "$k\AU" 'AUOptions' 3; Set-Reg "$k\AU" 'NoAutoRebootWithLoggedOnUsers' 1
    Set-Svc 'wuauserv' 'Manual'; Set-Svc 'UsoSvc' 'Automatic'
    Set-UpdateTasks $true
    Write-Output 'Recommended update profile applied'
  }
  def = {
    Remove-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Recurse -Force -ErrorAction SilentlyContinue
    Set-Svc 'wuauserv' 'Manual'; Set-Svc 'UsoSvc' 'Automatic'
    Set-UpdateTasks $true
    Write-Output 'Windows Update is back to Windows defaults'
  }
  dis = {
    $k = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
    Set-Reg "$k\AU" 'NoAutoUpdate' 1; Set-Reg "$k\AU" 'AUOptions' 1
    Set-Svc 'wuauserv' 'Disabled'; Set-Svc 'UsoSvc' 'Disabled'
    Set-UpdateTasks $false
    Clear-Folder "$env:SystemRoot\SoftwareDistribution\Download"
    Write-Output 'Windows Update disabled'
  }
}
