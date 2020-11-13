#!/bin/powershell

# ---------------------------------------
# load helpers-cfg
# ---------------------------------------

$SCRIPT_DIR = $PSScriptRoot
$SCRIPT_NAME = "$PSScriptRoot\helpers.ps1"
$SCRIPT_CFG = "$SCRIPT_DIR\helpers-cfg.ps1"

if (Test-Path $SCRIPT_CFG) {
  Import-Module -Force -Global $SCRIPT_CFG
}

# ---------------------------------------
# alias and log
# ---------------------------------------
Set-Alias -Name grep -Value Select-String
Set-Alias -Name choco -Value C:\ProgramData\chocolatey\bin\choco.exe
Set-Alias -Name gsudo -Value C:\ProgramData\chocolatey\lib\gsudo\bin\gsudo.exe

# ---------------------------------------
# log
# ---------------------------------------
$hf_log_func = 'Write-Host -ForegroundColor DarkYellow "--" $MyInvocation.MyCommand.ToString()'

function hf_log() {
  Write-Host -ForegroundColor DarkYellow "--" ($args -join " ")
}
function hf_log_l2() {
  Write-Host -ForegroundColor DarkYellow "--  " ($args -join " ")
}

# ---------------------------------------
# go home
# ---------------------------------------
Set-Location ~

# ---------------------------------------
# profile funcs
# ---------------------------------------

function hf_profile_install() {
  Write-Output "Import-Module -Force -Global $SCRIPT_NAME" > $Profile.AllUsersAllHosts
}

function hf_profile_reload() {
  powershell -nologo
}

function hf_profile_import($path) {
  Write-Output "RUN: Import-Module -Force -Global $path"
}

# ---------------------------------------
# ps funcs
# ---------------------------------------

function hf_ps_enable_PSWindowsUpdate() {
  if (-Not (Get-Package -Name PSWindowsUpdate -ea 0)) {
    Install-Module -Confirm PSWindowsUpdate 
  }
  Import-Module -Force -Global PSWindowsUpdate 
}

function hf_ps_show_module_commands($name) {
  Get-Command -module $name
}

function hf_ps_show_function($name) {
  Get-Content Function:\$name
}

function hf_ps_enable_scripts() {
  Set-ExecutionPolicy unrestricted
}

function hf_ps_profiles_list() {
  $profile | Select-Object -Property *
}

function hf_ps_profiles_reset() {
  Invoke-Expression $hf_log_func
  $profile.AllUsersAllHosts = "\Windows\System32\WindowsPowerShell\v1.0\profile.ps1"
  $profile.AllUsersCurrentHost = "\Windows\System32\WindowsPowerShell\v1.0\Microsoft.PowerShell_profile.ps1"
  $profile.CurrentUserAllHosts = "WindowsPowerShell\profile.ps1"
  $profile.CurrentUserCurrentHost = "WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
}

function hf_ps_wait_for_fey {
  hf_log "Press any key to continue"
  [Console]::ReadKey($true) | Out-Null
}

# ---------------------------------------
# system funcs
# ---------------------------------------

function hf_system_rename($new_name) {
  Rename-Computer -NewName "$new_name"
}

Function hf_system_restart {
  hf_log "Restarting"
  Restart-Computer
}

function hf_system_rename($new_name) {
  Rename-Computer -NewName "$new_name"
}

function hf_system_info() {
  cmd.exe /c systeminfo
}
function hf_system_env() {
  [Environment]::GetEnvironmentVariables()
}

function hf_system_disable_password_policy {
  Invoke-Expression $hf_log_func
  $tmpfile = New-TemporaryFile
  secedit /export /cfg $tmpfile /quiet
  (Get-Content $tmpfile).Replace("PasswordComplexity = 1", "PasswordComplexity = 0").Replace("MaximumPasswordAge = 42", "MaximumPasswordAge = -1") | Out-File $tmpfile
  secedit /configure /db "$env:SYSTEMROOT\security\database\local.sdb" /cfg $tmpfile /areas SECURITYPOLICY | Out-Null
  Remove-Item -Path $tmpfile
}

# ---------------------------------------
# path funcs
# ---------------------------------------
function hf_path_add($addPath) {
  if (Test-Path $addPath) {
    $path = [Environment]::GetEnvironmentVariable('path', 'Machine')
    $regexAddPath = [regex]::Escape($addPath)
    $arrPath = $path -split ';' | Where-Object { $_ -notMatch 
      "^$regexAddPath\\?" }
    $newpath = ($arrPath + $addPath) -join ';'
    [Environment]::SetEnvironmentVariable("path", $newpath, 'Machine')
  }
  else {
    Throw "$addPath' is not a valid path."
  }
}

function hf_path_print($addPath) {
  $path = [Environment]::GetEnvironmentVariable('path', 'Machine')
  Write-Output $path
}

