# CyberTweak app list for the winget installer.
# One line per app: Group | Name | winget id | English description
# Translations of the description live in lang\<code>.json under "apps".<winget id>.
# A 12-character store id (e.g. 9NKSQGP7F2NH) is installed from the msstore source.

$AppList = @'
Favorites|Discord|Discord.Discord|Voice, video and text chat for gamers and communities.
Favorites|Steam|Valve.Steam|Valve's huge PC gaming platform.
Favorites|Firefox|Mozilla.Firefox|Independent open-source browser with strong privacy.
Favorites|WinRAR|RARLab.WinRAR|Archiver for RAR and ZIP.
Favorites|Claude Desktop|Anthropic.Claude|Anthropic's Claude desktop app.
Favorites|ChatGPT Desktop|9NT1R1C2HH7J|OpenAI ChatGPT app (Microsoft Store).
Favorites|.NET Desktop Runtime 3.1|Microsoft.DotNet.DesktopRuntime.3_1|Needed by older .NET Core programs.
Favorites|.NET Desktop Runtime 5|Microsoft.DotNet.DesktopRuntime.5|Needed by older .NET programs.
Favorites|.NET Desktop Runtime 6|Microsoft.DotNet.DesktopRuntime.6|Needed by older .NET programs.
Favorites|.NET Desktop Runtime 7|Microsoft.DotNet.DesktopRuntime.7|Needed by older .NET programs.
Favorites|.NET Desktop Runtime 8|Microsoft.DotNet.DesktopRuntime.8|Needed by many Windows programs.
Favorites|.NET Desktop Runtime 9|Microsoft.DotNet.DesktopRuntime.9|Needed by many Windows programs.
Favorites|.NET Desktop Runtime 10|Microsoft.DotNet.DesktopRuntime.10|Needed by many Windows programs.
Favorites|Visual C++ 2015-2022 32-bit|Microsoft.VCRedist.2015+.x86|Runtime needed by many games and programs (32-bit).
Favorites|Visual C++ 2015-2022 64-bit|Microsoft.VCRedist.2015+.x64|Runtime needed by many games and programs (64-bit).
Browsers|Brave|Brave.Brave|Fast Chromium browser with built-in ad and tracker blocker.
Browsers|Chrome|Google.Chrome|Google's browser, the most used in the world.
Browsers|Chromium|Hibbiki.Chromium|Open-source base of Chrome, without Google services.
Browsers|Edge|Microsoft.Edge|Microsoft's Chromium browser built into Windows.
Browsers|Firefox|Mozilla.Firefox|Independent open-source browser with strong privacy.
Browsers|Firefox ESR|Mozilla.Firefox.ESR|Firefox Extended Support Release: fewer updates, very stable.
Browsers|Floorp|Ablaze.Floorp|Highly customizable Firefox-based browser.
Browsers|Helium|ImputNet.Helium|Lightweight, privacy-focused Chromium browser.
Browsers|LibreWolf|LibreWolf.LibreWolf|Firefox fork hardened for privacy, no telemetry.
Browsers|Mullvad Browser|MullvadVPN.MullvadBrowser|Anti-fingerprinting browser from Mullvad and Tor.
Browsers|Tor Browser|TorProject.TorBrowser|Browses anonymously through the Tor network.
Browsers|Ungoogled Chromium|eloston.ungoogled-chromium|Chromium with all Google integration removed.
Browsers|Vivaldi|Vivaldi.Vivaldi|Feature-packed Chromium browser with tabs, notes and mail.
Browsers|Waterfox|Waterfox.Waterfox|Privacy-friendly Firefox fork.
Browsers|Zen Browser|Zen-Team.Zen-Browser|Modern Firefox-based browser with vertical tabs.
Communications|Betterbird|Betterbird.Betterbird|Improved fork of the Thunderbird mail client.
Communications|Chatterino|ChatterinoTeam.Chatterino|Desktop chat client for Twitch.
Communications|Discord|Discord.Discord|Voice, video and text chat for gamers and communities.
Communications|Dorion|SpikeHD.Dorion|Lightweight alternative Discord client.
Communications|Element|Element.Element|Secure chat on the open Matrix network.
Communications|Proton Mail|Proton.ProtonMail|Desktop app for encrypted Proton Mail.
Communications|QTox|Tox.qTox|Encrypted peer-to-peer chat and calls (Tox).
Communications|Signal|OpenWhisperSystems.Signal|End-to-end encrypted messenger.
Communications|Slack|SlackTechnologies.Slack|Team chat for work.
Communications|Teams|Microsoft.Teams|Microsoft Teams for work and school.
Communications|TeamSpeak 3|TeamSpeakSystems.TeamSpeakClient|Classic low-latency voice chat for gaming.
Communications|TeamSpeak 6|TeamSpeakSystems.TeamSpeakClient.Beta.6|New TeamSpeak client with modern interface.
Communications|Telegram|Telegram.TelegramDesktop|Fast cloud messenger.
Communications|Thunderbird|Mozilla.Thunderbird|Free email client from Mozilla.
Communications|Vesktop|Vencord.Vesktop|Discord client with Vencord mods and better screen share.
Communications|Viber|Rakuten.Viber|Messenger and calls.
Communications|WhatsApp Desktop|9NKSQGP7F2NH|WhatsApp for Windows (Microsoft Store).
Communications|Zoom|Zoom.Zoom|Video meetings.
Development|Bruno|Bruno.Bruno|Open-source API client, alternative to Postman.
Development|ChatGPT Desktop|9NT1R1C2HH7J|OpenAI ChatGPT app (Microsoft Store).
Development|Claude Desktop|Anthropic.Claude|Anthropic's Claude desktop app.
Development|Claude Code|Anthropic.ClaudeCode|Claude AI coding agent for the terminal.
Development|CMake|Kitware.CMake|Build system generator for C/C++.
Development|Codex|OpenAI.Codex|OpenAI coding agent for the terminal.
Development|Cursor|Anysphere.Cursor|AI-powered code editor based on VS Code.
Development|Docker Desktop|Docker.DockerDesktop|Run containers on Windows.
Development|Fast Node Manager|Schniz.fnm|Switch between Node.js versions quickly.
Development|Git|Git.Git|Version control system.
Development|Git Extensions|GitExtensionsTeam.GitExtensions|Graphical Git client.
Development|GitHub CLI|GitHub.cli|GitHub on the command line (gh).
Development|GitHub Desktop|GitHub.GitHubDesktop|Simple graphical Git client for GitHub.
Development|Go|GoLang.Go|Go programming language.
Development|Hugo|Hugo.Hugo.Extended|Fast static website generator.
Development|Amazon Corretto 21 (LTS)|Amazon.Corretto.21.JDK|Free Java 21 JDK from Amazon.
Development|Amazon Corretto 25 (LTS)|Amazon.Corretto.25.JDK|Free Java 25 JDK from Amazon.
Development|Amazon Corretto 8 (LTS)|Amazon.Corretto.8.JDK|Free Java 8 JDK from Amazon.
Development|Jetbrains Toolbox|JetBrains.Toolbox|Installs and updates JetBrains IDEs.
Development|Lazygit|JesseDuffield.lazygit|Terminal UI for Git.
Development|Lua|DEVCOM.Lua|Lua scripting language.
Development|Neovim|Neovim.Neovim|Modern Vim-based text editor.
Development|NodeJS|OpenJS.NodeJS|JavaScript runtime (current version).
Development|NodeJS LTS|OpenJS.NodeJS.LTS|JavaScript runtime (long-term support).
Development|Notepad++|Notepad++.Notepad++|Powerful text editor for code and notes.
Development|OpenCode|SST.opencode|Open-source AI coding agent for the terminal.
Development|pnpm|pnpm.pnpm|Fast, disk-saving Node.js package manager.
Development|Oh My Posh (Prompt)|JanDeDobbeleer.OhMyPosh|Pretty, informative shell prompt.
Development|Postman|Postman.Postman|API testing platform.
Development|Python3|Python.Python.3.13|Python programming language.
Development|Ruby|RubyInstallerTeam.RubyWithDevKit.3.4|Ruby language with DevKit.
Development|Rust|Rustlang.Rustup|Rust toolchain installer (rustup).
Development|Starship (Shell Prompt)|Starship.Starship|Fast, customizable shell prompt.
Development|Sublime Text|SublimeHQ.SublimeText.4|Fast, lightweight code editor.
Development|Unity Game Engine|Unity.UnityHub|Unity Hub to install the Unity game engine.
Development|uv|astral-sh.uv|Very fast Python package and project manager.
Development|Vagrant|Hashicorp.Vagrant|Build and manage virtual machine environments.
Development|Visual Studio 2022|Microsoft.VisualStudio.2022.Community|Microsoft's full IDE (Community edition).
Development|Visual Studio 2026|Microsoft.VisualStudio.Community|Newest Visual Studio IDE (Community edition).
Development|VS Code|Microsoft.VisualStudioCode|Popular free code editor.
Development|VS Codium|VSCodium.VSCodium|VS Code without Microsoft telemetry.
Development|Yarn|Yarn.Yarn|Node.js package manager.
Development|Zed|ZedIndustries.Zed|Very fast, modern code editor.
Document|Adobe Acrobat Reader|Adobe.Acrobat.Reader.64-bit|Official PDF reader from Adobe.
Document|Foxit PDF Reader|Foxit.FoxitReader|Fast PDF reader with annotation tools.
Document|Joplin|Joplin.Joplin|Open-source notes app with sync.
Document|LibreOffice|TheDocumentFoundation.LibreOffice|Free office suite (Writer, Calc, Impress).
Document|NAPS2 (Scanner)|Cyanfish.NAPS2|Simple document scanning to PDF.
Document|Obsidian|Obsidian.Obsidian|Markdown notes with linked knowledge base.
Document|Okular|KDE.Okular|Universal document viewer from KDE.
Document|ONLYOFFICE Desktop|ONLYOFFICE.DesktopEditors|Office suite very compatible with MS Office files.
Document|PDF24 Creator|geeksoftwareGmbH.PDF24Creator|Free all-in-one PDF toolbox.
Document|PDFgear|PDFgear.PDFgear|Free PDF editor and converter.
Document|PDFsam Basic|PDFsam.PDFsam|Split, merge and rotate PDF files.
Document|PDF-XChange Editor|TrackerSoftware.PDF-XChangeEditor|Feature-rich PDF viewer and editor.
Document|QOwnNotes|pbek.QOwnNotes|Markdown notes with Nextcloud integration.
Document|Simplenote|Automattic.Simplenote|Simple synced notes.
Document|Sumatra PDF|SumatraPDF.SumatraPDF|Tiny, very fast PDF and ebook reader.
Document|Xournal++|Xournal++.Xournal++|Handwritten notes and PDF annotation.
Document|Zotero|DigitalScholar.Zotero|Collect and cite research sources.
Games|Battle.net|Blizzard.BattleNet|Blizzard launcher (CoD, Overwatch, WoW, Diablo).
Games|Cemu|Cemu.Cemu|Wii U emulator.
Games|EA App|ElectronicArts.EADesktop|Launcher for EA games (Battlefield, FC, Apex).
Games|Epic Games Launcher|EpicGames.EpicGamesLauncher|Epic Games store with weekly free games.
Games|EmulationStation Desktop|ES-DE.EmulationStation-DE|Frontend for all your emulators in one place.
Games|GeForce NOW|Nvidia.GeForceNow|NVIDIA cloud gaming.
Games|GOG Galaxy|GOG.Galaxy|Launcher for DRM-free GOG games.
Games|Heroic Games Launcher|HeroicGamesLauncher.HeroicGamesLauncher|Open-source launcher for Epic, GOG and Amazon.
Games|Itch.io|ItchIo.Itch|Indie game store and launcher.
Games|Modrinth App|Modrinth.ModrinthApp|Minecraft launcher with mod management.
Games|CurseForge|Overwolf.CurseForge|Mod manager for Minecraft and more.
Games|Playnite|Playnite.Playnite|One library for all your game launchers.
Games|Prism Launcher|PrismLauncher.PrismLauncher|Open-source Minecraft launcher with multiple instances.
Games|Roblox|Roblox.Roblox|Roblox player.
Games|Steam|Valve.Steam|Valve's huge PC gaming platform.
Games|Ubisoft Connect|Ubisoft.Connect|Ubisoft game launcher.
Games|Virtual Desktop Streamer|VirtualDesktop.Streamer|Streams PC VR games wirelessly to Quest headsets.
Microsoft Tools|Autoruns|Microsoft.Sysinternals.Autoruns|Shows everything that starts with Windows.
Microsoft Tools|DISMTools|CodingWondersSoftware.DISMTools.Stable|GUI for DISM to edit Windows images.
Microsoft Tools|.NET Desktop Runtime 10|Microsoft.DotNet.DesktopRuntime.10|Needed by many Windows programs.
Microsoft Tools|.NET Desktop Runtime 6|Microsoft.DotNet.DesktopRuntime.6|Needed by older .NET programs.
Microsoft Tools|.NET Desktop Runtime 8|Microsoft.DotNet.DesktopRuntime.8|Needed by many Windows programs.
Microsoft Tools|.NET Desktop Runtime 9|Microsoft.DotNet.DesktopRuntime.9|Needed by many Windows programs.
Microsoft Tools|NTLite|Nlitesoft.NTLite|Customize and slim down Windows installation images.
Microsoft Tools|NuGet|Microsoft.NuGet|.NET package manager CLI.
Microsoft Tools|OneDrive|Microsoft.OneDrive|Microsoft cloud storage.
Microsoft Tools|PowerShell|Microsoft.PowerShell|Newest PowerShell 7.
Microsoft Tools|PowerToys|Microsoft.PowerToys|Microsoft toolbox: FancyZones, Color Picker and more.
Microsoft Tools|Process Explorer|Microsoft.Sysinternals.ProcessExplorer|Advanced Task Manager.
Microsoft Tools|Process Monitor|Microsoft.Sysinternals.ProcessMonitor|Live view of file, registry and process activity.
Microsoft Tools|PsTools|Microsoft.Sysinternals.PsTools|Command-line tools for remote administration.
Microsoft Tools|RDCMan|Microsoft.Sysinternals.RDCMan|Manage many Remote Desktop connections.
Microsoft Tools|TCPView|Microsoft.Sysinternals.TCPView|Shows all network connections live.
Microsoft Tools|Windows Terminal|Microsoft.WindowsTerminal|Modern terminal with tabs.
Microsoft Tools|Visual C++ 2015-2022 32-bit|Microsoft.VCRedist.2015+.x86|Runtime needed by many games and programs (32-bit).
Microsoft Tools|Visual C++ 2015-2022 64-bit|Microsoft.VCRedist.2015+.x64|Runtime needed by many games and programs (64-bit).
Multimedia Tools|AIMP (Music Player)|AIMP.AIMP|Lightweight music player.
Multimedia Tools|Audacity|Audacity.Audacity|Free audio editor and recorder.
Multimedia Tools|Blender (3D Graphics)|BlenderFoundation.Blender|Free 3D modeling, animation and rendering.
Multimedia Tools|Calibre|calibre.calibre|Ebook manager and converter.
Multimedia Tools|EarTrumpet (Audio)|File-New-Project.EarTrumpet|Better volume control per app.
Multimedia Tools|File Converter|AdrienAllard.FileConverter|Convert files from the right-click menu.
Multimedia Tools|foobar2000 (Music Player)|PeterPawlowski.foobar2000|Highly customizable audio player.
Multimedia Tools|GIMP (Image Editor)|GIMP.GIMP.3|Free image editor, Photoshop alternative.
Multimedia Tools|HandBrake|HandBrake.HandBrake|Convert and compress videos.
Multimedia Tools|ImageGlass (Image Viewer)|DuongDieuPhap.ImageGlass|Fast, modern image viewer.
Multimedia Tools|IrfanView|IrfanSkiljan.IrfanView|Classic fast image viewer.
Multimedia Tools|iTunes|Apple.iTunes|Apple music and device manager.
Multimedia Tools|K-Lite Codec Standard|CodecGuide.K-LiteCodecPack.Standard|Codec pack for nearly every video format.
Multimedia Tools|Media Player Classic - Home Cinema|clsid2.mpc-hc|Lightweight classic video player.
Multimedia Tools|mpc-qt|mpc-qt.mpc-qt|Modern MPC-style player based on mpv.
Multimedia Tools|mpv|shinchiro.mpv|Minimalist, high-quality video player.
Multimedia Tools|nomacs|nomacs.nomacs|Free image viewer.
Multimedia Tools|OBS Studio|OBSProject.OBSStudio|Free streaming and recording software.
Multimedia Tools|Paint.NET|dotPDN.PaintDotNet|Simple but powerful image editor.
Multimedia Tools|ShareX (Screenshots)|ShareX.ShareX|Screenshots, recordings and uploads.
Multimedia Tools|VLC (Video Player)|VideoLAN.VLC|Plays almost every video and audio format.
Pro Tools|Advanced IP Scanner|Famatech.AdvancedIPScanner|Finds all devices in your network.
Pro Tools|Angry IP Scanner|angryziber.AngryIPScanner|Fast network scanner.
Pro Tools|Cinebench R23|Maxon.CinebenchR23|CPU benchmark.
Pro Tools|CPU-Z|CPUID.CPU-Z|Shows CPU, RAM and mainboard details.
Pro Tools|Display Driver Uninstaller|Wagnardsoft.DisplayDriverUninstaller|Completely removes GPU drivers (DDU).
Pro Tools|GPU-Z|TechPowerUp.GPU-Z|Shows graphics card details and sensors.
Pro Tools|gsudo|gerardog.gsudo|sudo for Windows: run commands as admin.
Pro Tools|HWiNFO|REALiX.HWiNFO|All hardware info and sensors.
Pro Tools|HWMonitor|CPUID.HWMonitor|Temperatures, voltages and fan speeds.
Pro Tools|ImHex|WerWolv.ImHex|Hex editor for reverse engineering.
Pro Tools|MSI Afterburner|Guru3D.Afterburner|GPU overclocking and in-game FPS overlay.
Pro Tools|Mullvad VPN|MullvadVPN.MullvadVPN|Privacy-focused VPN.
Pro Tools|Nmap|Insecure.Nmap|Network scanner and security audit tool.
Pro Tools|OpenVPN Connect|OpenVPNTechnologies.OpenVPNConnect|Official OpenVPN client.
Pro Tools|Proton VPN|Proton.ProtonVPN|VPN from Proton with free tier.
Pro Tools|PuTTY|PuTTY.PuTTY|SSH and Telnet client.
Pro Tools|Rufus Imager|Rufus.Rufus|Create bootable USB sticks.
Pro Tools|Simplewall|Henry++.simplewall|Simple firewall that blocks unwanted connections.
Pro Tools|System Informer|WinsiderSS.SystemInformer|Powerful process and system monitor.
Pro Tools|Tailscale|Tailscale.Tailscale|Easy private network between your devices.
Pro Tools|Ventoy|Ventoy.Ventoy|USB stick that boots many ISO files.
Pro Tools|WinSCP|WinSCP.WinSCP|SFTP and FTP file transfer.
Pro Tools|WireGuard|WireGuard.WireGuard|Fast, modern VPN client.
Pro Tools|Wireshark|WiresharkFoundation.Wireshark|Network traffic analyzer.
Selfhosted Tools|Jellyfin Media Player|Jellyfin.JellyfinMediaPlayer|Client for your Jellyfin media server.
Selfhosted Tools|Jellyfin Server|Jellyfin.Server|Free self-hosted media server.
Selfhosted Tools|Kodi Media Center|XBMCFoundation.Kodi|Media center for movies, series and music.
Selfhosted Tools|LocalSend|LocalSend.LocalSend|Share files with nearby devices, no internet needed.
Selfhosted Tools|Moonlight/GameStream Client|MoonlightGameStreamingProject.Moonlight|Stream games from your PC to other devices.
Selfhosted Tools|NetBird|Netbird.Netbird|Self-hostable private network (WireGuard).
Selfhosted Tools|Nextcloud Desktop|Nextcloud.NextcloudDesktop|Sync client for Nextcloud.
Selfhosted Tools|Plex Media Server|Plex.PlexMediaServer|Media server for your library.
Selfhosted Tools|Plex Desktop|Plex.Plex|Plex player app.
Selfhosted Tools|Sunshine/GameStream Server|LizardByte.Sunshine|Game stream host for Moonlight.
Selfhosted Tools|Syncthing (CLI / Web UI)|Syncthing.Syncthing|Sync files between devices without a cloud.
Selfhosted Tools|SyncTrayzor|SyncTrayzor.SyncTrayzor|Tray app for Syncthing.
Utilities|1Password|AgileBits.1Password|Password manager.
Utilities|7-Zip|7zip.7zip|Free archiver for ZIP, RAR, 7z and more.
Utilities|AB Download Manager|amir1376.ABDownloadManager|Fast download manager.
Utilities|AnyDesk|AnyDesk.AnyDesk|Remote desktop access.
Utilities|AutoHotkey|AutoHotkey.AutoHotkey|Automate keys and macros with scripts.
Utilities|Bitwarden|Bitwarden.Bitwarden|Open-source password manager.
Utilities|BlurAutoClicker|Blur009.BlurAutoClicker|Simple auto clicker.
Utilities|Bulk Crap Uninstaller|Klocman.BulkCrapUninstaller|Remove many programs and leftovers at once.
Utilities|Cloudflare WARP|Cloudflare.Warp|Faster, more private internet via 1.1.1.1.
Utilities|Crystal Disk Info|CrystalDewWorld.CrystalDiskInfo|Shows SSD/HDD health and temperature.
Utilities|Crystal Disk Mark|CrystalDewWorld.CrystalDiskMark|SSD/HDD speed benchmark.
Utilities|Deskflow|Deskflow.Deskflow|Share one mouse and keyboard across PCs.
Utilities|Dropbox|Dropbox.Dropbox|Cloud storage.
Utilities|Ente Auth|ente-io.auth-desktop|Open-source 2FA authenticator.
Utilities|Everything|voidtools.Everything|Finds any file in milliseconds.
Utilities|Files|FilesCommunity.Files|Modern file manager for Windows.
Utilities|F.lux|flux.flux|Warms screen colors at night.
Utilities|GlazeWM|glzr-io.glazewm|Tiling window manager.
Utilities|Google Drive|Google.GoogleDrive|Google cloud storage.
Utilities|Internet Download Manager|Tonec.InternetDownloadManager|Popular download accelerator.
Utilities|JPEG View|sylikc.JPEGView|Lean, fast image viewer.
Utilities|KeePassXC|KeePassXCTeam.KeePassXC|Offline password manager.
Utilities|MiniTool Partition Wizard|MiniTool.PartitionWizard.Free|Manage disk partitions.
Utilities|MSEdgeRedirect|rcmaehl.MSEdgeRedirect|Opens Windows Edge links in your default browser.
Utilities|NanaZip|M2Team.NanaZip|Modern 7-Zip fork.
Utilities|Nilesoft Shell|Nilesoft.Shell|Customize the right-click menu.
Utilities|NVCleanstall|TechPowerUp.NVCleanstall|Install NVIDIA drivers without bloat.
Utilities|OFGB (Oh Frick Go Back)|xM4ddy.OFGB|Removes ads from Windows 11.
Utilities|OPAutoClicker|OPAutoClicker.OPAutoClicker|Auto clicker.
Utilities|OpenRGB|OpenRGB.OpenRGB|Control RGB lighting of all brands.
Utilities|Oracle VirtualBox|Oracle.VirtualBox|Run virtual machines.
Utilities|Parsec|Parsec.Parsec|Low-latency remote desktop and game streaming.
Utilities|PeaZip|Giorgiotani.Peazip|Free archiver.
Utilities|Policy Plus|Fleex255.PolicyPlus|Group policy editor, also for Windows Home.
Utilities|Process Lasso|BitSum.ProcessLasso|Automatic process priority optimization.
Utilities|Proton Authenticator|Proton.ProtonAuthenticator|2FA authenticator from Proton.
Utilities|Proton Drive|Proton.ProtonDrive|Encrypted cloud storage.
Utilities|Proton Pass|Proton.ProtonPass|Password manager from Proton.
Utilities|qBittorrent|qBittorrent.qBittorrent|Free, ad-free torrent client.
Utilities|Revo Uninstaller|RevoUninstaller.RevoUninstaller|Uninstall programs including leftovers.
Utilities|Snappy Driver Installer Origin|GlennDelahoy.SnappyDriverInstallerOrigin|Offline driver installer.
Utilities|SignalRGB|WhirlwindFX.SignalRgb|Sync RGB lighting across devices.
Utilities|StartAllBack|StartIsBack.StartAllBack|Classic Start menu and taskbar for Windows 11.
Utilities|TeamViewer|TeamViewer.TeamViewer|Remote support and access.
Utilities|TightVNC|GlavSoft.TightVNC|VNC remote control.
Utilities|Total Commander|Ghisler.TotalCommander|Two-panel file manager.
Utilities|TreeSize Free|JAMSoftware.TreeSize.Free|Shows what takes up disk space.
Utilities|TranslucentTB|CharlesMilette.TranslucentTB|Makes the taskbar transparent.
Utilities|UniGetUI|Devolutions.UniGetUI|GUI for winget, Scoop and Chocolatey.
Utilities|WinRAR|RARLab.WinRAR|Archiver for RAR and ZIP.
Utilities|Wise Program Uninstaller|WiseCleaner.WiseProgramUninstaller|Uninstall programs cleanly.
Utilities|WizTree|AntibodySoftware.WizTree|Very fast disk space analyzer.
Utilities|HxD Hex Editor|MHNexus.HxD|Fast hex editor.
'@

$AppGroups = @('Favorites', 'Browsers', 'Communications', 'Development', 'Document', 'Games', 'Microsoft Tools', 'Multimedia Tools', 'Pro Tools', 'Selfhosted Tools', 'Utilities')

$Apps = foreach ($line in ($AppList -split "`r?`n")) {
    if (-not $line.Trim()) { continue }
    $p = $line.Split('|')
    # Favorites repeat apps from other groups, so they get their own item id
    $prefix = if ($p[0] -eq 'Favorites') { 'app_fav_' } else { 'app_' }
    @{ Id = $prefix + $p[2]; Group = $p[0]; Name = $p[1]; WingetId = $p[2]; Desc = $p[3]
       Store = ($p[2] -match '^[0-9A-Z]{12}$') }
}
