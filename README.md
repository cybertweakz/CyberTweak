#  CYBERTWEAK

> simply tweakzz_

A modern Windows tweaker and optimizer with a clean cyber-style GUI. Pick what you want, read exactly what it does, and apply it in one click. Everything runs through PowerShell.

## Quick start

Open **PowerShell** (as administrator is best) and run:

```powershell
irm https://raw.githubusercontent.com/BrainDeadVibeC0der/Cybertweaker/main/win.ps1 | iex
```

This downloads the latest version to `%LOCALAPPDATA%\CyberTweak` and starts it. Your settings are kept between updates.

**Other ways to run it**

- **EXE:** download `CyberTweak.exe` from [Releases](https://github.com/BrainDeadVibeC0der/Cybertweaker/releases) and double-click it. It is a single file and needs nothing else.
- **ZIP:** download the repo and run `Start.bat`.

## Features

- **200+ tweaks.** They cover Performance, Gaming, Privacy, Debloat & UI, Preferences, Advanced, Network & DNS, Cleanup, Windows Features, Fixes, and classic Panels.
- **Every option explained.** Each tweak shows what it does, the technical commands, the benefit, the downside or risk, and whether it can be undone.
- **Status at a glance.** A checkmark shows tweaks that are already active and apps that are already installed.
- **Undo.** Most tweaks can be reverted to the Windows default with one click.
- **Restore point.** Before applying, a confirmation dialog appears where you can create a system restore point.
- **Presets.** *Recommended* (safe privacy and debloat) and *Gaming* (low latency, network and FPS tweaks).
- **250+ apps via winget.** Install apps in categories (Browsers, Gaming, Development, Multimedia, Utilities...) with their original logos and a Favorites list.
- **Windows Update profiles.** Choose Recommended, Windows Default or Disable Updates.
- **6 languages.** English, Deutsch, 中文, Français, Español and Русский.
- **5 themes and multiple fonts.** Cyber, Matrix, Synthwave, Amber and Crimson, with the Monocraft font by default.
- **Scales with the window.** Maximize the window and everything gets bigger.

## Requirements

- Windows 10 or 11
- Administrator rights (asked on start)
- winget (App Installer) for the Apps tab. *Fixes → Reinstall winget* can repair it.

## Safety

- Tweaks marked **SAFE** are low-risk. **MEDIUM** and **EXPERT** tweaks explain their trade-offs, so read them before applying.
- Cleanup actions delete files and cannot be undone.

## Credits

- Many tweaks are inspired by [Chris Titus Tech's WinUtil](https://github.com/ChrisTitusTech/winutil).
- The [Monocraft](https://github.com/IdreesInc/Monocraft) font is used under the SIL Open Font License (`fonts/OFL.txt`).
- App logos belong to their respective owners.

## Disclaimer

Use at your own risk. CyberTweak changes system settings. Create a restore point before applying large changes.