function hf_path_add_msys() {
  hf_path_add 'C:\tools\msys64\mingw64\bin'
}
function hf_path_add_choco_tools() {
  $chocotools = [Environment]::GetEnvironmentVariable('ChocolateyToolsLocation')
  hf_path_add $chocotools
}

# ---------------------------------------
# optimize funcs
# ---------------------------------------

function hf_optimize_features() {
  Invoke-Expression $hf_log_func
  
  # Visual to performace
  hf_log  "Visuals to performace "
  New-ItemProperty -ea 0 -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name 'VisualFXSetting' -Value 2 -PropertyType DWORD -Force | Out-Null
  New-ItemProperty -ea 0 -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name 'EnableTransparency' -Value 0 -PropertyType DWORD -Force | Out-Null
  Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Type String -Value 0 | Out-Null
  Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type String -Value 0 | Out-Null
  Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Type Binary -Value ([byte[]](144, 18, 3, 128, 16, 0, 0, 0)) | Out-Null
  Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Type String -Value 0 | Out-Null
  Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Type DWord -Value 0 | Out-Null
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Type DWord -Value 0 | Out-Null
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Type DWord -Value 0 | Out-Null
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Type DWord -Value 0 | Out-Null
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Type DWord -Value 0 | Out-Null
  
  # Fax
  hf_log  "Remove Fax "
  Remove-Printer -Name "Fax" -ea 0

  # XPS Services
  hf_log  "Remove XPS "
  dism.exe /online /quiet /disable-feature /featurename:Printing-XPSServices-Features /norestart

  # Work Folders
  hf_log  "Remove Work Folders "
  dism.exe /online /quiet /disable-feature /featurename:WorkFolders-Client /norestart

  # Remove Lock screen
  hf_log  "Remove Lockscreen "
  Set-ItemProperty  -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreen" -Type DWord -Value 1 -ea 0 -Force  | Out-Null
  Set-ItemProperty  -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "DisableLogonBackgroundImage" -Type DWord -Value 1 -ea 0 -Force | Out-Null
  
  # Disable drives Autoplay
  hf_log "Disable new drives Autoplay"
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWord -Value 1  | Out-Null
  
  # Disable offering of Malicious Software Removal Tool through Windows Update
  hf_log "Disable Malicious Software Removal Tool offering"
  New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT" -ea 0 -Force | Out-Null
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT" -Name "DontOfferThroughWUAU" -Type DWord -Value 1  -ea 0 -Force | Out-Null
  
  # Disable Remote Assistance
  hf_log "Disable Remote Assistance"
  Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0  -ea 0 -Force | Out-Null
  
  # Disable AutoRotation Hotkeys
  hf_log "Disable AutoRotation Hotkeys"
  reg add "HKCU\Software\INTEL\DISPLAY\IGFXCUI\HotKeys" /v "Enable" /t REG_DWORD /d 0 /f | Out-Null
  
  # Disable Autorun for all drives
  hf_log "Disable Autorun for all drives"
  New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ea 0 -Force | Out-Null
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Type DWord -Value 255 -ea 0 -Force | Out-Null
  
  # Disable error reporting
  hf_log  "Disable error reporting "
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f | Out-Null
  
  # Disable license checking
  hf_log  "Disable license checking "
  reg add "HKLM\Software\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" /v NoGenTicket /t REG_DWORD /d 1 /f | Out-Null
  
  # Disable tips
  hf_log  "Disable tips "
  reg add "HKCU\Software\Policies\Microsoft\Windows\CloudContent" /v DisableSoftLanding /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKCU\Software\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsSpotlightFeatures /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKCU\Software\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKCU\Software\Policies\Microsoft\Windows\DataCollection" /v DoNotShowFeedbackNotifications /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKCU\Software\Policies\Microsoft\WindowsInkWorkspace" /v AllowSuggestedAppsInWindowsInkWorkspace /t REG_DWORD /d 0 /f | Out-Null
  
  # 'Disable Accessibility Keys Prompts
  hf_log 'Disable Accessibility Keys Prompts '
  $path = 'HKCU:\Control Panel\Accessibility\'
  Set-ItemProperty -Path "$path\StickyKeys" -Name 'Flags' -Type String -Value '506'
  Set-ItemProperty -Path "$path\ToggleKeys" -Name 'Flags' -Type String -Value '58'
  Set-ItemProperty -Path "$path\Keyboard Response" -Name 'Flags' -Type String -Value '122'
  
  # "Disable Windows Timeline 
  hf_log "Disable Windows Timeline "
  Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'EnableActivityFeed' -Type DWord -Value 0
  
  # Disable unused services
  hf_log  "Disable unused services "
  $services = @("*diagnosticshub.standardcollector.service*" # Diagnostics Hub 
    "*diagsvc*" # Diagnostic Execution Service
    "*dmwappushservice*" # Device Management WAP Push message Routing Service
    "*DiagTrack*" # Connected User Experiences and Telemetry
    "*lfsvc*" # Geolocation Service
    "*MapsBroker*" # Downloaded Maps Manager
    "*RetailDemo*" # Retail Demo Service
    "*RemoteRegistry*" # Remote Registry
    "*FoxitReaderUpdateService*" # Remote Registry
    "*RemoteAccess*" # Routing and Remote Access (routing services to businesses in LAN)
    "*TrkWks*" # Distributed Link Tracking Client
    "*XblAuthManager*" # Xbox Live Auth Manager
    "*XboxNetApiSvc*" # Xbox Live Networking Service
    "*XblGameSave*" # Xbox Live Game Save
    "*wisvc*" # Windows Insider Service
  )
  
  $services | ForEach-Object {
    hf_log_l2  "Stop and disable $_"
    Get-Service -Name $_ | Stop-Service -WarningAction SilentlyContinue 
    Get-Service -Name $_ | Set-Service -StartupType Disabled -ea 0 
  }
  
  # Disable unused windows packages
  hf_log  "Disable windows packages "
  $pkgs = @(
    '*QuickAssist*'
    '*Hello-Face*'
    '*phone*'
  )
  hf_winpackage_uninstall_like @pkgs 
}
  
