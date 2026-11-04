<#
  CyberTweak - Windows tweaker / optimizer
  Start with Start.bat (asks for admin). Use -DryRun to only show what would run.
#>
param([switch]$DryRun)

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin -and -not $DryRun) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden', '-File', "`"$PSCommandPath`"")
    exit
}

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

try {

Add-Type -TypeDefinition @'
using System.ComponentModel;
public class CtItem : INotifyPropertyChanged {
    public event PropertyChangedEventHandler PropertyChanged;
    private void N(string p) { var h = PropertyChanged; if (h != null) h(this, new PropertyChangedEventArgs(p)); }
    public string Id { get; set; }
    public string Category { get; set; }
    public object Icon { get; set; }
    public string Initial { get; set; }
    public bool HasIcon { get { return Icon != null; } }
    public bool IsApp { get { return Category == "Apps"; } }
    private string _group;
    public string Group       { get { return _group; }       set { _group = value;       N("Group"); } }
    private string _state;
    public string State       { get { return _state; }       set { _state = value;       N("State"); } }
    private string _name, _badge, _badgeColor, _statusColor, _statusTip;
    private bool _isChecked;
    public string Name        { get { return _name; }        set { _name = value;        N("Name"); } }
    public string Badge       { get { return _badge; }       set { _badge = value;       N("Badge"); } }
    public string BadgeColor  { get { return _badgeColor; }  set { _badgeColor = value;  N("BadgeColor"); } }
    public string StatusColor { get { return _statusColor; } set { _statusColor = value; N("StatusColor"); } }
    public string StatusTip   { get { return _statusTip; }   set { _statusTip = value;   N("StatusTip"); } }
    public bool IsChecked     { get { return _isChecked; }   set { _isChecked = value;   N("IsChecked"); } }
}
'@

. "$Root\Helpers.ps1"
. "$Root\Tweaks.ps1"
. "$Root\TweaksExtra.ps1"
. "$Root\Apps.ps1"
$HelperCode = [IO.File]::ReadAllText("$Root\Helpers.ps1")
$Build = [int](Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').CurrentBuildNumber

# ------------------------------------------------------------------ languages
$LangCodes = @('en', 'de', 'zh', 'fr', 'es', 'ru')
$Langs = @{}
foreach ($c in $LangCodes) {
    $p = Join-Path $Root "lang\$c.json"
    if (Test-Path $p) { $Langs[$c] = [IO.File]::ReadAllText($p, [Text.Encoding]::UTF8) | ConvertFrom-Json }
}
if (-not $Langs['en']) { throw "lang\en.json is missing" }

$SettingsPath = Join-Path $Root 'settings.json'
$Lang = $null
$ThemeName = 'Cyber'
$FontName = 'Monocraft'
$Welcomed = $false
if (Test-Path $SettingsPath) {
    try {
        $s = [IO.File]::ReadAllText($SettingsPath) | ConvertFrom-Json
        $Lang = $s.lang
        if ($s.theme) { $ThemeName = $s.theme }
        if ($s.font) { $FontName = $s.font }
        $Welcomed = [bool]$s.welcomed
    } catch {}
}
if (-not $Lang -or -not $Langs[$Lang]) {
    $sys = (Get-UICulture).TwoLetterISOLanguageName
    $Lang = if ($Langs[$sys]) { $sys } else { 'en' }
}
$script:L = $Langs[$Lang]

function T([string]$k) {
    $v = $script:L.ui.$k
    if (-not $v) { $v = $Langs['en'].ui.$k }
    if (-not $v) { $v = $k }
    "$v"
}
function TX([string]$id, [string]$field) {
    $o = $script:L.tweaks.$id
    $v = if ($o) { $o.$field }
    if (-not $v) { $o = $Langs['en'].tweaks.$id; if ($o) { $v = $o.$field } }
    "$v"
}
function TA([string]$id) {
    $d = $Defs[$id]
    $v = $script:L.apps.($d.WingetId)
    if (-not $v) { $v = $d.Desc }
    "$v"
}
function Get-WingetCmd($d, [string]$mode) {
    $src = if ($d.Store) { ' --source msstore' } else { '' }
    if ($mode -eq 'Apply') { "winget install --id $($d.WingetId) -e$src --silent --accept-source-agreements --accept-package-agreements" }
    else { "winget uninstall --id $($d.WingetId) -e$src --silent --accept-source-agreements" }
}

# ------------------------------------------------------------------ items
$Categories = @('Performance', 'Gaming', 'Privacy', 'Debloat', 'Preferences', 'Advanced', 'Network', 'Cleanup', 'Features', 'Fixes', 'Panels', 'Apps')

# Colour themes (Log tab > DESIGN). Keys match the brush resources in the XAML.
$Themes = [ordered]@{
  Cyber     = @{ Bg='#0B0F14'; Deep='#080B0F'; Panel='#10161E'; Info='#0D1218'; Line='#1E2A36'; LineHover='#2C3E50'; Accent='#00E5FF'; AccentHover='#7DF3FF'; AccentPress='#00B8CC'; AccentText='#05080B'; Hot='#FF2E88'; Text='#C9D6E3'; Muted='#5C6F82'; Dim='#3A4A5A'; HoverBg='#0E141B'; HoverBg2='#16202B'; SelBg='#0C1A22'; PressBg='#0A2A30'; Thumb='#26394A'; Code='#7FA7C0'; LogText='#8FB3C8'; Ok='#2EE59D'; Warn='#FFB020'; Overlay='#D905080B' }
  Matrix    = @{ Bg='#050A07'; Deep='#030604'; Panel='#0A140D'; Info='#07100A'; Line='#163322'; LineHover='#22503A'; Accent='#39FF6A'; AccentHover='#8CFFA8'; AccentPress='#22C94A'; AccentText='#031006'; Hot='#FF5555'; Text='#B9F5C9'; Muted='#4E8060'; Dim='#2F5440'; HoverBg='#0B1A10'; HoverBg2='#10241A'; SelBg='#0A2414'; PressBg='#0C3018'; Thumb='#1E4A2E'; Code='#7CC79A'; LogText='#8CE0A8'; Ok='#39FF6A'; Warn='#E8D44D'; Overlay='#D9020603' }
  Synthwave = @{ Bg='#0F0A1A'; Deep='#0A0612'; Panel='#170F26'; Info='#120B1F'; Line='#2C1B47'; LineHover='#43296B'; Accent='#FF4FD8'; AccentHover='#FF9BEA'; AccentPress='#D93AB5'; AccentText='#14061A'; Hot='#FFD23F'; Text='#E6D9FF'; Muted='#8670B0'; Dim='#54417A'; HoverBg='#1A1130'; HoverBg2='#22163D'; SelBg='#24123A'; PressBg='#3A1747'; Thumb='#3D2763'; Code='#B79CE8'; LogText='#C9B2F2'; Ok='#3DF5C4'; Warn='#FFD23F'; Overlay='#D90A0612' }
  Amber     = @{ Bg='#0E0B06'; Deep='#0A0804'; Panel='#18130A'; Info='#120E07'; Line='#33281A'; LineHover='#4D3D24'; Accent='#FFB000'; AccentHover='#FFD066'; AccentPress='#D99500'; AccentText='#120D02'; Hot='#FF5A36'; Text='#F2E2C4'; Muted='#8F7A55'; Dim='#5C4C33'; HoverBg='#1A140B'; HoverBg2='#241C10'; SelBg='#241A08'; PressBg='#33260A'; Thumb='#4A3A20'; Code='#D9B57A'; LogText='#E8C88E'; Ok='#9BE15D'; Warn='#FFB000'; Overlay='#D90A0804' }
  Crimson   = @{ Bg='#0E080A'; Deep='#0A0507'; Panel='#180D11'; Info='#120A0D'; Line='#35191F'; LineHover='#52262F'; Accent='#FF3B55'; AccentHover='#FF8A9A'; AccentPress='#D92A42'; AccentText='#14040A'; Hot='#FFC145'; Text='#F2D9DD'; Muted='#93636C'; Dim='#5E3B42'; HoverBg='#1B0E12'; HoverBg2='#26131A'; SelBg='#2A0F17'; PressBg='#3A111C'; Thumb='#4A2028'; Code='#E0A0AA'; LogText='#EDB8C0'; Ok='#4CE0A0'; Warn='#FFC145'; Overlay='#D90A0507' }
}
$RiskColor  = @{ Safe = '#2EE59D'; Medium = '#FFB020'; Advanced = '#FF2E88' }
$StateColor = @{ active = '#2EE59D'; default = '#33475A'; unknown = '#1E2A36'; na = 'Transparent' }

$Items = New-Object System.Collections.Generic.List[object]
$Defs = @{}
$ItemById = @{}
foreach ($t in $Tweaks) {
    $i = New-Object CtItem
    $i.Id = $t.Id; $i.Category = $t.Cat
    $i.BadgeColor = $RiskColor[$t.Risk]
    $i.State = if ($t.Check) { 'unknown' } else { 'na' }
    $Items.Add($i); $Defs[$t.Id] = $t; $ItemById[$t.Id] = $i
}
foreach ($a in $Apps) {
    $i = New-Object CtItem
    $i.Id = $a.Id; $i.Category = 'Apps'
    $i.BadgeColor = '#00E5FF'
    $i.State = 'unknown'
    $a.IsApp = $true
    # original app logo from icons\<WingetId>.png, otherwise the first letter is shown
    $ip = Join-Path $Root "icons\$($a.WingetId).png"
    if (Test-Path -LiteralPath $ip) {
        try {
            $bi = New-Object Windows.Media.Imaging.BitmapImage
            $bi.BeginInit(); $bi.CacheOption = 'OnLoad'; $bi.UriSource = [Uri]$ip; $bi.EndInit(); $bi.Freeze()
            $i.Icon = $bi
        } catch {}
    }
    $i.Initial = "$($a.Name)".Substring(0, 1).ToUpper()
    $Items.Add($i); $Defs[$a.Id] = $a; $ItemById[$a.Id] = $i
}

$HistoryPath = Join-Path $Root 'history.json'
$History = New-Object 'System.Collections.Generic.HashSet[string]'
if (Test-Path $HistoryPath) {
    try { foreach ($h in @([IO.File]::ReadAllText($HistoryPath) | ConvertFrom-Json)) { [void]$History.Add("$h") } } catch {}
}
foreach ($h in $History) { if ($ItemById[$h] -and -not $Defs[$h].IsApp) { $ItemById[$h].State = 'active' } }

# ------------------------------------------------------------------ XAML
[xml]$Xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="CyberTweak" Width="1220" Height="760" MinWidth="1120" MinHeight="620"
        WindowStartupLocation="CenterScreen" WindowStyle="None" ResizeMode="CanResize"
        Background="{DynamicResource Bg}" Foreground="{DynamicResource Text}" FontSize="12"
        TextOptions.TextFormattingMode="Display" UseLayoutRounding="True" SnapsToDevicePixels="True">
  <WindowChrome.WindowChrome>
    <WindowChrome CaptionHeight="42" ResizeBorderThickness="6" GlassFrameThickness="0" CornerRadius="0" UseAeroCaptionButtons="False"/>
  </WindowChrome.WindowChrome>
  <Window.Resources>
    <!-- theme brushes, filled from $Themes by Set-Theme -->
    <SolidColorBrush x:Key="Overlay" Color="#000000"/>
    <SolidColorBrush x:Key="Bg" Color="#000000"/>
    <SolidColorBrush x:Key="Deep" Color="#000000"/>
    <SolidColorBrush x:Key="Panel" Color="#000000"/>
    <SolidColorBrush x:Key="Info" Color="#000000"/>
    <SolidColorBrush x:Key="Line" Color="#000000"/>
    <SolidColorBrush x:Key="LineHover" Color="#000000"/>
    <SolidColorBrush x:Key="Accent" Color="#000000"/>
    <SolidColorBrush x:Key="AccentHover" Color="#000000"/>
    <SolidColorBrush x:Key="AccentPress" Color="#000000"/>
    <SolidColorBrush x:Key="AccentText" Color="#000000"/>
    <SolidColorBrush x:Key="Hot" Color="#000000"/>
    <SolidColorBrush x:Key="Text" Color="#000000"/>
    <SolidColorBrush x:Key="Muted" Color="#000000"/>
    <SolidColorBrush x:Key="Dim" Color="#000000"/>
    <SolidColorBrush x:Key="HoverBg" Color="#000000"/>
    <SolidColorBrush x:Key="HoverBg2" Color="#000000"/>
    <SolidColorBrush x:Key="SelBg" Color="#000000"/>
    <SolidColorBrush x:Key="PressBg" Color="#000000"/>
    <SolidColorBrush x:Key="Thumb" Color="#000000"/>
    <SolidColorBrush x:Key="Code" Color="#000000"/>
    <SolidColorBrush x:Key="LogText" Color="#000000"/>
    <SolidColorBrush x:Key="Ok" Color="#000000"/>
    <SolidColorBrush x:Key="Warn" Color="#000000"/>

    <Style x:Key="Chip" TargetType="RadioButton">
      <Setter Property="Foreground" Value="{DynamicResource Muted}"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="FontSize" Value="11"/>
      <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="RadioButton">
            <Border x:Name="b" BorderBrush="{DynamicResource Line}" BorderThickness="1" Padding="10,5" Margin="0,0,6,0" Background="Transparent">
              <ContentPresenter/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter Property="Foreground" Value="{DynamicResource Text}"/>
              </Trigger>
              <Trigger Property="IsChecked" Value="True">
                <Setter TargetName="b" Property="BorderBrush" Value="{DynamicResource Accent}"/>
                <Setter Property="Foreground" Value="{DynamicResource Accent}"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="Swatch" TargetType="RadioButton">
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="RadioButton">
            <Border x:Name="b" Width="22" Height="22" Padding="4" Margin="0,0,5,0" BorderThickness="1" BorderBrush="{DynamicResource Line}" Background="Transparent">
              <ContentPresenter/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="b" Property="BorderBrush" Value="{DynamicResource Muted}"/>
              </Trigger>
              <Trigger Property="IsChecked" Value="True">
                <Setter TargetName="b" Property="BorderBrush" Value="{DynamicResource Text}"/>
                <Setter TargetName="b" Property="Padding" Value="3"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="Card" TargetType="Border">
      <Setter Property="Background" Value="{DynamicResource Panel}"/>
      <Setter Property="BorderBrush" Value="{DynamicResource Line}"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="Padding" Value="18,16"/>
      <Setter Property="MinHeight" Value="300"/>
    </Style>

    <Style x:Key="Btn" TargetType="Button">
      <Setter Property="Foreground" Value="{DynamicResource Text}"/>
      <Setter Property="Background" Value="Transparent"/>
      <Setter Property="BorderBrush" Value="{DynamicResource Line}"/>
      <Setter Property="Padding" Value="16,8"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="b" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="1" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="b" Property="BorderBrush" Value="{DynamicResource Accent}"/>
                <Setter Property="Foreground" Value="{DynamicResource Accent}"/>
              </Trigger>
              <Trigger Property="IsPressed" Value="True">
                <Setter TargetName="b" Property="Background" Value="{DynamicResource PressBg}"/>
              </Trigger>
              <Trigger Property="IsEnabled" Value="False">
                <Setter Property="Opacity" Value="0.35"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="BtnPrimary" TargetType="Button">
      <Setter Property="Foreground" Value="{DynamicResource AccentText}"/>
      <Setter Property="Padding" Value="22,8"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="b" Background="{DynamicResource Accent}" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="b" Property="Background" Value="{DynamicResource AccentHover}"/>
              </Trigger>
              <Trigger Property="IsPressed" Value="True">
                <Setter TargetName="b" Property="Background" Value="{DynamicResource AccentPress}"/>
              </Trigger>
              <Trigger Property="IsEnabled" Value="False">
                <Setter Property="Opacity" Value="0.35"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="Cap" TargetType="Button">
      <Setter Property="Foreground" Value="{DynamicResource Muted}"/>
      <Setter Property="Width" Value="46"/>
      <Setter Property="Height" Value="42"/>
      <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
      <Setter Property="WindowChrome.IsHitTestVisibleInChrome" Value="True"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="b" Background="Transparent">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="b" Property="Background" Value="{DynamicResource HoverBg2}"/>
                <Setter Property="Foreground" Value="{DynamicResource Text}"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="CapClose" TargetType="Button" BasedOn="{StaticResource Cap}">
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="b" Background="Transparent">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="b" Property="Background" Value="{DynamicResource Hot}"/>
                <Setter Property="Foreground" Value="{DynamicResource AccentText}"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="LangBtn" TargetType="RadioButton">
      <Setter Property="Foreground" Value="{DynamicResource Muted}"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="FontSize" Value="11"/>
      <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
      <Setter Property="WindowChrome.IsHitTestVisibleInChrome" Value="True"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="RadioButton">
            <Border x:Name="b" BorderBrush="Transparent" BorderThickness="1" Padding="7,3" Margin="2,0" Background="Transparent">
              <ContentPresenter/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter Property="Foreground" Value="{DynamicResource Text}"/>
              </Trigger>
              <Trigger Property="IsChecked" Value="True">
                <Setter TargetName="b" Property="BorderBrush" Value="{DynamicResource Accent}"/>
                <Setter Property="Foreground" Value="{DynamicResource Accent}"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="LangDrop" TargetType="ToggleButton">
      <Setter Property="Foreground" Value="{DynamicResource Text}"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="FontSize" Value="11"/>
      <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
      <Setter Property="WindowChrome.IsHitTestVisibleInChrome" Value="True"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="ToggleButton">
            <Border x:Name="b" BorderBrush="{DynamicResource Line}" BorderThickness="1" Padding="10,4" Background="Transparent">
              <ContentPresenter/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="b" Property="BorderBrush" Value="{DynamicResource Accent}"/>
                <Setter Property="Foreground" Value="{DynamicResource Accent}"/>
              </Trigger>
              <Trigger Property="IsChecked" Value="True">
                <Setter TargetName="b" Property="BorderBrush" Value="{DynamicResource Accent}"/>
                <Setter Property="Foreground" Value="{DynamicResource Accent}"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="LangItem" TargetType="RadioButton">
      <Setter Property="Foreground" Value="{DynamicResource Text}"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="FontSize" Value="12"/>
      <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="RadioButton">
            <Border x:Name="b" Background="Transparent" BorderThickness="2,0,0,0" BorderBrush="Transparent" Padding="12,7">
              <ContentPresenter/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="b" Property="Background" Value="{DynamicResource HoverBg2}"/>
              </Trigger>
              <Trigger Property="IsChecked" Value="True">
                <Setter Property="Foreground" Value="{DynamicResource Accent}"/>
                <Setter TargetName="b" Property="BorderBrush" Value="{DynamicResource Accent}"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="Nav" TargetType="RadioButton">
      <Setter Property="Foreground" Value="{DynamicResource Muted}"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="FontSize" Value="12"/>
      <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="RadioButton">
            <Border x:Name="b" Background="Transparent" BorderThickness="2,0,0,0" BorderBrush="Transparent" Padding="20,7">
              <ContentPresenter/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter Property="Foreground" Value="{DynamicResource Text}"/>
                <Setter TargetName="b" Property="Background" Value="{DynamicResource HoverBg}"/>
              </Trigger>
              <Trigger Property="IsChecked" Value="True">
                <Setter Property="Foreground" Value="{DynamicResource Accent}"/>
                <Setter TargetName="b" Property="BorderBrush" Value="{DynamicResource Accent}"/>
                <Setter TargetName="b" Property="Background" Value="{DynamicResource SelBg}"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style TargetType="CheckBox">
      <Setter Property="Foreground" Value="{DynamicResource Text}"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="CheckBox">
            <StackPanel Orientation="Horizontal" Background="Transparent">
              <Border x:Name="box" Width="16" Height="16" BorderThickness="1" BorderBrush="{DynamicResource Dim}" Background="{DynamicResource Bg}" VerticalAlignment="Center">
                <Rectangle x:Name="mark" Width="8" Height="8" Fill="{DynamicResource Accent}" Visibility="Collapsed"/>
              </Border>
              <ContentPresenter x:Name="cp" Margin="9,0,0,0" VerticalAlignment="Center"/>
            </StackPanel>
            <ControlTemplate.Triggers>
              <Trigger Property="IsChecked" Value="True">
                <Setter TargetName="mark" Property="Visibility" Value="Visible"/>
                <Setter TargetName="box" Property="BorderBrush" Value="{DynamicResource Accent}"/>
              </Trigger>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="box" Property="BorderBrush" Value="{DynamicResource Accent}"/>
              </Trigger>
              <Trigger Property="Content" Value="{x:Null}">
                <Setter TargetName="cp" Property="Margin" Value="0"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style TargetType="ScrollBar">
      <Setter Property="Width" Value="8"/>
      <Setter Property="MinWidth" Value="8"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="ScrollBar">
            <Border Background="Transparent">
              <Track x:Name="PART_Track" IsDirectionReversed="True">
                <Track.Thumb>
                  <Thumb>
                    <Thumb.Template>
                      <ControlTemplate TargetType="Thumb">
                        <Border Background="{DynamicResource Thumb}" Margin="2"/>
                      </ControlTemplate>
                    </Thumb.Template>
                  </Thumb>
                </Track.Thumb>
              </Track>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="Orientation" Value="Horizontal">
                <Setter TargetName="PART_Track" Property="IsDirectionReversed" Value="False"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
      <Style.Triggers>
        <Trigger Property="Orientation" Value="Horizontal">
          <Setter Property="Width" Value="Auto"/>
          <Setter Property="MinWidth" Value="0"/>
          <Setter Property="Height" Value="8"/>
        </Trigger>
      </Style.Triggers>
    </Style>

    <Style x:Key="Input" TargetType="TextBox">
      <Setter Property="Background" Value="{DynamicResource Panel}"/>
      <Setter Property="Foreground" Value="{DynamicResource Text}"/>
      <Setter Property="BorderBrush" Value="{DynamicResource Line}"/>
      <Setter Property="CaretBrush" Value="{DynamicResource Accent}"/>
      <Setter Property="SelectionBrush" Value="{DynamicResource Accent}"/>
      <Setter Property="Padding" Value="8,7"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="TextBox">
            <Border x:Name="b" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="1">
              <ScrollViewer x:Name="PART_ContentHost" Margin="{TemplateBinding Padding}"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsKeyboardFocused" Value="True">
                <Setter TargetName="b" Property="BorderBrush" Value="{DynamicResource Accent}"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style TargetType="ProgressBar">
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="ProgressBar">
            <Grid>
              <Border x:Name="PART_Track" Background="{DynamicResource Panel}" BorderBrush="{DynamicResource Line}" BorderThickness="1"/>
              <Border x:Name="PART_Indicator" Background="{DynamicResource Accent}" HorizontalAlignment="Left"/>
            </Grid>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="Row" TargetType="ListBoxItem">
      <Setter Property="Foreground" Value="{DynamicResource Text}"/>
      <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
      <Setter Property="HorizontalContentAlignment" Value="Stretch"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="ListBoxItem">
            <Border x:Name="b" Background="{DynamicResource Panel}" BorderBrush="{DynamicResource Line}" BorderThickness="1" Padding="14,11" Margin="0,0,10,6">
              <ContentPresenter/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="b" Property="BorderBrush" Value="{DynamicResource LineHover}"/>
              </Trigger>
              <Trigger Property="IsSelected" Value="True">
                <Setter TargetName="b" Property="BorderBrush" Value="{DynamicResource Accent}"/>
                <Setter TargetName="b" Property="Background" Value="{DynamicResource SelBg}"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
      <Style.Triggers>
        <Trigger Property="IsKeyboardFocusWithin" Value="True">
          <Setter Property="IsSelected" Value="True"/>
        </Trigger>
      </Style.Triggers>
    </Style>

    <Style x:Key="H" TargetType="TextBlock">
      <Setter Property="Foreground" Value="{DynamicResource Muted}"/>
      <Setter Property="FontSize" Value="11"/>
      <Setter Property="Margin" Value="0,20,0,7"/>
    </Style>
    <Style x:Key="P" TargetType="TextBlock">
      <Setter Property="Foreground" Value="{DynamicResource Text}"/>
      <Setter Property="TextWrapping" Value="Wrap"/>
      <Setter Property="LineHeight" Value="19"/>
    </Style>
  </Window.Resources>

  <Border x:Name="RootBorder" BorderBrush="{DynamicResource Line}" BorderThickness="1" Background="{DynamicResource Bg}">
    <Grid>
      <Grid.RowDefinitions>
        <RowDefinition Height="42"/>
        <RowDefinition Height="*"/>
        <RowDefinition Height="Auto"/>
      </Grid.RowDefinitions>

      <!-- title bar -->
      <Border x:Name="TitleArea" Grid.Row="0" Background="{DynamicResource Deep}" BorderBrush="{DynamicResource Line}" BorderThickness="0,0,0,1">
        <DockPanel LastChildFill="False">
          <StackPanel DockPanel.Dock="Left" Orientation="Horizontal" VerticalAlignment="Center" Margin="18,0,0,0">
            <Rectangle Width="10" Height="10" Fill="{DynamicResource Accent}" Margin="0,0,12,0">
              <Rectangle.Effect><DropShadowEffect x:Name="LogoGlow1" Color="#00E5FF" BlurRadius="14" ShadowDepth="0" Opacity="0.9"/></Rectangle.Effect>
            </Rectangle>
            <TextBlock x:Name="LogoCyber" Text="CYBER" FontSize="15" FontWeight="Bold" Foreground="{DynamicResource Text}"/>
            <TextBlock x:Name="LogoTweak" Text="TWEAK" FontSize="15" FontWeight="Bold" Foreground="{DynamicResource Accent}">
              <TextBlock.Effect><DropShadowEffect x:Name="LogoGlow2" Color="#00E5FF" BlurRadius="12" ShadowDepth="0" Opacity="0.85"/></TextBlock.Effect>
            </TextBlock>
            <Border x:Name="DryBadge" BorderBrush="{DynamicResource Hot}" BorderThickness="1" Padding="6,1" Margin="14,0,0,0" Visibility="Collapsed" VerticalAlignment="Center">
              <TextBlock Text="DRY-RUN" FontSize="10" Foreground="{DynamicResource Hot}"/>
            </Border>
          </StackPanel>
          <StackPanel DockPanel.Dock="Right" Orientation="Horizontal">
            <!-- design + font dropdowns -->
            <StackPanel Orientation="Horizontal" VerticalAlignment="Center" Margin="0,0,8,0" WindowChrome.IsHitTestVisibleInChrome="True">
              <Grid VerticalAlignment="Center" Margin="0,0,8,0">
                <ToggleButton x:Name="ThemeToggle" Style="{StaticResource LangDrop}" ToolTip="Design">
                  <StackPanel Orientation="Horizontal">
                    <Rectangle Width="11" Height="11" Fill="{DynamicResource Accent}" VerticalAlignment="Center"/>
                    <Path Data="M0,0 L4,4 L8,0" StrokeThickness="1.5" Margin="9,1,0,0" VerticalAlignment="Center"
                          Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType=ToggleButton}}"/>
                  </StackPanel>
                </ToggleButton>
                <Popup PlacementTarget="{Binding ElementName=ThemeToggle}" Placement="Bottom" VerticalOffset="4"
                       IsOpen="{Binding IsChecked, ElementName=ThemeToggle, Mode=TwoWay}" StaysOpen="False" AllowsTransparency="True">
                  <Border Background="{DynamicResource Panel}" BorderBrush="{DynamicResource Accent}" BorderThickness="1" Padding="4" MinWidth="150">
                    <StackPanel>
                      <RadioButton x:Name="Theme_Cyber" GroupName="theme" Style="{StaticResource LangItem}">
                        <StackPanel Orientation="Horizontal"><Rectangle Width="10" Height="10" Fill="#00E5FF" Margin="0,0,9,0" VerticalAlignment="Center"/><TextBlock Text="Cyber"/></StackPanel>
                      </RadioButton>
                      <RadioButton x:Name="Theme_Matrix" GroupName="theme" Style="{StaticResource LangItem}">
                        <StackPanel Orientation="Horizontal"><Rectangle Width="10" Height="10" Fill="#39FF6A" Margin="0,0,9,0" VerticalAlignment="Center"/><TextBlock Text="Matrix"/></StackPanel>
                      </RadioButton>
                      <RadioButton x:Name="Theme_Synthwave" GroupName="theme" Style="{StaticResource LangItem}">
                        <StackPanel Orientation="Horizontal"><Rectangle Width="10" Height="10" Fill="#FF4FD8" Margin="0,0,9,0" VerticalAlignment="Center"/><TextBlock Text="Synthwave"/></StackPanel>
                      </RadioButton>
                      <RadioButton x:Name="Theme_Amber" GroupName="theme" Style="{StaticResource LangItem}">
                        <StackPanel Orientation="Horizontal"><Rectangle Width="10" Height="10" Fill="#FFB000" Margin="0,0,9,0" VerticalAlignment="Center"/><TextBlock Text="Amber"/></StackPanel>
                      </RadioButton>
                      <RadioButton x:Name="Theme_Crimson" GroupName="theme" Style="{StaticResource LangItem}">
                        <StackPanel Orientation="Horizontal"><Rectangle Width="10" Height="10" Fill="#FF3B55" Margin="0,0,9,0" VerticalAlignment="Center"/><TextBlock Text="Crimson"/></StackPanel>
                      </RadioButton>
                    </StackPanel>
                  </Border>
                </Popup>
              </Grid>
              <Grid VerticalAlignment="Center">
                <ToggleButton x:Name="FontToggle" Style="{StaticResource LangDrop}" MinWidth="120" ToolTip="Font">
                  <DockPanel>
                    <Path DockPanel.Dock="Right" Data="M0,0 L4,4 L8,0" StrokeThickness="1.5" Margin="10,1,0,0" VerticalAlignment="Center"
                          Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType=ToggleButton}}"/>
                    <TextBlock x:Name="FontCurrent" Text="Monocraft" VerticalAlignment="Center"/>
                  </DockPanel>
                </ToggleButton>
                <Popup PlacementTarget="{Binding ElementName=FontToggle}" Placement="Bottom" VerticalOffset="4"
                       IsOpen="{Binding IsChecked, ElementName=FontToggle, Mode=TwoWay}" StaysOpen="False" AllowsTransparency="True">
                  <Border Background="{DynamicResource Panel}" BorderBrush="{DynamicResource Accent}" BorderThickness="1" Padding="4" MinWidth="170">
                    <StackPanel x:Name="FontList"/>
                  </Border>
                </Popup>
              </Grid>
            </StackPanel>
            <Border Width="1" Height="18" Background="{DynamicResource Line}" Margin="0,0,8,0" VerticalAlignment="Center"/>
            <Grid VerticalAlignment="Center" Margin="0,0,16,0">
              <ToggleButton x:Name="LangToggle" Style="{StaticResource LangDrop}">
                <StackPanel Orientation="Horizontal">
                  <TextBlock x:Name="LangCurrent" Text="EN" VerticalAlignment="Center"/>
                  <Path Data="M0,0 L4,4 L8,0" StrokeThickness="1.5" Margin="9,1,0,0" VerticalAlignment="Center"
                        Stroke="{Binding Foreground, RelativeSource={RelativeSource AncestorType=ToggleButton}}"/>
                </StackPanel>
              </ToggleButton>
              <Popup x:Name="LangPopup" PlacementTarget="{Binding ElementName=LangToggle}" Placement="Bottom" VerticalOffset="4"
                     IsOpen="{Binding IsChecked, ElementName=LangToggle, Mode=TwoWay}" StaysOpen="False" AllowsTransparency="True">
                <Border Background="{DynamicResource Panel}" BorderBrush="{DynamicResource Accent}" BorderThickness="1" Padding="4" MinWidth="140">
                  <StackPanel>
                    <RadioButton x:Name="Lang_en" GroupName="lang" Style="{StaticResource LangItem}"/>
                    <RadioButton x:Name="Lang_de" GroupName="lang" Style="{StaticResource LangItem}"/>
                    <RadioButton x:Name="Lang_zh" GroupName="lang" Style="{StaticResource LangItem}"/>
                    <RadioButton x:Name="Lang_fr" GroupName="lang" Style="{StaticResource LangItem}"/>
                    <RadioButton x:Name="Lang_es" GroupName="lang" Style="{StaticResource LangItem}"/>
                  <RadioButton x:Name="Lang_ru" GroupName="lang" Style="{StaticResource LangItem}"/>
                  </StackPanel>
                </Border>
              </Popup>
            </Grid>
            <Button x:Name="BtnMin" Content="_" Style="{StaticResource Cap}"/>
            <Button x:Name="BtnMax" Content="[ ]" Style="{StaticResource Cap}"/>
            <Button x:Name="BtnClose" Content="X" Style="{StaticResource CapClose}"/>
          </StackPanel>
        </DockPanel>
      </Border>

      <!-- main -->
      <Grid x:Name="MainArea" Grid.Row="1">
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="210"/>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="380"/>
        </Grid.ColumnDefinitions>

        <!-- sidebar -->
        <Border Grid.Column="0" Background="{DynamicResource Deep}" BorderBrush="{DynamicResource Line}" BorderThickness="0,0,1,0">
          <DockPanel>
            <StackPanel DockPanel.Dock="Bottom" Margin="20,0,16,18">
              <TextBlock x:Name="SysOs" FontSize="10" Foreground="{DynamicResource Muted}" TextWrapping="Wrap"/>
              <TextBlock x:Name="SysAdmin" FontSize="10" Margin="0,5,0,0"/>
            </StackPanel>
            <StackPanel Margin="0,12,0,0">
              <TextBlock Tag="i18n:menu" FontSize="10" Foreground="{DynamicResource Dim}" Margin="22,0,0,6"/>
              <RadioButton x:Name="Nav_Performance" Tag="i18n:cat_Performance" GroupName="nav" Style="{StaticResource Nav}" IsChecked="True"/>
              <RadioButton x:Name="Nav_Gaming" Tag="i18n:cat_Gaming" GroupName="nav" Style="{StaticResource Nav}"/>
              <RadioButton x:Name="Nav_Privacy" Tag="i18n:cat_Privacy" GroupName="nav" Style="{StaticResource Nav}"/>
              <RadioButton x:Name="Nav_Debloat" Tag="i18n:cat_Debloat" GroupName="nav" Style="{StaticResource Nav}"/>
              <RadioButton x:Name="Nav_Preferences" Tag="i18n:cat_Preferences" GroupName="nav" Style="{StaticResource Nav}"/>
              <RadioButton x:Name="Nav_Advanced" Tag="i18n:cat_Advanced" GroupName="nav" Style="{StaticResource Nav}"/>
              <RadioButton x:Name="Nav_Network" Tag="i18n:cat_Network" GroupName="nav" Style="{StaticResource Nav}"/>
              <RadioButton x:Name="Nav_Cleanup" Tag="i18n:cat_Cleanup" GroupName="nav" Style="{StaticResource Nav}"/>
              <RadioButton x:Name="Nav_Features" Tag="i18n:cat_Features" GroupName="nav" Style="{StaticResource Nav}"/>
              <RadioButton x:Name="Nav_Fixes" Tag="i18n:cat_Fixes" GroupName="nav" Style="{StaticResource Nav}"/>
              <RadioButton x:Name="Nav_Panels" Tag="i18n:cat_Panels" GroupName="nav" Style="{StaticResource Nav}"/>
              <RadioButton x:Name="Nav_Updates" Tag="i18n:cat_Updates" GroupName="nav" Style="{StaticResource Nav}"/>
              <RadioButton x:Name="Nav_Apps" Tag="i18n:cat_Apps" GroupName="nav" Style="{StaticResource Nav}"/>
              <Border Height="1" Background="{DynamicResource Line}" Margin="20,8"/>
              <RadioButton x:Name="Nav_Log" Tag="i18n:cat_Log" GroupName="nav" Style="{StaticResource Nav}"/>
            </StackPanel>
          </DockPanel>
        </Border>

        <!-- list -->
        <Grid x:Name="ListArea" Grid.Column="1" Margin="24,20,14,0">
          <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
          </Grid.RowDefinitions>
          <Grid Margin="0,0,10,16">
            <Grid.ColumnDefinitions>
              <ColumnDefinition Width="*"/>
              <ColumnDefinition Width="Auto"/>
              <ColumnDefinition Width="210"/>
            </Grid.ColumnDefinitions>
            <StackPanel VerticalAlignment="Center">
              <TextBlock x:Name="CatTitle" FontSize="20" FontWeight="Bold" Foreground="{DynamicResource Text}"/>
              <TextBlock x:Name="CatSub" FontSize="11" Foreground="{DynamicResource Muted}" Margin="0,5,0,0" TextWrapping="Wrap"/>
            </StackPanel>
            <Grid x:Name="SearchWrap" Grid.Column="2" VerticalAlignment="Center">
              <TextBox x:Name="SearchBox" Style="{StaticResource Input}"/>
              <TextBlock x:Name="SearchHint" Tag="i18n:search" Foreground="{DynamicResource Dim}" IsHitTestVisible="False" Margin="11,0,0,0" VerticalAlignment="Center"/>
            </Grid>
          </Grid>
          <WrapPanel x:Name="GroupBar" Grid.Row="1" Margin="0,0,10,8" Visibility="Collapsed"/>
          <ListBox x:Name="List" Grid.Row="2" Background="Transparent" BorderThickness="0"
                   ItemContainerStyle="{StaticResource Row}"
                   ScrollViewer.HorizontalScrollBarVisibility="Disabled" HorizontalContentAlignment="Stretch">
            <ListBox.GroupStyle>
              <GroupStyle>
                <GroupStyle.HeaderTemplate>
                  <DataTemplate>
                    <TextBlock Text="{Binding Name, StringFormat='- {0}'}" Foreground="{DynamicResource Accent}" FontSize="13" Margin="0,14,0,8"/>
                  </DataTemplate>
                </GroupStyle.HeaderTemplate>
              </GroupStyle>
            </ListBox.GroupStyle>
            <ListBox.ItemTemplate>
              <DataTemplate>
                <Grid>
                  <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="Auto"/>
                  </Grid.ColumnDefinitions>
                  <CheckBox IsChecked="{Binding IsChecked, Mode=TwoWay}" VerticalAlignment="Center" Margin="0,0,14,0"/>
                  <DockPanel Grid.Column="1">
                    <Grid x:Name="appIcon" DockPanel.Dock="Left" Width="20" Height="20" Margin="0,0,10,0" VerticalAlignment="Center" Visibility="Collapsed">
                      <Border x:Name="iconFallback" BorderBrush="{DynamicResource Line}" BorderThickness="1" Background="{DynamicResource HoverBg2}">
                        <TextBlock Text="{Binding Initial}" FontSize="11" Foreground="{DynamicResource Accent}" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                      </Border>
                      <Image x:Name="iconImg" Source="{Binding Icon}" RenderOptions.BitmapScalingMode="HighQuality" Visibility="Collapsed"/>
                    </Grid>
                    <TextBlock Text="{Binding Name}" VerticalAlignment="Center" TextTrimming="CharacterEllipsis"/>
                  </DockPanel>
                  <Border Grid.Column="2" BorderBrush="{Binding BadgeColor}" BorderThickness="1" Padding="6,1" Margin="12,0" VerticalAlignment="Center">
                    <TextBlock Text="{Binding Badge}" Foreground="{Binding BadgeColor}" FontSize="10"/>
                  </Border>
                  <Grid Grid.Column="3" Width="14" Height="14" VerticalAlignment="Center" Background="Transparent" ToolTip="{Binding StatusTip}">
                    <Rectangle x:Name="dot" Width="8" Height="8" Fill="{Binding StatusColor}"/>
                    <Path x:Name="tick" Data="M1,7 L5,11 L13,2" Stroke="{DynamicResource Ok}" StrokeThickness="2.5" Visibility="Collapsed"/>
                  </Grid>
                </Grid>
                <DataTemplate.Triggers>
                  <DataTrigger Binding="{Binding State}" Value="active">
                    <Setter TargetName="dot" Property="Visibility" Value="Collapsed"/>
                    <Setter TargetName="tick" Property="Visibility" Value="Visible"/>
                  </DataTrigger>
                  <DataTrigger Binding="{Binding IsApp}" Value="True">
                    <Setter TargetName="appIcon" Property="Visibility" Value="Visible"/>
                  </DataTrigger>
                  <DataTrigger Binding="{Binding HasIcon}" Value="True">
                    <Setter TargetName="iconFallback" Property="Visibility" Value="Collapsed"/>
                    <Setter TargetName="iconImg" Property="Visibility" Value="Visible"/>
                  </DataTrigger>
                </DataTemplate.Triggers>
              </DataTemplate>
            </ListBox.ItemTemplate>
          </ListBox>
          <DockPanel x:Name="LogPanel" Grid.Row="1" Grid.RowSpan="2" Visibility="Collapsed">
            <TextBox x:Name="LogBox" Style="{StaticResource Input}" IsReadOnly="True" TextWrapping="Wrap" AcceptsReturn="True"
                     VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled" FontSize="11"
                     Foreground="{DynamicResource LogText}" Background="{DynamicResource Deep}" Margin="0,0,10,18"/>
          </DockPanel>
        </Grid>

        <!-- windows update profiles -->
        <ScrollViewer x:Name="UpdatesView" Grid.Column="1" Grid.ColumnSpan="2" Visibility="Collapsed" Background="{DynamicResource Bg}"
                      VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
          <StackPanel Margin="28,22,28,22">
            <TextBlock Tag="i18n:cat_Updates" FontSize="20" FontWeight="Bold" Foreground="{DynamicResource Text}"/>
            <TextBlock Tag="i18n:catsub_Updates" FontSize="11" Foreground="{DynamicResource Muted}" Margin="0,5,0,18" TextWrapping="Wrap"/>
            <UniformGrid Columns="3">
              <Border x:Name="UpdCardRec" Style="{StaticResource Card}" Margin="0,0,10,0">
                <DockPanel>
                  <Button x:Name="UpdBtnRec" DockPanel.Dock="Bottom" Tag="i18n:upd_rec_btn" Style="{StaticResource Btn}" HorizontalAlignment="Center" Margin="0,18,0,0"/>
                  <StackPanel>
                    <TextBlock Tag="i18n:upd_rec_title" FontSize="17" FontWeight="Bold" Foreground="{DynamicResource Text}" TextWrapping="Wrap"/>
                    <TextBlock Tag="i18n:upd_rec_sub" Foreground="{DynamicResource Muted}" Margin="0,4,0,12" TextWrapping="Wrap"/>
                    <TextBlock Tag="i18n:upd_rec_list" Style="{StaticResource P}" FontSize="11"/>
                    <TextBlock Tag="i18n:upd_rec_note" Style="{StaticResource P}" FontSize="10" FontStyle="Italic" Foreground="{DynamicResource Muted}" Margin="0,10,0,0"/>
                  </StackPanel>
                </DockPanel>
              </Border>
              <Border x:Name="UpdCardDef" Style="{StaticResource Card}" Margin="5,0,5,0">
                <DockPanel>
                  <Button x:Name="UpdBtnDef" DockPanel.Dock="Bottom" Tag="i18n:upd_def_btn" Style="{StaticResource Btn}" HorizontalAlignment="Center" Margin="0,18,0,0"/>
                  <StackPanel>
                    <TextBlock Tag="i18n:upd_def_title" FontSize="17" FontWeight="Bold" Foreground="{DynamicResource Text}" TextWrapping="Wrap"/>
                    <TextBlock Tag="i18n:upd_def_sub" Foreground="{DynamicResource Muted}" Margin="0,4,0,12" TextWrapping="Wrap"/>
                    <TextBlock Tag="i18n:upd_def_list" Style="{StaticResource P}" FontSize="11"/>
                    <TextBlock Tag="i18n:upd_def_note" Style="{StaticResource P}" FontSize="10" FontStyle="Italic" Foreground="{DynamicResource Muted}" Margin="0,10,0,0"/>
                  </StackPanel>
                </DockPanel>
              </Border>
              <Border x:Name="UpdCardDis" Style="{StaticResource Card}" Margin="10,0,0,0">
                <DockPanel>
                  <Button x:Name="UpdBtnDis" DockPanel.Dock="Bottom" Tag="i18n:upd_dis_btn" Style="{StaticResource Btn}" Foreground="{DynamicResource Hot}" HorizontalAlignment="Center" Margin="0,18,0,0"/>
                  <StackPanel>
                    <TextBlock Tag="i18n:upd_dis_title" FontSize="17" FontWeight="Bold" Foreground="{DynamicResource Hot}" TextWrapping="Wrap"/>
                    <TextBlock Tag="i18n:upd_dis_sub" Foreground="{DynamicResource Hot}" Margin="0,4,0,12" TextWrapping="Wrap"/>
                    <TextBlock Tag="i18n:upd_dis_list" Style="{StaticResource P}" FontSize="11"/>
                    <TextBlock Tag="i18n:upd_dis_note" Style="{StaticResource P}" FontSize="10" FontStyle="Italic" Foreground="{DynamicResource Hot}" Margin="0,10,0,0"/>
                  </StackPanel>
                </DockPanel>
              </Border>
            </UniformGrid>
            <Border BorderBrush="{DynamicResource Line}" BorderThickness="1" Background="{DynamicResource Panel}" Padding="14,10" Margin="0,16,0,0">
              <TextBlock Tag="i18n:upd_footer" FontSize="11" Foreground="{DynamicResource Muted}" TextWrapping="Wrap" HorizontalAlignment="Center" TextAlignment="Center"/>
            </Border>
          </StackPanel>
        </ScrollViewer>

        <!-- info panel -->
        <Border x:Name="InfoArea" Grid.Column="2" Background="{DynamicResource Info}" BorderBrush="{DynamicResource Line}" BorderThickness="1,0,0,0">
          <Grid>
          <StackPanel x:Name="InfoEmpty" HorizontalAlignment="Center" VerticalAlignment="Center" Margin="30,0,30,40">
            <Border Width="92" Height="92" BorderBrush="{DynamicResource Line}" BorderThickness="2" HorizontalAlignment="Center">
              <TextBlock x:Name="InfoEmptyMark" Text="?" FontSize="54" FontWeight="Bold" Foreground="{DynamicResource Dim}" HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <TextBlock Tag="i18n:select_hint" FontSize="11" Foreground="{DynamicResource Muted}" TextWrapping="Wrap" TextAlignment="Center" Margin="0,18,0,0" MaxWidth="230"/>
          </StackPanel>
          <ScrollViewer x:Name="InfoScroll" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
            <StackPanel Margin="24,22,22,22">
              <TextBlock Tag="i18n:info_header" FontSize="10" Foreground="{DynamicResource Dim}"/>
              <TextBlock x:Name="InfoTitle" FontSize="16" FontWeight="Bold" Foreground="{DynamicResource Accent}" TextWrapping="Wrap" Margin="0,10,0,0"/>
              <WrapPanel x:Name="InfoMeta" Margin="0,12,0,0">
                <Border x:Name="InfoBadge" BorderThickness="1" Padding="6,1" Margin="0,0,8,6">
                  <TextBlock x:Name="InfoBadgeText" FontSize="10"/>
                </Border>
                <Border BorderBrush="{DynamicResource Line}" BorderThickness="1" Padding="6,1" Margin="0,0,8,6">
                  <StackPanel Orientation="Horizontal">
                    <Rectangle x:Name="InfoStatusDot" Width="6" Height="6" Margin="0,0,6,0" VerticalAlignment="Center"/>
                    <TextBlock x:Name="InfoStatusText" FontSize="10" Foreground="{DynamicResource Muted}"/>
                  </StackPanel>
                </Border>
              </WrapPanel>
              <StackPanel x:Name="InfoBody">
                <TextBlock Tag="i18n:info_what" Style="{StaticResource H}"/>
                <TextBlock x:Name="InfoWhat" Style="{StaticResource P}"/>
                <TextBlock Tag="i18n:info_tech" Style="{StaticResource H}"/>
                <Border Background="{DynamicResource Deep}" BorderBrush="{DynamicResource Line}" BorderThickness="1" Padding="10,8">
                  <TextBlock x:Name="InfoTech" FontSize="10" Foreground="{DynamicResource Code}" TextWrapping="Wrap" LineHeight="16"/>
                </Border>
                <StackPanel x:Name="InfoProBox">
                  <TextBlock Tag="i18n:info_pro" Style="{StaticResource H}" Foreground="{DynamicResource Ok}"/>
                  <TextBlock x:Name="InfoPro" Style="{StaticResource P}"/>
                </StackPanel>
                <StackPanel x:Name="InfoContraBox">
                  <TextBlock Tag="i18n:info_contra" Style="{StaticResource H}" Foreground="{DynamicResource Warn}"/>
                  <TextBlock x:Name="InfoContra" Style="{StaticResource P}"/>
                </StackPanel>
                <TextBlock Tag="i18n:info_undo" Style="{StaticResource H}"/>
                <TextBlock x:Name="InfoUndo" Style="{StaticResource P}"/>
                <TextBlock x:Name="InfoNeeds" Style="{StaticResource P}" Foreground="{DynamicResource Hot}" Margin="0,12,0,0"/>
              </StackPanel>
            </StackPanel>
          </ScrollViewer>
          </Grid>
        </Border>
      </Grid>

      <!-- footer -->
      <Border x:Name="FooterArea" Grid.Row="2" Background="{DynamicResource Deep}" BorderBrush="{DynamicResource Line}" BorderThickness="0,1,0,0" Padding="18,12">
        <Grid>
          <Grid.ColumnDefinitions>
            <ColumnDefinition Width="Auto"/>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="Auto"/>
          </Grid.ColumnDefinitions>
          <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
            <TextBlock Tag="i18n:presets" FontSize="11" Foreground="{DynamicResource Muted}" VerticalAlignment="Center" Margin="0,0,10,0"/>
            <Button x:Name="BtnPresetRec" Tag="i18n:preset_recommended" Style="{StaticResource Btn}" Padding="10,6" FontSize="11" Margin="0,0,6,0"/>
            <Button x:Name="BtnPresetGame" Tag="i18n:preset_gaming" Style="{StaticResource Btn}" Padding="10,6" FontSize="11" Margin="0,0,6,0"/>
            <Button x:Name="BtnPresetClear" Tag="i18n:preset_clear" Style="{StaticResource Btn}" Padding="10,6" FontSize="11"/>
          </StackPanel>
          <ProgressBar x:Name="Progress" Grid.Column="1" Height="6" Minimum="0" Maximum="100" Value="0" Margin="22,0" VerticalAlignment="Center"/>
          <StackPanel Grid.Column="2" Orientation="Horizontal">
            <TextBlock x:Name="SelCount" FontSize="11" Foreground="{DynamicResource Muted}" VerticalAlignment="Center" Margin="0,0,14,0"/>
            <Button x:Name="BtnUndo" Tag="i18n:btn_undo" Style="{StaticResource Btn}" Margin="0,0,8,0"/>
            <Button x:Name="BtnApply" Tag="i18n:btn_apply" Style="{StaticResource BtnPrimary}" FontWeight="Bold"/>
          </StackPanel>
        </Grid>
      </Border>

      <!-- dialog overlay -->
      <Grid x:Name="Overlay" Grid.RowSpan="3" Background="{DynamicResource Overlay}" Visibility="Collapsed">
        <Border Width="580" MaxHeight="540" HorizontalAlignment="Center" VerticalAlignment="Center" Background="{DynamicResource Panel}" BorderBrush="{DynamicResource Accent}" BorderThickness="1" Padding="26,22">
          <DockPanel>
            <TextBlock x:Name="OvTitle" DockPanel.Dock="Top" FontSize="16" FontWeight="Bold" Foreground="{DynamicResource Accent}" TextWrapping="Wrap" Margin="0,0,0,14"/>
            <DockPanel DockPanel.Dock="Bottom" Margin="0,20,0,0">
              <StackPanel DockPanel.Dock="Right" Orientation="Horizontal">
                <Button x:Name="OvCancel" Tag="i18n:btn_cancel" Style="{StaticResource Btn}" Margin="0,0,8,0"/>
                <Button x:Name="OvOk" Tag="i18n:btn_ok" Style="{StaticResource BtnPrimary}"/>
              </StackPanel>
              <CheckBox x:Name="OvRestore" Tag="i18n:restore_point" IsChecked="True" FontSize="11" VerticalAlignment="Center"/>
            </DockPanel>
            <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
              <TextBlock x:Name="OvBody" TextWrapping="Wrap" LineHeight="19"/>
            </ScrollViewer>
          </DockPanel>
        </Border>
      </Grid>

      <!-- welcome screen (first start) -->
      <Grid x:Name="Welcome" Grid.RowSpan="3" Background="{DynamicResource Bg}" Visibility="Collapsed" Cursor="Hand"
            WindowChrome.IsHitTestVisibleInChrome="True">
        <StackPanel HorizontalAlignment="Center" VerticalAlignment="Center">
          <TextBlock x:Name="WelcomeTop" Text="W E L C O M E   T O" FontSize="20" Foreground="{DynamicResource Muted}" HorizontalAlignment="Center" Margin="0,0,0,18"/>
          <StackPanel x:Name="WelcomeLogo" Orientation="Horizontal" HorizontalAlignment="Center">
            <Rectangle Width="46" Height="46" Fill="{DynamicResource Accent}" Margin="0,0,30,0" VerticalAlignment="Center">
              <Rectangle.Effect><DropShadowEffect Color="#00E5FF" BlurRadius="50" ShadowDepth="0" Opacity="0.9"/></Rectangle.Effect>
            </Rectangle>
            <TextBlock Text="CYBER" FontSize="86" FontWeight="Bold" Foreground="{DynamicResource Text}"/>
            <TextBlock Text="TWEAK" FontSize="86" FontWeight="Bold" Foreground="{DynamicResource Accent}">
              <TextBlock.Effect><DropShadowEffect Color="#00E5FF" BlurRadius="45" ShadowDepth="0" Opacity="0.85"/></TextBlock.Effect>
            </TextBlock>
          </StackPanel>
          <TextBlock x:Name="WelcomeSlogan" Text="&gt; simply tweakzz_" FontSize="24" Foreground="{DynamicResource Hot}" HorizontalAlignment="Center" Margin="0,22,0,0"/>
          <Border Height="1" Width="460" Background="{DynamicResource Line}" Margin="0,24,0,20"/>
          <TextBlock Tag="i18n:welcome_sub" FontSize="14" Foreground="{DynamicResource Muted}" HorizontalAlignment="Center"/>
          <TextBlock x:Name="WelcomeHint" Tag="i18n:welcome_hint" FontSize="12" Foreground="{DynamicResource Accent}" HorizontalAlignment="Center" Margin="0,56,0,0"/>
        </StackPanel>
      </Grid>
    </Grid>
  </Border>