function hf_optimize_features_advanced() {
  Invoke-Expression $hf_log_func
  # Disable services
  hf_log  "Disable services "
  $services = @(
    "*TermService*" # Remote Desktop Services
    "*UmRdpService*" # Remote Desktop Services UserMode Port Redirector
    "*SessionEnv*" # Remote Desktop Configuration
    
    "*AppleOSSMgr*" # bootcamp: Apple OS Switch Manager
    # "*Bonjour Service*" # bootcamp: Bonjour Service
    # "*BootCampService*" # bootcamp: Boot Camp Service
    
    "*Phone*" # Foxit Reader Update Service
    "*gupdate*" # Google Update Service
    "*gupdatem*" # Google Update Service
    
    "*PcaSvc*" # Program Compatibility Assistant Service
    "*wercplsupport*" # Problem Reports Control Panel Support
    "*WerSvc*" # Windows Error Reporting Service
    
    "*NetTcpPortSharing*" # Net.Tcp Port Sharing Service   
    "*PhoneSvc*" # Phone Service
    "*Themes*" # Themes (Provides user experience theme management.)
    "*WbioSrvc*" # Windows Biometric Service
    "*Sense*" # Windows Defender Advanced Threat Protection Service

    "*SysMain*" # SysMain (Maintains and improves system performance)
    "*MicrosoftEdgeElevationService*" # Edge Update Service 
    "*edgeupdate*" # Edge Update Service 
    "*edgeupdatem*" # Edge Update Service
    
    # "*SecurityHealthService*"
    # "*AppVClient*" # Microsoft App-V Client
    # "*AxInstSV*" # ActiveX Installer
    # "*SharedAccess*" # Internet Connection Sharing (ICS)
    # "*UevAgentService*" # User Experience Virtualization Service (application and OS settings roaming)
    
    # craches
    # "*TabletInputService*" # Touch Keyboard and Handwriting Panel Service. OBS crashes WindowsTerminal input https://github.com/microsoft/terminal/issues/4448
    # "*ClickToRunSvc*" # Office Click-to-Run Service.
    # "*shpamsvc*" # Shared PC Account Manager
    # "*HomeGroupListener*" 
    # "*UserManager*" # User Manager
  )
  $services | ForEach-Object {
    hf_log_l2 "Stop and disable $_"
    Get-Service -Name $_ | Stop-Service -WarningAction SilentlyContinue 
    Get-Service -Name $_ | Set-Service -StartupType Disabled -ea 0
  }
}

function hf_optimize_explorer() {
  Invoke-Expression $hf_log_func
 
  # used for -LiteralPath
  New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -ea 0 | Out-Null
  
  # Use small icons
  hf_log "Use small icons "
  New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarSmallIcons -PropertyType DWORD -Value 1 -ea 0 | Out-null
 
  # Hide search button
  hf_log "Hide search button "
  New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name SearchboxTaskbarMode -PropertyType DWORD -Value 0 -ea 0 | Out-null
 
  # Hide task view button
  hf_log "Hide taskview button "
  Remove-Item -Path "HKCR:\Software\Microsoft\Windows\CurrentVersion\Explorer\MultiTaskingView\AllUpView" -Recurse -ea 0 | Out-null
  New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowTaskViewButton -PropertyType DWORD -Value 0 -ea 0 | Out-null
 
  # Hide taskbar people icon
  hf_log "Hide people button "
  New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"  -ea 0 | Out-null
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWord -Value 0  -ea 0 | Out-null
 
  # Disable file delete confirmation dialog
  hf_log "Disable file delete confirmation dialog"
  Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "ConfirmFileDelete" -ea 0 | Out-null
 
  # Disable action center
  hf_log "Hide action center button "
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Type DWord -Value 1 -ea 0 | Out-null
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type DWord -Value 0 -ea 0 | Out-null
 
  # Disable Bing
  hf_log "Disable Bing search "
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /d "0" /t REG_DWORD /f  | Out-null
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v AllowSearchToUseLocation /d "0" /t REG_DWORD /f | Out-null
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v CortanaConsent /d "0" /t REG_DWORD /f | Out-null
  reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v ConnectedSearchUseWeb /d "0" /t REG_DWORD /f | Out-null
 
  # Disable Cortana
  hf_log "Disable Cortana"
  New-Item -Path "HKCU:\Software\Microsoft\Personalization\Settings"  -ea 0 | Out-null
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
  New-Item -Path "HKCU:\Software\Microsoft\InputPersonalization"  -ea 0 | Out-null
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
  New-Item -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore"   -ea 0 | Out-null
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
  New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"  -ea 0 | Out-null
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0 -ea 0 | Out-null
 
  # Remove AutoLogger file and restrict directory
  hf_log "Remove AutoLogger file and restricting directory"
  $autoLoggerDir = "$env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger"
  Remove-Item "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl"  -ea 0 | Out-null
 
  # Hide icons in desktop
  hf_log "Hide icons in desktop "
  $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
  Set-ItemProperty -Path $path -Name "HideIcons" -Value 1  -ea 0 | Out-null
 
  # Hide recently explorer shortcut
  hf_log "Hide recently explorer shortcut "
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -Type DWord -Value 0  -ea 0 | Out-null
 
  # Set explorer to open to 'This PC'
  hf_log "Set explorer to open to 'This PC "
  New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name LaunchTo -PropertyType DWORD -Value 1 -ea 0 | Out-null
 
  # Disable show frequent in Quick acess
  hf_log "Disable show frequent in Quick acess "
  New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name 'ShowFrequent' -Value 0 -PropertyType DWORD -ea 0 | Out-null
 
  # Set explorer how file extensions
  hf_log "Set explorer show file extensions " 
  New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideFileExt -PropertyType DWORD -Value 0 -ea 0 | Out-null
  
  # Disable store search for unknown extensions
  hf_log "Disable store search unknown extensions " 
  New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -ea 0 | Out-null
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoUseStoreOpenWith" -Type DWord -Value 1 -ea 0 | Out-null
 
  # 'Hide Most used Apps in Start Menu'
  hf_log 'Hide Most used Apps in Start Menu'
  Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Start_TrackProgs' -Type DWord -Value 0 -ea 0 | Out-null

  # 'Hide Recently used Apps in Start Menu'
  hf_log 'Hide Recently used Apps in Start Menu'
  Set-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\Explorer' -Name 'HideRecentlyAddedApps' -Type DWord -Value 1 -ea 0 | Out-null
 
  # Remove * from This PC
  # ----------------------------------------
  hf_log "Remove user folders under This PC "
  # Remove Desktop from This PC
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" -ea 0 | Out-null
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" -ea 0 | Out-null
  # Remove Documents from This PC
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" -ea 0 | Out-null
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" -ea 0 | Out-null
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" -ea 0 | Out-null
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" -ea 0 | Out-null
  # Remove Downloads from This PC
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" -ea 0 | Out-null
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" -ea 0 | Out-null
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" -ea 0 | Out-null
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" -ea 0 | Out-null
  # Remove Music from This PC
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" -ea 0 | Out-null
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" -ea 0 | Out-null
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" -ea 0 | Out-null
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" -ea 0 | Out-null
  # Remove Pictures from This PC
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" -ea 0 | Out-null
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" -ea 0 | Out-null
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" -ea 0 | Out-null
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" -ea 0 | Out-null
  # Remove Videos from This PC
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" -ea 0 | Out-null
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" -ea 0 | Out-null
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" -ea 0 | Out-null
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" -ea 0 | Out-null
  # Remove 3D Objects from This PC
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -ea 0 | Out-null
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -ea 0 | Out-null
 
  # Remove unused context menus
  # ----------------------------------------
  hf_log "Remove unused context menu"
  # 'Restore to previous versions'
  hf_log_l2 "Restore to previous version" 
  Remove-Item "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -ea 0 | Out-null
  Remove-Item "HKCR:\CLSID\{450D8FBA-AD25-11D0-98A8-0800361B1103}\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -ea 0 | Out-null
  Remove-Item "HKCR:\Directory\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -ea 0 | Out-null
  Remove-Item "HKCR:\Drive\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -ea 0 | Out-null
  # 'Share with'
  hf_log_l2 "Share with " 
  Set-ItemProperty -LiteralPath 'HKCR:\*\shellex\ContextMenuHandlers\ModernSharing' -Name '(Default)' -Value '' -ea 0 | Out-null
  Set-ItemProperty -LiteralPath 'HKCR:\*\shellex\ContextMenuHandlers\Sharing' -Name '(Default)' -Value '' -ea 0 | Out-null
  Set-ItemProperty -Path 'HKCR:\Directory\shellex\ContextMenuHandlers\Sharing' -Name '(Default)' -Value '' -ea 0 | Out-null
  Set-ItemProperty -Path 'HKCR:\Directory\shellex\CopyHookHandlers\Sharing' -Name '(Default)' -Value '' -ea 0 | Out-null
  Set-ItemProperty -Path 'HKCR:\Directory\shellex\PropertySheetHandlers\Sharing' -Name '(Default)' -Value '' -ea 0 | Out-null
  Set-ItemProperty -Path 'HKCR:\Directory\Background\shellex\ContextMenuHandlers\Sharing' -Name '(Default)' -Value '' -ea 0 | Out-null
  Set-ItemProperty -Path 'HKCR:\Drive\shellex\ContextMenuHandlers\Sharing' -Name '(Default)' -Value '' -ea 0 | Out-null
  Set-ItemProperty -Path 'HKCR:\LibraryFolder\background\shellex\ContextMenuHandlers\Sharing' -Name '(Default)' -Value '' -ea 0 | Out-null
  # for gitg
  hf_log_l2 "gitg" 
  Remove-Item "HKCR:\Directory\shell\gitg" -Recurse -ea 0 | Out-null
  # for add/play with vlc
  hf_log_l2 "Add/play with vlc" 
  Remove-Item "HKCR:\Directory\shell\AddToPlaylistVLC" -Recurse -ea 0 | Out-null
  Remove-Item "HKCR:\Directory\shell\PlayWithVLC" -Recurse -ea 0 | Out-null
  # for git bash
  hf_log_l2 "Git bash" 
  Remove-Item "HKCR:\Directory\shell\git_gui" -Recurse -ea 0 | Out-null
  Remove-Item "HKCR:\Directory\shell\git_shell" -Recurse -ea 0 | Out-null
  # "Open With" 
  hf_log_l2 "Open With "
  Remove-Item -LiteralPath 'HKCR:\*\shellex\OpenWithList' -ea 0 | Out-null
  # Pin To Start 
  hf_log_l2 "Pin To Start "
  Remove-Item -LiteralPath 'HKCR:\*\shellex\ContextMenuHandlers\{90AA3A4E-1CBA-4233-B8BB-535773D48449}' -ea 0 | Out-null
  Remove-Item -LiteralPath 'HKCR:\*\shellex\ContextMenuHandlers\{a2a9545d-a0c2-42b4-9708-a0b2badd77c8}' -ea 0 | Out-null
  Remove-Item 'HKCR:\Folder\shellex\ContextMenuHandlers\PintoStartScreen' -ea 0 | Out-null
  # 'Include in library'
  hf_log_l2 "Include in library " 
  Remove-Item "HKCR:\Folder\ShellEx\ContextMenuHandlers\Library Location" -ea 0 | Out-null
  Remove-Item "HKCR:\Folder\ShellEx\ContextMenuHandlers\Library Location" -ea 0 | Out-null
  # 'Send to'
  hf_log_l2 "Send to " 
  Remove-Item -Path "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\SendTo" -Recurse -ea 0 | Out-null
  # Disable Windows Defender'
  hf_log_l2 "Windows Defender "
  Set-Item "HKCR:\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}\InprocServer32" "" -ea 0 | Out-null
  
  # restart explorer
  hf_explorer_restart
}