</Window>
'@

$Window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $Xaml))
$UI = @{}
foreach ($n in $Xaml.SelectNodes('//*[@*[local-name()="Name"]]')) {
    $name = $n.GetAttribute('Name', 'http://schemas.microsoft.com/winfx/2006/xaml')
    if ($name) { $UI[$name] = $Window.FindName($name) }
}

$FontDir = New-Object Uri((Join-Path $Root 'fonts') + '\')
$MonoFont = New-Object Windows.Media.FontFamily($FontDir, './#Monocraft, Microsoft YaHei UI, Consolas')
# UI fonts (Log tab > FONT). Monocraft ships with CyberTweak, the others come with Windows.
# Every entry falls back to Microsoft YaHei UI for Chinese.
$Fonts = [ordered]@{
  Monocraft = $MonoFont
  Cascadia  = New-Object Windows.Media.FontFamily('Cascadia Mono, Consolas, Microsoft YaHei UI')
  Consolas  = New-Object Windows.Media.FontFamily('Consolas, Microsoft YaHei UI')
  Bahnschrift = New-Object Windows.Media.FontFamily('Bahnschrift, Segoe UI, Microsoft YaHei UI')
  Segoe     = New-Object Windows.Media.FontFamily('Segoe UI, Microsoft YaHei UI')
}
$FontLabels = @{ Monocraft = 'Monocraft'; Cascadia = 'Cascadia Mono'; Consolas = 'Consolas'; Bahnschrift = 'Bahnschrift'; Segoe = 'Segoe UI' }
# the logo always keeps the Minecraft look, whatever font is chosen
foreach ($n in 'LogoCyber', 'LogoTweak') { $UI[$n].FontFamily = $MonoFont }
foreach ($t in $UI.WelcomeLogo.Children) { if ($t -is [Windows.Controls.TextBlock]) { $t.FontFamily = $MonoFont } }
$UI.WelcomeTop.FontFamily = $MonoFont; $UI.WelcomeSlogan.FontFamily = $MonoFont
$UI.InfoEmptyMark.FontFamily = $MonoFont

foreach ($k in $Fonts.Keys) {
    $rb = New-Object Windows.Controls.RadioButton
    $rb.Style = $Window.FindResource('LangItem')
    $rb.GroupName = 'font'
    $rb.Name = "Font_$k"
    $rb.Content = $FontLabels[$k]
    $rb.FontFamily = $Fonts[$k]
    $rb.Add_Click({ param($sender, $e) $UI.FontToggle.IsChecked = $false; Set-Font $sender.Name.Substring(5) })
    [void]$UI.FontList.Children.Add($rb)
    $UI["Font_$k"] = $rb
}

function Set-Font([string]$name) {
    if (-not $Fonts.Contains($name)) { $name = 'Monocraft' }
    $script:FontName = $name
    $Window.FontFamily = $Fonts[$name]
    $UI["Font_$name"].IsChecked = $true
    $UI.FontCurrent.Text = $FontLabels[$name]
    $UI.FontCurrent.FontFamily = $Fonts[$name]
    Save-Settings
}

if ($DryRun) { $UI.DryBadge.Visibility = 'Visible' }
$os = (Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue).Caption
$UI.SysOs.Text = "$os`nBuild $Build"

# ------------------------------------------------------------------ logging
$LogDir = Join-Path $Root 'logs'
$LogFile = Join-Path $LogDir ("CyberTweak_{0}.log" -f (Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'))
function Write-Log([string]$text) {
    $UI.LogBox.AppendText($text + "`r`n")
    $UI.LogBox.ScrollToEnd()
    try {
        if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir | Out-Null }
        [IO.File]::AppendAllText($LogFile, $text + "`r`n", [Text.Encoding]::UTF8)
    } catch {}
}

# ------------------------------------------------------------------ UI helpers
function Set-I18n($node) {
    if ($node -is [Windows.FrameworkElement] -and "$($node.Tag)" -like 'i18n:*') {
        $k = "$($node.Tag)".Substring(5)
        if ($node -is [Windows.Controls.TextBlock]) { $node.Text = T $k }
        elseif ($node -is [Windows.Controls.ContentControl]) { $node.Content = T $k }
    }
    foreach ($c in [Windows.LogicalTreeHelper]::GetChildren($node)) {
        if ($c -is [Windows.DependencyObject]) { Set-I18n $c }
    }
}

function Set-State($item, [string]$state) {
    $item.State = $state
    $item.StatusColor = $StateColor[$state]
    $item.StatusTip = T "status_$state"
}

function Update-ItemTexts {
    foreach ($i in $Items) {
        $d = $Defs[$i.Id]
        if ($d.IsApp) {
            $i.Name = $d.Name
            $i.Badge = if ($d.Store) { 'STORE' } else { 'WINGET' }
            $i.BadgeColor = $Themes[$script:ThemeName].Accent
            $g = $script:L.ui."grp_$($d.Group)"
            $i.Group = if ($g) { $g } else { $d.Group }
        } else {
            $i.Name = TX $i.Id 'name'
            $i.Badge = T "risk_$($d.Risk)"
        }
        Set-State $i $i.State
    }
}

# Undo only makes sense for ticked items that are already active and can be reverted.
function Get-UndoItems {
    @($Items | Where-Object { $_.IsChecked -and $_.State -eq 'active' -and ($Defs[$_.Id].IsApp -or $Defs[$_.Id].Undo) })
}

function Update-Count {
    $n = @($Items | Where-Object { $_.IsChecked }).Count
    $UI.SelCount.Text = (T 'selected') -f $n
    $UI.BtnUndo.Visibility = if ((Get-UndoItems).Count) { 'Visible' } else { 'Collapsed' }
}

function Test-ItemMatch($item, [string]$q) {
    if ($item.Name -and $item.Name.IndexOf($q, [StringComparison]::OrdinalIgnoreCase) -ge 0) { return $true }
    $desc = if ($Defs[$item.Id].IsApp) { TA $item.Id } else { TX $item.Id 'desc' }
    $desc.IndexOf($q, [StringComparison]::OrdinalIgnoreCase) -ge 0
}

function Show-List {
    $isLog = ($script:CurCat -eq 'Log')
    $isUpd = ($script:CurCat -eq 'Updates')
    $UI.GroupBar.Visibility = 'Collapsed'
    $UI.UpdatesView.Visibility = if ($isUpd) { 'Visible' } else { 'Collapsed' }
    $UI.ListArea.Visibility = if ($isUpd) { 'Collapsed' } else { 'Visible' }
    $UI.InfoArea.Visibility = if ($isUpd) { 'Collapsed' } else { 'Visible' }
    if ($isUpd) { Update-UpdateCards; return }
    $UI.List.Visibility = if ($isLog) { 'Collapsed' } else { 'Visible' }
    $UI.LogPanel.Visibility = if ($isLog) { 'Visible' } else { 'Collapsed' }
    $UI.SearchWrap.Visibility = if ($isLog) { 'Collapsed' } else { 'Visible' }
    if ($isLog) {
        $UI.CatTitle.Text = T 'cat_Log'
        $UI.CatSub.Text = T 'catsub_Log'
        return
    }
    $q = $UI.SearchBox.Text.Trim()
    if ($q) {
        $src = @($Items | Where-Object { Test-ItemMatch $_ $q })
        $UI.CatTitle.Text = T 'search_results'
        $UI.CatSub.Text = (T 'search_count') -f $src.Count
    } else {
        $src = @($Items | Where-Object { $_.Category -eq $script:CurCat })
        $UI.CatTitle.Text = T "cat_$($script:CurCat)"
        $UI.CatSub.Text = T "catsub_$($script:CurCat)"
    }
    $script:Shown = $src
    $UI.List.ItemsSource = $src
    $UI.List.Items.GroupDescriptions.Clear()
    $grouped = (-not $q -and $script:CurCat -eq 'Apps')
    $UI.GroupBar.Visibility = if ($grouped) { 'Visible' } else { 'Collapsed' }
    if ($grouped) {
        $UI.List.Items.GroupDescriptions.Add((New-Object Windows.Data.PropertyGroupDescription 'Group'))
        Update-GroupBar
    }
}

# Apps tab: one small button per group that jumps to that group's header
function Update-GroupBar {
    $UI.GroupBar.Children.Clear()
    foreach ($g in $AppGroups) {
        $b = New-Object Windows.Controls.Button
        $b.Style = $Window.FindResource('Btn')
        $b.Padding = '9,4'
        $b.FontSize = 10
        $b.Margin = '0,0,6,6'
        $label = $script:L.ui."grp_$g"
        $b.Content = if ($label) { $label } else { $g }
        $b.Tag = $g
        $b.Add_Click({ param($sender, $e) Jump-ToGroup $sender.Tag })
        [void]$UI.GroupBar.Children.Add($b)
    }
}

function Get-ListScroller {
    $o = $UI.List
    while ($o -and -not ($o -is [Windows.Controls.ScrollViewer])) {
        if ([Windows.Media.VisualTreeHelper]::GetChildrenCount($o) -eq 0) { return $null }
        $o = [Windows.Media.VisualTreeHelper]::GetChild($o, 0)
    }
    $o
}

function Jump-ToGroup([string]$group) {
    $first = $null
    foreach ($i in $Items) { if ($i.Category -eq 'Apps' -and $Defs[$i.Id].Group -eq $group) { $first = $i; break } }
    if (-not $first) { return }
    $sv = Get-ListScroller
    $UI.List.UpdateLayout()
    $c = $UI.List.ItemContainerGenerator.ContainerFromItem($first)
    if (-not $sv -or -not $c) { $UI.List.ScrollIntoView($first); return }
    # offset of the item inside the scrolled content, minus room for the group header
    $y = $c.TransformToAncestor($sv).Transform((New-Object Windows.Point 0, 0)).Y
    $sv.ScrollToVerticalOffset([math]::Max(0, $sv.VerticalOffset + $y - 44))
}

function Show-Info($item) {
    $script:InfoItem = $item
    $UI.InfoEmpty.Visibility = if ($item) { 'Collapsed' } else { 'Visible' }
    $UI.InfoScroll.Visibility = if ($item) { 'Visible' } else { 'Collapsed' }
    if (-not $item) { return }
    $d = $Defs[$item.Id]
    $UI.InfoMeta.Visibility = 'Visible'
    $UI.InfoBody.Visibility = 'Visible'
    $UI.InfoTitle.Text = $item.Name
    $UI.InfoBadge.BorderBrush = $item.BadgeColor
    $UI.InfoBadgeText.Foreground = $item.BadgeColor
    $UI.InfoBadgeText.Text = $item.Badge
    $UI.InfoStatusDot.Fill = if ($item.State -eq 'na') { $StateColor.default } else { $StateColor[$item.State] }
    $UI.InfoStatusText.Text = if ($d.IsApp -and $item.State -eq 'active') { T 'status_installed' }
                              elseif ($d.IsApp -and $item.State -eq 'default') { T 'status_not_installed' }
                              else { T "status_$($item.State)" }
    if ($d.IsApp) {
        $UI.InfoWhat.Text = TA $item.Id
        $UI.InfoTech.Text = Get-WingetCmd $d 'Apply'
        $UI.InfoProBox.Visibility = 'Collapsed'
        $UI.InfoContraBox.Visibility = 'Collapsed'
        $UI.InfoUndo.Text = T 'undo_app'
        $UI.InfoNeeds.Text = ''
    } else {
        $UI.InfoWhat.Text = TX $item.Id 'desc'
        $UI.InfoTech.Text = $d.Tech
        $UI.InfoPro.Text = TX $item.Id 'pro'
        $UI.InfoContra.Text = TX $item.Id 'contra'
        $UI.InfoProBox.Visibility = if ($UI.InfoPro.Text) { 'Visible' } else { 'Collapsed' }
        $UI.InfoContraBox.Visibility = if ($UI.InfoContra.Text) { 'Visible' } else { 'Collapsed' }
        $UI.InfoUndo.Text = if ($d.Undo) { T 'undo_yes' } elseif ($d.Cat -eq 'Cleanup') { T 'undo_no' } else { T 'undo_na' }
        $notes = @()
        if ($d.Needs) { $notes += T "needs_$($d.Needs)" }
        if ($d.MinBuild -and $Build -lt $d.MinBuild) { $notes += (T 'min_build') -f $d.MinBuild }
        $UI.InfoNeeds.Text = $notes -join "`n"
    }
}

function Set-Lang([string]$code) {
    if (-not $Langs[$code]) { return }
    $script:Lang = $code
    $script:L = $Langs[$code]
    $UI["Lang_$code"].IsChecked = $true
    $UI.LangCurrent.Text = $code.ToUpper()
    Set-I18n $Window
    Update-ItemTexts
    Show-List
    Show-Info $script:InfoItem
    Update-Count
    $UI.SysAdmin.Text = if ($IsAdmin) { T 'admin_yes' } else { T 'admin_no' }
    $UI.SysAdmin.Foreground = if ($IsAdmin) { '#2EE59D' } else { '#FF2E88' }
    Save-Settings
}

function Save-Settings {
    try { [IO.File]::WriteAllText($SettingsPath, (@{ lang = $script:Lang; theme = $script:ThemeName; font = $script:FontName; welcomed = [bool]$script:Welcomed } | ConvertTo-Json)) } catch {}
}

# Welcome screen: shown once on the very first start. The app behind it starts blurred;
# any key or click fades the welcome out while blurring it and un-blurs the app.
$WelcomeParts = @('TitleArea', 'MainArea', 'FooterArea')
function Show-Welcome {
    $UI.Welcome.Visibility = 'Visible'
    foreach ($n in $WelcomeParts) { $b = New-Object Windows.Media.Effects.BlurEffect; $b.Radius = 18; $UI[$n].Effect = $b }
    $pulse = New-Object Windows.Media.Animation.DoubleAnimation(1, 0.25, (New-Object Windows.Duration ([TimeSpan]::FromMilliseconds(1100))))
    $pulse.AutoReverse = $true
    $pulse.RepeatBehavior = [Windows.Media.Animation.RepeatBehavior]::Forever
    $UI.WelcomeHint.BeginAnimation([Windows.UIElement]::OpacityProperty, $pulse)
}

function Hide-Welcome {
    if ($script:WelcomeClosing -or $UI.Welcome.Visibility -ne 'Visible') { return }
    $script:WelcomeClosing = $true
    $dur = New-Object Windows.Duration ([TimeSpan]::FromMilliseconds(700))
    $ease = New-Object Windows.Media.Animation.CubicEase
    $ease.EasingMode = 'EaseOut'

    $wb = New-Object Windows.Media.Effects.BlurEffect
    $wb.Radius = 0
    $UI.Welcome.Effect = $wb
    $blurOut = New-Object Windows.Media.Animation.DoubleAnimation(0, 30, $dur)
    $blurOut.EasingFunction = $ease
    $wb.BeginAnimation([Windows.Media.Effects.BlurEffect]::RadiusProperty, $blurOut)

    $fade = New-Object Windows.Media.Animation.DoubleAnimation(1, 0, $dur)
    $fade.EasingFunction = $ease
    $fade.add_Completed({
        $UI.Welcome.Visibility = 'Collapsed'
        foreach ($n in $WelcomeParts) { $UI[$n].Effect = $null }
    })
    $UI.Welcome.BeginAnimation([Windows.UIElement]::OpacityProperty, $fade)

    foreach ($n in $WelcomeParts) {
        $unblur = New-Object Windows.Media.Animation.DoubleAnimation(18, 0, $dur)
        $unblur.EasingFunction = $ease
        if ($UI[$n].Effect) { $UI[$n].Effect.BeginAnimation([Windows.Media.Effects.BlurEffect]::RadiusProperty, $unblur) }
    }
    $script:Welcomed = $true
    Save-Settings
}

function Set-Theme([string]$name) {
    if (-not $Themes.Contains($name)) { $name = 'Cyber' }
    $script:ThemeName = $name
    foreach ($kv in $Themes[$name].GetEnumerator()) {
        $brush = New-Object Windows.Media.SolidColorBrush
        $brush.Color = [Windows.Media.ColorConverter]::ConvertFromString($kv.Value)
        $Window.Resources.Remove($kv.Key)
        $Window.Resources.Add($kv.Key, $brush)
    }
    $UI["Theme_$name"].IsChecked = $true
    foreach ($el in $UI.LogoTweak, $UI.LogoTweak.Parent.Children[0], $UI.WelcomeLogo.Children[0], $UI.WelcomeLogo.Children[2]) { $el.Effect.Color = [Windows.Media.ColorConverter]::ConvertFromString($Themes[$name].Accent) }
    foreach ($i in $Items) { if ($Defs[$i.Id].IsApp) { $i.BadgeColor = $Themes[$name].Accent } }
    # rebuild the visible rows so the app badges pick up the new accent colour
    if ($script:CurCat -eq 'Apps') { Show-List }
    if ($script:InfoItem) { Show-Info $script:InfoItem }
    Update-UpdateCards
    Save-Settings
}

function Show-Dialog([string]$title, [string]$body, $onOk, [bool]$withCancel = $true, [bool]$withRestore = $false) {
    $UI.OvTitle.Text = $title
    $UI.OvBody.Text = $body
    $UI.OvCancel.Visibility = if ($withCancel) { 'Visible' } else { 'Collapsed' }
    $UI.OvRestore.Visibility = if ($withRestore) { 'Visible' } else { 'Collapsed' }
    $UI.OvRestore.IsChecked = $true
    $script:OnOk = $onOk
    $UI.Overlay.Visibility = 'Visible'
}

# Windows Update profiles: which one is active right now (read-only registry check)
function Get-UpdateProfile {
    if (Test-Reg "$CT_WU\AU" 'NoAutoUpdate' 1) { return 'dis' }
    if (Test-Reg $CT_WU 'DeferFeatureUpdatesPeriodInDays' 365) { return 'rec' }
    'def'
}

function Update-UpdateCards {
    if (-not $UI.UpdCardRec) { return }
    $cur = Get-UpdateProfile
    $ok = $Window.Resources['Ok']; $line = $Window.Resources['Line']
    foreach ($p in 'Rec', 'Def', 'Dis') {
        $card = $UI["UpdCard$p"]
        $active = ($cur -eq $p.ToLower())
        $card.BorderBrush = if ($active) { $ok } else { $line }
        $card.BorderThickness = if ($active) { 2 } else { 1 }
    }
}

function Invoke-UpdateProfile([string]$p) {
    if ($script:BusyMode) { return }
    $title = T "upd_$($p)_title"
    $body = (T 'upd_confirm') -f $title
    if ($DryRun) { $body += "`n`n" + (T 'confirm_dryrun') }
    $script:PendingMode = 'Apply'
    $script:PendingSel = $null
    $script:PendingJobs = @(@{ Id = "upd_$p"; Name = $title; Code = $UpdateProfiles[$p].ToString(); MinBuild = 0; Needs = 'reboot'; IsApp = $false })
    Show-Dialog (T 'confirm_apply_title') $body { Start-Run } $true $true
}

# ------------------------------------------------------------------ background worker
$Sync = [hashtable]::Synchronized(@{ Queue = New-Object 'System.Collections.Concurrent.ConcurrentQueue[object]' })

$WorkerScript = {
    param($Sync, $HelperCode, $Mode, $Jobs, $Opt)
    . ([scriptblock]::Create($HelperCode))
    $Txt = $Opt.Txt
    function Out-Msg($m) { $Sync.Queue.Enqueue($m) }
    function Out-Log([string]$line) { $Sync.Queue.Enqueue(@{ T = 'log'; V = $line }) }
    $ok = 0; $err = 0
    try {
        if ($Mode -eq 'Check') {
            $checkTweaks = { foreach ($j in $Jobs) {
                $state = 'na'
                if (-not ($j.MinBuild -and $Opt.Build -lt $j.MinBuild)) {
                    try {
                        $r = @(& ([scriptblock]::Create($j.Code)) 2>$null)
                        $last = if ($r.Count) { $r[-1] } else { $null }
                        if ($last -is [bool]) { $state = if ($last) { 'active' } else { 'default' } }
                    } catch {}
                }
                Out-Msg @{ T = 'status'; Id = $j.Id; V = $state }
            } }
            if (-not $Opt.Apps) { . $checkTweaks }
            # Installed apps
            if ($Opt.Apps) {
                # 1. Windows uninstall list (fast, also finds programs not installed with winget).
                #    Results are sent right away so the ticks show up before winget has finished.
                $names = foreach ($k in 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
                                        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
                                        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*') {
                    Get-ItemProperty $k -ErrorAction SilentlyContinue | ForEach-Object { if ($_.DisplayName) { "$($_.DisplayName)" } }
                }
                $found = @{}
                foreach ($a in $Opt.Apps) {
                    $short = ($a.Name -replace '\s*\(.*\)$', '').Trim()
                    $rx = '^' + [regex]::Escape($short) + '( v?\d.*| \(.*\))?$'
                    if ($names | Where-Object { $_ -match $rx } | Select-Object -First 1) {
                        $found[$a.Id] = $true
                        Out-Msg @{ T = 'status'; Id = $a.Id; V = 'active' }
                    }
                }
                . $checkTweaks
                # 2. winget export for everything winget knows (max. 90 s, it can hang when elevated)
                $installed = @{}
                $known = $false
                if (Test-Winget) {
                    $tmp = [IO.Path]::Combine([IO.Path]::GetTempPath(), "cybertweak_export_$PID.json")
                    try {
                        $wg = (Get-Command winget -ErrorAction Stop).Source
                        $p = Start-Process $wg -ArgumentList "export -o `"$tmp`" --accept-source-agreements --disable-interactivity" -WindowStyle Hidden -PassThru
                        if (-not $p.WaitForExit(90000)) { try { $p.Kill() } catch {} }
                        $exp = [IO.File]::ReadAllText($tmp) | ConvertFrom-Json
                        foreach ($s in $exp.Sources) { foreach ($pk in $s.Packages) { $installed["$($pk.PackageIdentifier)"] = $true } }
                        $known = $true
                    } catch {}
                    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
                }
                foreach ($a in $Opt.Apps) {
                    if ($found[$a.Id]) { continue }
                    $state = if ($installed[$a.WingetId]) { 'active' } elseif ($known) { 'default' } else { 'na' }
                    Out-Msg @{ T = 'status'; Id = $a.Id; V = $state }
                }
            }
            return
        }

        $n = $Jobs.Count; $i = 0; $needs = @{}
        Out-Log ('=' * 60)
        Out-Log ($Txt.log_start -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $(if ($Mode -eq 'Apply') { $Txt.mode_apply } else { $Txt.mode_undo }), $n)
        if ($Opt.DryRun) { Out-Log $Txt.log_dryrun }

        if ($Opt.RestorePoint) {
            Out-Log ''
            Out-Log $Txt.log_restore
            if ($Opt.DryRun) { Out-Log '  [DRYRUN] Checkpoint-Computer -RestorePointType MODIFY_SETTINGS' }
            else {
                try {
                    Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
                    $k = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore'
                    $old = Get-Reg $k 'SystemRestorePointCreationFrequency'
                    Set-Reg $k 'SystemRestorePointCreationFrequency' 0
                    Checkpoint-Computer -Description ("CyberTweak " + (Get-Date -Format 'yyyy-MM-dd HH:mm')) -RestorePointType MODIFY_SETTINGS -ErrorAction Stop
                    if ($null -eq $old) { Remove-Reg $k 'SystemRestorePointCreationFrequency' } else { Set-Reg $k 'SystemRestorePointCreationFrequency' $old }
                    Out-Log ('  ' + $Txt.log_restore_ok)
                } catch { Out-Log ('  ' + ($Txt.log_restore_fail -f $_.Exception.Message)) }
            }
        }

        foreach ($j in $Jobs) {
            $i++
            Out-Msg @{ T = 'progress'; V = [int](100 * ($i - 1) / $n) }
            Out-Log ''
            Out-Log ('[{0}/{1}] {2}' -f $i, $n, $j.Name)
            if ($j.MinBuild -and $Opt.Build -lt $j.MinBuild) { Out-Log ('  ' + ($Txt.log_skip_build -f $j.MinBuild)); continue }
            if ($j.IsApp -and -not (Test-Winget)) { Out-Log ('  ' + $Txt.winget_missing); $err++; continue }
            if ($Opt.DryRun) {
                foreach ($line in ($j.Code -split "`r?`n")) { $t = $line.Trim(); if ($t) { Out-Log "  [DRYRUN] $t" } }
                $ok++
                if ($j.Needs) { $needs[$j.Needs] = $true }
                Out-Msg @{ T = 'result'; Id = $j.Id; Mode = $Mode }
                continue
            }
            try {
                $global:LASTEXITCODE = 0
                & ([scriptblock]::Create($j.Code)) 2>&1 | ForEach-Object {
                    if ($_ -is [System.Management.Automation.ErrorRecord]) { Out-Log ('  ! ' + $_.ToString()) }
                    else {
                        foreach ($seg in ("$_" -split "[`r`n]+")) {
                            $t = $seg.Trim()
                            if ($t.Length -gt 1 -and $t -notmatch '^[\s\-\\\|/]+$' -and $t -notmatch '[\u2580-\u259F]') { Out-Log "  $t" }
                        }
                    }
                }
                if ($j.IsApp -and $LASTEXITCODE -ne 0 -and $LASTEXITCODE -notin @(-1978335189, -1978335135)) {
                    throw ('winget exit code {0}' -f $LASTEXITCODE)
                }
                Out-Log ('  ' + $Txt.log_ok)
                $ok++
                if ($j.Needs) { $needs[$j.Needs] = $true }
                Out-Msg @{ T = 'result'; Id = $j.Id; Mode = $Mode }
            } catch {
                Out-Log ('  ' + ($Txt.log_err -f $_.Exception.Message))
                $err++
            }
        }

        Out-Msg @{ T = 'progress'; V = 100 }
        Out-Log ''
        if ($needs['explorer']) {
            Out-Log $Txt.log_explorer
            if (-not $Opt.DryRun) { Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue }
        }
        if ($needs['reboot']) { Out-Log $Txt.log_reboot }
        elseif ($needs['signout']) { Out-Log $Txt.log_signout }
        Out-Log ($Txt.log_done -f $ok, $err)
    } catch {
        Out-Log ('FATAL: ' + $_.Exception.Message)
    } finally {
        Out-Msg @{ T = 'done'; Mode = $Mode; Ok = $ok; Err = $err }
    }
}

function Set-Busy([bool]$busy) {
    foreach ($b in 'BtnApply', 'BtnUndo', 'BtnPresetRec', 'BtnPresetGame', 'BtnPresetClear', 'UpdBtnRec', 'UpdBtnDef', 'UpdBtnDis') { $UI[$b].IsEnabled = -not $busy }
}

function Start-Worker([string]$mode, $jobs, $apps = $null) {
    $txt = @{}
    foreach ($k in 'log_start', 'mode_apply', 'mode_undo', 'log_dryrun', 'log_restore', 'log_restore_ok', 'log_restore_fail', 'log_skip_build',
                   'winget_missing', 'log_ok', 'log_err', 'log_explorer', 'log_reboot', 'log_signout', 'log_done') { $txt[$k] = T $k }
    $opt = @{ DryRun = [bool]$DryRun; RestorePoint = ($mode -ne 'Check' -and [bool]$UI.OvRestore.IsChecked); Build = $Build; Txt = $txt; Apps = $apps }
    $script:BusyMode = $mode
    Set-Busy $true
    $rs = [runspacefactory]::CreateRunspace()
    $rs.ApartmentState = 'STA'
    $rs.Open()
    $ps = [powershell]::Create()
    $ps.Runspace = $rs
    [void]$ps.AddScript($WorkerScript.ToString()).AddArgument($Sync).AddArgument($HelperCode).AddArgument($mode).AddArgument(@($jobs)).AddArgument($opt)
    $script:WorkerPS = $ps
    $script:WorkerHandle = $ps.BeginInvoke()
}

function Start-StatusCheck {
    $jobs = foreach ($t in $Tweaks) {
        if ($t.Check) {
            Set-State $ItemById[$t.Id] 'unknown'
            @{ Id = $t.Id; Code = $t.Check.ToString(); MinBuild = $t.MinBuild }
        }
    }
    $apps = foreach ($a in $Apps) {
        if ($ItemById[$a.Id].State -ne 'active') { Set-State $ItemById[$a.Id] 'unknown' }
        @{ Id = $a.Id; WingetId = $a.WingetId; Name = $a.Name }
    }
    Start-Worker 'Check' $jobs $apps
}

function Complete-Worker($m) {
    try { [void]$script:WorkerPS.EndInvoke($script:WorkerHandle) } catch {}
    try { $script:WorkerPS.Runspace.Dispose(); $script:WorkerPS.Dispose() } catch {}
    $script:BusyMode = $null
    Set-Busy $false
    Update-Count
    if ($m.Mode -eq 'Check') { Show-Info $script:InfoItem }
    else { Update-UpdateCards; Start-StatusCheck }
}

# A finished item gets unticked. Items without a status check (cleanup, fixes) are
# remembered in history.json so they keep their check mark; apps are re-detected.
function Set-Result($m) {
    $it = $ItemById[$m.Id]
    if (-not $it) { return }
    $it.IsChecked = $false
    $d = $Defs[$m.Id]
    if ($d.Check -or $DryRun -or $d.Track -eq $false) { return }
    if ($d.IsApp) { Set-State $it $(if ($m.Mode -eq 'Apply') { 'active' } else { 'default' }); return }
    if ($m.Mode -eq 'Apply') { [void]$History.Add($m.Id); Set-State $it 'active' }
    else { [void]$History.Remove($m.Id); Set-State $it 'na' }
    try { [IO.File]::WriteAllText($HistoryPath, (ConvertTo-Json @($History) -Compress)) } catch {}
}

function Invoke-Run([string]$mode) {
    if ($script:BusyMode) { return }
    $sel = @($Items | Where-Object { $_.IsChecked })
    if ($mode -eq 'Undo') { $sel = Get-UndoItems }
    if (-not $sel.Count) {
        Show-Dialog (T 'dlg_info') (T $(if ($mode -eq 'Undo') { 'nothing_undo' } else { 'nothing_selected' })) $null $false
        return
    }
    $list = ($sel | ForEach-Object { ' > ' + $_.Name }) -join "`n"
    $body = (T 'confirm_body') -f $sel.Count, $list
    if ($DryRun) { $body += "`n`n" + (T 'confirm_dryrun') }
    $title = if ($mode -eq 'Apply') { T 'confirm_apply_title' } else { T 'confirm_undo_title' }
    $script:PendingMode = $mode
    $script:PendingSel = $sel
    $script:PendingJobs = $null
    Show-Dialog $title $body { Start-Run } $true $true
}

function Start-Run {
    $mode = $script:PendingMode
    $jobs = if ($script:PendingJobs) { $script:PendingJobs } else { foreach ($i in $script:PendingSel) {
        $d = $Defs[$i.Id]
        if ($d.IsApp) {
            $code = Get-WingetCmd $d $mode
            @{ Id = $i.Id; Name = $i.Name; Code = $code; MinBuild = 0; Needs = $null; IsApp = $true }
        } else {
            $sb = if ($mode -eq 'Apply') { $d.Apply } else { $d.Undo }
            @{ Id = $i.Id; Name = $i.Name; Code = $sb.ToString(); MinBuild = $d.MinBuild; Needs = $d.Needs; IsApp = $false }
        }
    } }
    $UI.Progress.Value = 0
    $UI.Nav_Log.IsChecked = $true
    Start-Worker $mode $jobs
}

# ------------------------------------------------------------------ events
$UI.BtnClose.Add_Click({ $Window.Close() })
$UI.BtnMin.Add_Click({ $Window.WindowState = 'Minimized' })
$UI.BtnMax.Add_Click({ $Window.WindowState = if ($Window.WindowState -eq 'Maximized') { 'Normal' } else { 'Maximized' } })
$Window.Add_StateChanged({
    if ($Window.WindowState -eq 'Maximized') {
        # a borderless window would cover the taskbar; keep it inside the work area
        $wa = [Windows.SystemParameters]::WorkArea
        $Window.MaxWidth = $wa.Width + 14
        $Window.MaxHeight = $wa.Height + 14
        $UI.RootBorder.Margin = 7
    } else {
        $Window.MaxWidth = [double]::PositiveInfinity
        $Window.MaxHeight = [double]::PositiveInfinity
        $UI.RootBorder.Margin = 0
    }
})

# Bigger window (e.g. maximized) = bigger UI: everything is scaled up evenly from the
# 1220x760 design size, never below 1 and at most 1.8x.
$script:UiScale = New-Object Windows.Media.ScaleTransform 1, 1
$UI.RootBorder.Child.LayoutTransform = $script:UiScale
function Update-UiScale {
    $w = $UI.RootBorder.ActualWidth; $h = $UI.RootBorder.ActualHeight
    if ($w -le 0 -or $h -le 0) { return }
    $s = [math]::Max([double]1, [math]::Min([double]1.8, [math]::Min([double]($w / 1218), [double]($h / 758))))
    if ([math]::Abs($script:UiScale.ScaleX - $s) -gt 0.001) {
        $script:UiScale.ScaleX = $s
        $script:UiScale.ScaleY = $s
    }
}
$UI.RootBorder.Add_SizeChanged({ Update-UiScale })

foreach ($c in $LangCodes) {
    $UI["Lang_$c"].Content = if ($Langs[$c]) { $Langs[$c].langName } else { $c.ToUpper() }
    $UI["Lang_$c"].Add_Click({ param($sender, $e) $UI.LangToggle.IsChecked = $false; Set-Lang $sender.Name.Substring(5) })
}
foreach ($t in $Themes.Keys) {
    $UI["Theme_$t"].Add_Click({ param($sender, $e) $UI.ThemeToggle.IsChecked = $false; Set-Theme $sender.Name.Substring(6) })
}
$UI.UpdBtnRec.Add_Click({ Invoke-UpdateProfile 'rec' })
$UI.UpdBtnDef.Add_Click({ Invoke-UpdateProfile 'def' })
$UI.UpdBtnDis.Add_Click({ Invoke-UpdateProfile 'dis' })

foreach ($c in ($Categories + 'Updates' + 'Log')) {
    $UI["Nav_$c"].Add_Checked({
        param($sender, $e)
        $script:CurCat = $sender.Name.Substring(4)
        $UI.SearchBox.Text = ''
        Show-List
    })
}

$UI.SearchBox.Add_TextChanged({
    $UI.SearchHint.Visibility = if ($UI.SearchBox.Text) { 'Collapsed' } else { 'Visible' }
    Show-List
})
$UI.List.Add_SelectionChanged({ if ($UI.List.SelectedItem) { Show-Info $UI.List.SelectedItem } })

$UI.BtnPresetRec.Add_Click({ foreach ($i in $Items) { $i.IsChecked = $Presets.Recommended -contains $i.Id } })
$UI.BtnPresetGame.Add_Click({ foreach ($i in $Items) { $i.IsChecked = $Presets.Gaming -contains $i.Id } })
$UI.BtnPresetClear.Add_Click({ foreach ($i in $Items) { $i.IsChecked = $false } })

$UI.BtnApply.Add_Click({ Invoke-Run 'Apply' })
$UI.BtnUndo.Add_Click({ Invoke-Run 'Undo' })

$UI.OvCancel.Add_Click({ $UI.Overlay.Visibility = 'Collapsed'; $script:OnOk = $null })
$UI.OvOk.Add_Click({
    $UI.Overlay.Visibility = 'Collapsed'
    $cb = $script:OnOk
    $script:OnOk = $null
    if ($cb) { & $cb }
})

foreach ($i in $Items) {
    $i.add_PropertyChanged({ param($sender, $e) if ($e.PropertyName -eq 'IsChecked') { Update-Count } })
}

$Timer = New-Object Windows.Threading.DispatcherTimer
$Timer.Interval = [TimeSpan]::FromMilliseconds(80)
$Timer.Add_Tick({
    $m = $null
    while ($Sync.Queue.TryDequeue([ref]$m)) {
        switch ($m.T) {
            'log'      { Write-Log $m.V }
            'progress' { $UI.Progress.Value = $m.V }
            'status'   { $it = $ItemById[$m.Id]; if ($it) { Set-State $it $m.V } }
            'result'   { Set-Result $m }
            'done'     { Complete-Worker $m }
        }
    }
})

$Window.Add_Closing({
    param($sender, $e)
    if ($script:BusyMode -and $script:BusyMode -ne 'Check') {
        $e.Cancel = $true
        Show-Dialog (T 'dlg_info') (T 'busy') $null $false
    }
})

$Window.Add_Loaded({
    $Timer.Start()
    Start-StatusCheck
})

$Window.Add_PreviewKeyDown({ param($sender, $e) if ($UI.Welcome.Visibility -eq 'Visible') { $e.Handled = $true; Hide-Welcome } })
$Window.Add_PreviewMouseDown({ param($sender, $e) if ($UI.Welcome.Visibility -eq 'Visible') { $e.Handled = $true; Hide-Welcome } })

# ------------------------------------------------------------------ start
$script:CurCat = 'Performance'
$script:InfoItem = $null
$script:BusyMode = $null
$script:ThemeName = $ThemeName
$script:Lang = $Lang
$script:Welcomed = $Welcomed
$script:WelcomeClosing = $false
$script:FontName = $FontName
Set-Font $FontName
Set-Theme $ThemeName
Set-Lang $Lang
Show-Welcome
if ($DryRun) { Write-Log '[DRYRUN] CyberTweak started in dry-run mode - nothing will be changed.' }
[void]$Window.ShowDialog()
$Timer.Stop()

} catch {
    $msg = "CyberTweak crashed:`n`n" + ($_ | Out-String)
    try {
        $dir = Join-Path $Root 'logs'
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
        [IO.File]::AppendAllText((Join-Path $dir 'crash.log'), $msg + "`r`n", [Text.Encoding]::UTF8)
    } catch {}
    [System.Windows.MessageBox]::Show($msg, 'CyberTweak', 'OK', 'Error') | Out-Null
}