function hf_optimize_appx() {
  Invoke-Expression $hf_log_func
  # microsoft
  $pkgs = @(
    'Microsoft.3DBuilder'
    'Microsoft.Appconnector'
    'Microsoft.BingNews'
    'Microsoft.BingSports'
    'Microsoft.BingWeather'
    'Microsoft.CommsPhone'
    'Microsoft.ConnectivityStore'
    'Microsoft.GetHelp'
    'Microsoft.Getstarted'
    'Microsoft.Messaging'
    'Microsoft.Microsoft3DViewer'
    'Microsoft.MicrosoftOfficeHub'
    'Microsoft.MicrosoftSolitaireCollection'
    'Microsoft.MicrosoftStickyNotes'
    'Microsoft.MinecraftUWP'
    'Microsoft.MixedReality.Portal'
    'Microsoft.MSPaint'
    'Microsoft.Office.Desktop'
    'Microsoft.Office.OneNote'
    'Microsoft.Office.Sway'
    'Microsoft.OneConnect'
    'Microsoft.People'
    'Microsoft.Print3D'
    'Microsoft.StorePurchaseApp'
    'Microsoft.Wallet'
    'Microsoft.WindowsAlarms'
    'Microsoft.windowscommunicationsapps'
    'Microsoft.WindowsFeedbackHub'
    'Microsoft.WindowsMaps'
    'Microsoft.WindowsPhone'
    'Microsoft.Xbox.TCUI'
    'Microsoft.XboxApp'
    'Microsoft.XboxGameOverlay'
    'Microsoft.XboxGamingOverlay'
    'Microsoft.XboxIdentityProvider'
    'Microsoft.XboxSpeechToTextOverlay'
    'Microsoft.ZuneMusic'
    'Microsoft.ZuneVideo'
  )
  hf_appx_uninstall @pkgs

  # others
  $pkgs = @(
    '7EE7776C.LinkedInforWindows'
    '9E2F88E3.Twitter'
    'A278AB0D.DisneyMagicKingdoms'
    'A278AB0D.MarchofEmpires'
    'Facebook.Facebook'
    'king.com.BubbleWitch3Saga'
    'king.com.BubbleWitch3Saga'
    'king.com.CandyCrushFriends'
    'king.com.CandyCrushSaga'
    'king.com.CandyCrushSodaSaga'
    'king.com.FarmHeroesSaga_5.34.8.0_x86__kgqvnymyfvs32'
    'king.com.FarmHeroesSaga'
    'NORDCURRENT.COOKINGFEVER'
    'SpotifyAB.SpotifyMusic'
  )
  hf_appx_uninstall @pkgs
}

# ---------------------------------------
# network funcs
# ---------------------------------------

function hf_network_list_wifi_SSIDs() {
  return (netsh wlan show net mode=bssid)
}

# ---------------------------------------
# link funcs
# ---------------------------------------

function hf_link_create($desntination, $source) {
  cmd /c mklink /D $desntination $source
}

# ---------------------------------------
# winpackage funcs
# ---------------------------------------

function hf_winpackage_uninstall_like() {
  Invoke-Expression $hf_log_func" "$args
  foreach ($name in $args) {
    $pkgs = Get-WindowsPackage -Online | Where-Object PackageState -like Installed | Where-Object PackageName -like $name
    if ($pkgs) {
      Invoke-Expression $hf_log_func" "$name
      $pkgs | ForEach-Object { Remove-WindowsPackage -Online -NoRestart $_ }
    }
  }
}

# ---------------------------------------
# appx funcs
# ---------------------------------------

function hf_appx_list_installed() {
  Invoke-Expression $hf_log_func
  Get-AppxPackage -AllUsers | Select-Object Name, PackageFullName
}

function hf_appx_install() {
  Invoke-Expression $hf_log_func" "$args
  foreach ($name in $args) {
    if ( !(Get-AppxPackage -Name $name)) {
      Get-AppxPackage -allusers $name | ForEach-Object { Add-AppxPackage -ea 0 -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" } | Out-null
    }
  }
}

function hf_appx_uninstall() {
  Invoke-Expression $hf_log_func" "$args
  foreach ($name in $args) {
    if (Get-AppxPackage -Name $name) {
      hf_log "uninstall $name"
      Get-AppxPackage -allusers $name | Remove-AppxPackage 
    }
  }
}

function hf_appx_install_essentials() {
  Invoke-Expression $hf_log_func
  $pkgs = @(
    'Microsoft.WindowsStore'
    'Microsoft.WindowsCalculator'
    'Microsoft.Windows.Photos'
    'Microsoft.WindowsFeedbackHub'
    'Microsoft.WindowsTerminal'
    'Microsoft.WindowsCamera'
    'Microsoft.WindowsSoundRecorder'
  )
  hf_appx_install @pkgs
}

# ---------------------------------------
# clean funcs
# ---------------------------------------

function hf_clean_unused_folders() {
  Invoke-Expression $hf_log_func
  $folders = @(
    'Application Data'
    'Cookies'
    'Local Settings'
    'Start Menu'
    '3D Objects'
    'Contacts'
    'Cookies'
    'Favorites'
    'Favorites'
    'Intel'
    'IntelGraphicsProfiles'
    'Links'
    'MicrosoftEdgeBackups'
    'My Documents'
    'NetHood'
    'PrintHood'
    'Recent'
    'Saved Games'
    'Searches'
    'SendTo'
    # 'Documents'
    # 'Pictures/'
  )
  $folders | ForEach-Object { Remove-Item -Force -Recurse -ea 0 $_ }
}

function hf_clean_choco() {
  Invoke-Expression $hf_log_func
  gsudo \tools\BCURRAN3\choco-cleaner.ps1 | Out-Null
}

# ---------------------------------------
# explorer funcs
# ---------------------------------------

function hf_explorer_hide_dotfiles() {
  Get-ChildItem "$env:userprofile\.*" | ForEach-Object { $_.Attributes += "Hidden" }
}

function hf_explorer_open_start_menu_folder() {
  explorer '%ProgramData%\Microsoft\Windows\Start Menu\Programs'
}

function hf_explorer_open_task_bar_folder() {
  explorer '%AppData%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar'
}

function hf_explorer_open_startup_folder() {
  explorer 'shell:startup'
}

function hf_explorer_open_home_folder() {
  explorer $env:userprofile
}
function hf_explorer_open_trash() {
  explorer shell:recyclebinfolder
}

function hf_explorer_restart() {
  taskkill /f /im explorer.exe | Out-Null
  Start-Process explorer.exe
}

# ---------------------------------------
# customize funcs
# ---------------------------------------

function hf_enable_dark_mode() {
  Invoke-Expression $hf_log_func
  reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d 00000000 /f | Out-Null
}

# ---------------------------------------
# permissions funcs
# ---------------------------------------

function hf_adminstrator_user_enable() {
  Invoke-Expression $hf_log_func
  net user administrator /active:yes
}

function hf_adminstrator_user_disable() {
  Invoke-Expression $hf_log_func
  net user administrator /active:no
}

# ---------------------------------------
# choco function
# ---------------------------------------

function hf_choco_install() {
  Invoke-Expression $hf_log_func" "$args
  choco install -y --acceptlicense ($args -join ";")
}

function hf_choco_uninstall() {
  Invoke-Expression $hf_log_func" "$args
  choco uninstall -y --acceptlicense ($args -join ";")
}

function hf_choco_upgrade() {
  Invoke-Expression $hf_log_func
  choco upgrade -y --acceptlicense all
}

function hf_choco_list_installed() {
  Invoke-Expression $hf_log_func
  choco list -l
}

# ---------------------------------------
# wsl function
# ---------------------------------------

function hf_wsl_root() {
  wsl -u root
}

function hf_wsl_list() {
  wsl --list -v
}

function hf_wsl_list_running() {
  wsl --list --running
}

function hf_wsl_terminate_running() {
  wsl -t ((wsl --list --running -split [System.Environment]::NewLine)[3]).split(' ')[0]
}

function hf_wsl_ubuntu_set_default_user() {
  ubuntu.exe config --default-user alan
}

function hf_wsl_enable() {
  Invoke-Expression $hf_log_func
  # https://docs.microsoft.com/en-us/windows/wsl/wsl2-install
  dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
  dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
  Invoke-WebRequest -Uri "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" -Outfile $env:TEMP\wsl_update_x64.msi
  msiexec.exe /I "$env:TEMP\wsl_update_x64.msi"
}

function hf_wsl_set_version2() {
  wsl --set-version Ubuntu 2
}

function hf_wsl_fix_home_user() {
  Invoke-Expression $hf_log_func

  # fix file metadata
  # https://docs.microsoft.com/en-us/windows/wsl/wsl-config
  # https://github.com/Microsoft/WSL/issues/3138
  # https://devblogs.microsoft.com/commandline/chmod-chown-wsl-improvements/
  wsl -u root bash -c 'echo "[automount]" > /etc/wsl.conf'
  wsl -u root bash -c 'echo "enabled=true" >> /etc/wsl.conf'
  wsl -u root bash -c 'echo "root=/mnt" >> /etc/wsl.conf'
  wsl -u root bash -c 'echo "mountFsTab=false" >> /etc/wsl.conf'
  wsl -u root bash -c 'echo "options=\"metadata,uid=1000,gid=1000,umask=0022,fmask=11\"" >> /etc/wsl.conf'
  wsl -t Ubuntu

  # ensure sudoer
  wsl -u root usermod -aG sudo "$env:UserName"
  wsl -u root usermod -aG root "$env:UserName"

  # change default folder to /mnt/c/Users/
  wsl -u root skill -KILL -u $env:UserName
  wsl -u root usermod -d /mnt/c/Users/$env:UserName $env:UserName

  # changing file permissions
  hf_log "Changing file permissions "
  wsl -u root chown $env:UserName:$env:UserName /mnt/c/Users/$env:UserName/*
  wsl -u root chown -R $env:UserName:$env:UserName /mnt/c/Users/$env:UserName/.ssh/*
}

# ---------------------------------------
# install function
# ---------------------------------------

function hf_install_choco() {
  Invoke-Expression $hf_log_func
  if (-Not (Get-Command 'choco' -ea 0)) {
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    Set-Variable "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
    cmd /c 'setx ChocolateyToolsLocation C:\opt\'

    choco feature disable -n checksumFiles
    choco feature disable -n showDownloadProgress
    choco feature disable -n showNonElevatedWarnings
    choco feature disable -n logValidationResultsOnWarnings
    choco feature disable -n logEnvironmentValues 
    choco feature disable -n exitOnRebootDetected
    choco feature disable -n warnOnUpcomingLicenseExpiration
    choco feature enable -n stopOnFirstPackageFailure
    choco feature enable -n skipPackageUpgradesWhenNotInstalled 
    choco feature enable -n logWithoutColor 
    choco feature enable -n allowEmptyChecksumsSecure
    choco feature enable -n allowGlobalConfirmation
    choco feature enable -n failOnAutoUninstaller 
    choco feature enable -n removePackageInformationOnUninstall
    choco feature enable -n useRememberedArgumentsForUpgrades
  }
}

function hf_install_winget() {
  Invoke-Expression $hf_log_func
  $appx_pkg = "$env:TEMP\Microsoft.DesktopAppInstaller.appxbundle"
  If (!(Test-Path $appx_pkg)) {
    Invoke-WebRequest https://github.com/microsoft/winget-cli/releases/download/v0.2.2941/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.appxbundle -OutFile $appx_pkg
  }
  Add-AppPackage $appx_pkg
}

function hf_install_pwsh() {
  Invoke-Expression $hf_log_func
  Invoke-WebRequest -Uri "https://github.com/PowerShell/PowerShell/releases/download/v7.1.0/PowerShell-7.1.0-win-x64.msi" -Outfile $env:TEMP\pwsh_x64.msi
  msiexec.exe /I "$env:TEMP\pwsh_x64"
}

function hf_install_battle_steam_stramio() {
  Invoke-Expression $hf_log_func
  hf_choco_install battle.net steam stremio
}

function hf_install_luacheck() {
  Invoke-Expression $hf_log_func
  $luacheck_path = "C:\tools\luacheck.exe"
  If (!(Test-Path $luacheck_path)) {
    Invoke-WebRequest https://github.com/mpeterv/luacheck/releases/download/0.23.0/luacheck.exe -OutFile $luacheck_path
  }
}

function hf_install_latexindent() {
  Invoke-Expression $hf_log_func
  $latexindent_path = "C:\tools\latexindent.exe"
  If (!(Test-Path $latexindent_path)) {
    Invoke-WebRequest https://github.com/cmhughes/latexindent.pl/releases/download/V3.8.2/latexindent.exe -OutFile $latexindent_path
  }
}

function hf_install_onedrive() {
  Invoke-Expression $hf_log_func
  $onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
  If (!(Test-Path $onedrive)) {
    $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
  }
  Start-Process $onedrive -NoNewWindow -Wait
}

function hf_uninstall_onedrive() {
  Invoke-Expression $hf_log_func
  Stop-Process -Name "OneDrive*"
  Start-Sleep 2
  $onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
  If (!(Test-Path $onedrive)) {
    $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
  }
  Start-Process $onedrive "/uninstall" -NoNewWindow -Wait
  Start-Sleep 2
}

# ---------------------------------------
# config funcs
# ---------------------------------------

function hf_config_install_wt($path) {
  Copy-Item $path $env:userprofile\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
}

function hf_config_installvscode($path) {
  Copy-Item $path .\AppData\Roaming\Code\User\settings.json
}

function hf_config_wt_open() {
  code $env:userprofile\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
}

# ---------------------------------------
# winupdate funcs
# ---------------------------------------

function hf_winupdate_list() {
  Invoke-Expression $hf_log_func
  hf_ps_enable_PSWindowsUpdate
  Get-WindowsUpdate
}

function hf_winupdate_list_last_installed() {
  Invoke-Expression $hf_log_func
  hf_ps_enable_PSWindowsUpdate
  Get-WUHistory -Last 10 | Select-Object Date, Title, Result
}

function hf_winupdate_update() {
  Invoke-Expression $hf_log_func
  hf_ps_enable_PSWindowsUpdate
  $(Install-WindowsUpdate -AcceptAll -IgnoreReboot) | Where-Object { $_ -ne "" }
  hf_log "RequireReboot: $(Get-WURebootStatus -Silent)"
}

function hf_winupdate_update_hidden() {
  Invoke-Expression $hf_log_func
  hf_ps_enable_PSWindowsUpdate
  $(Install-WindowsUpdate -AcceptAll -IgnoreReboot -Hide) | Where-Object { $_ -ne "" }
  hf_log "RequireReboot=$(Get-WURebootStatus -Silent)"
}

# ---------------------------------------
# init funcs
# ---------------------------------------
function hf_sync {
  hf_choco_upgrade
  hf_clean_choco
  hf_winupdate_update
}

function hf_init_windows_sanity() {
  Invoke-Expression $hf_log_func
  hf_clean_unused_folders
  hf_system_disable_password_policy
  hf_optimize_features
  hf_optimize_appx
  hf_optimize_explorer
}

function hf_init_user_nomal() {
  Invoke-Expression $hf_log_func
  hf_log "INFO: (1) in other PowerShell terminal, run hf_init_windows_sanity"
  hf_install_choco
  hf_choco_install google-backup-and-sync googlechrome vlc 7zip ccleaner FoxitReader
}

function hf_init_user_bash() {
  Invoke-Expression $hf_log_func
  hf_log "INFO: (1) in other PowerShell terminal, run hf_init_windows_sanity"
  hf_log "INFO: (2) in other PowerShell terminal, run hf_wsl_enable"
  hf_log "INFO: (3) when WindowsTerminal installed, run hf_config_install_wt <profiles.jon>"
  hf_log "INFO: (4) when Ubuntu installed, run hf_wsl_set_version2"
  hf_log "INFO: (5) when Ubuntu installed, run hf_wsl_fix_home_user"
  hf_install_choco
  hf_install_winget
  hf_choco_install google-backup-and-sync googlechrome vscode pwsh gsudo
  hf_appx_install Microsoft.WindowsTerminal CanonicalGroupLimited.UbuntuonWindows
  hf_path_add 'C:\ProgramData\chocolatey\lib\gsudo\bin'
}