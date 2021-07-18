#!/bin/powershell

# ---------------------------------------
# load helpers-cfg
# ---------------------------------------

$SCRIPT_DIR = $PSScriptRoot
$SCRIPT_NAME = "$PSScriptRoot\helpers.ps1"
$SKEL_WT = "$SCRIPT_DIR\skel\wt"
$SKEL_VSCODE = "$SCRIPT_DIR\skel\vscode"
$MSYS_HOME = "C:\msys64"
$MSYS_BASH = "$MSYS_HOME\usr\bin\bash.exe"
$WT_SETTINGS = "${env:userprofile}\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$VSCODE_SETTINGS = "${env:userprofile}\AppData\Roaming\Code\User\settings.json"
$VSCODE_KEYS = "${env:userprofile}\AppData\Roaming\Code\User\keybindings.json"


# ---------------------------------------
# ps preferences
# ---------------------------------------
$ProgressPreference = "SilentlyContinue"

# ---------------------------------------
# alias
# ---------------------------------------
Set-Alias -Name grep -Value Select-String
Set-Alias -Name msysbash -Value C:\msys64\usr\bin\bash.exe # TODO: replace by $MSYS_BASH 
Set-Alias -Name env -Value hf_env
Set-Alias -Name path -Value hf_env_path_show
Set-Alias -Name trash -Value hf_explorer_open_trash

# ---------------------------------------
# log
# ---------------------------------------
$hf_log_func = 'Write-Host -ForegroundColor DarkYellow "--" $MyInvocation.MyCommand.ToString()'

function hf_log_msg() {
  Write-Host -ForegroundColor DarkYellow "--" ($args -join " ")
}
function hf_log_msg_2nd () {
  Write-Host -ForegroundColor DarkYellow "-- " ($args -join " ")
}

# ---------------------------------------
# profile
# ---------------------------------------

function hf_profile_install() {
  Write-Output "Import-Module -Force -Global $SCRIPT_NAME" > $Profile.AllUsersAllHosts
}

function hf_profile_reload() {
  powershell -nologo
}

function hf_profile_load($path) {
  Write-Output "RUN: Import-Module -Force -Global $path"
}

# ---------------------------------------
# HELPERS_INSTALL_OPT
# ---------------------------------------
# if $HELPERS_CFG not defined use from same dir
if (-not ($HELPERS_INSTALL_OPT)) {
  $HELPERS_INSTALL_OPT = "${env:userprofile}\opt\win"
  if ( -not (Test-Path $HELPERS_INSTALL_OPT)) {
    New-Item -ItemType Directory -Path $HELPERS_INSTALL_OPT
  }
}

# ---------------------------------------
# ps
# ---------------------------------------

function hf_ps_ver() {
  Write-Output "$($PSVersionTable.PSEdition.ToString()) $($PSVersionTable.PSVersion.ToString())"
}

function hf_elevate_if_not_admin() {
  $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
  if ( -not ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
    gsudo
  }
}

function hf_ps_enable_appx_if_core() {
  if ( $PSVersionTable.PSEdition -eq "Core") {
    Import-Module -Name Appx -UseWindowsPowershell -WarningAction Ignore 
  }
}

function hf_ps_enable_scheduledtask_if_core() {
  if ( $PSVersionTable.PSEdition -eq "Core") {
    Import-Module -Name ScheduledTasks -UseWindowsPowershell -WarningAction Ignore
  }
}

function hf_ps_module_list() {
  Get-Module
}

function hf_ps_module_show_commands($name) {
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

# ---------------------------------------
# rm
# ---------------------------------------

function hf_rm_rf ($path) {
  Remove-Item -Force -Recurse $path
}

# ---------------------------------------
# reg
# ---------------------------------------

function hf_reg_new_path ($path) {
  if (-not (Test-Path $path)) {
    New-Item -Path $path -ItemType Directory -Force | Out-Null
  }
}

function hf_reg_drives() {
  if ((Get-PSDrive HKCR -ea 0)) {
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
  }
  if (!(Get-PSDrive HKCU)) {
    New-PSDrive -Name HKCU -PSProvider Registry -Root HKEY_CURRENT_USER | Out-Null
  }
  if (!(Get-PSDrive HKLM)) {
    New-PSDrive -Name HKLM -PSProvider Registry -Root HKEY_LOCAL_MACHINE | Out-Null
  }
}

# ---------------------------------------
# system
# ---------------------------------------

Function hf_system_restart {
  Invoke-Expression $hf_log_func
  Restart-Computer
}

function hf_system_rename($new_name) {
  Rename-Computer -NewName "$new_name"
}

function hf_system_info() {
  cmd.exe /c systeminfo
}

function hf_system_admin_user_enable() {
  net user administrator /active:yes
}

function hf_system_admin_user_disable() {
  net user administrator /active:no
}

function hf_system_ver() {
  [Environment]::OSVersion.Version.ToString()
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
# sounds
# ---------------------------------------

function hf_system_disable_beep() {
  Invoke-Expression $hf_log_func
  net stop beep
}

# ---------------------------------------
# path
# ---------------------------------------

function hf_env_refresh() {
  refreshenv 
}

function hf_env_add($name, $value) {
  gsudo [Environment]::SetEnvironmentVariable($name, $value, 'Machine')
}

function hf_env_path_add($addPath) {
  if (Test-Path $addPath) {
    $currentpath = [Environment]::GetEnvironmentVariable('path', 'Machine')
    $regexAddPath = [regex]::Escape($addPath)
    $arrPath = $currentpath -split ';' | Where-Object { $_ -notMatch "^$regexAddPath\\?" }
    $newpath = ($arrPath + $addPath) -join ';'
    [Environment]::SetEnvironmentVariable("path", $newpath, 'Machine')
  }
  else {
    Throw "$addPath' is not a valid path."
  }
}

function hf_env_path_show($addPath) {
  $path = [Environment]::GetEnvironmentVariable('path', 'Machine')
  Write-Output $path
}

function hf_env() {
  [Environment]::GetEnvironmentVariables()
}

# ---------------------------------------
# optimize
# ---------------------------------------

function hf_optimize_services() {
  Invoke-Expression $hf_log_func
  hf_elevate_if_not_admin

  # Visual to performace
  hf_log_msg "Visuals to performace"
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name 'VisualFXSetting' -Value 2
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name 'EnableTransparency' -Value 0
  Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Value 0
  Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value 0
  Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Type Binary -Value ([byte[]](144, 18, 3, 128, 16, 0, 0, 0))
  Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0
  Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value 0
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Value 0
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Value 0
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Value 0

  # Enable dark mode
  hf_log_msg "Enable dark mode "
  Set-ItemProperty -Path HKCU:\AppEvents\Schemes -Name "(Default)" -Value ".None"
  Invoke-Expression $hf_log_func
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d 00000000 /f | Out-Null

  # Disable system sounds
  hf_log_msg "Disable system sounds "
  Set-ItemProperty -Path HKCU:\AppEvents\Schemes -Name "(Default)" -Value ".None"

  # Fax
  hf_log_msg "Remove Fax "
  Remove-Printer -Name "Fax" -ea 0

  # Remove Lock screen
  hf_log_msg "Remove Lockscreen "
  hf_reg_new_path "HKLM:\Software\Policies\Microsoft\Windows\Personalization"
  Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreen" -Value 1
  Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name "DisableLogonBackgroundImage" -Value 1

  # Disable drives Autoplay
  hf_log_msg "Disable new drives Autoplay"
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Value 1

  # Disable offering of Malicious Software Removal Tool through Windows Update
  hf_log_msg "Disable Malicious Software Removal Tool offering"
  New-Item -Path "HKLM:\Software\Policies\Microsoft\MRT" -ea 0
  Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\MRT" -Name "DontOfferThroughWUAU" -Value 1

  # Disable Remote Assistance
  hf_log_msg "Disable Remote Assistance"
  Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Value 0

  # Disable AutoRotation Hotkeys
  hf_log_msg "Disable AutoRotation Hotkeys"
  reg add "HKCU\Software\INTEL\DISPLAY\IGFXCUI\HotKeys" /v "Enable" /t REG_DWORD /d 0 /f | Out-Null

  # Disable Autorun for all drives
  hf_log_msg "Disable Autorun for all drives"
  hf_reg_new_path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
  Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Value 255

  # Disable error reporting
  hf_log_msg "Disable error reporting "
  reg add "HKLM\Software\Policies\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKLM\Software\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f | Out-Null

  # Disable license checking
  hf_log_msg "Disable license checking "
  reg add "HKLM\Software\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" /v NoGenTicket /t REG_DWORD /d 1 /f | Out-Null

  # Disable tips
  hf_log_msg "Disable tips "
  reg add "HKCU\Software\Policies\Microsoft\Windows\CloudContent" /v DisableSoftLanding /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKCU\Software\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsSpotlightFeatures /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKCU\Software\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKCU\Software\Policies\Microsoft\Windows\DataCollection" /v DoNotShowFeedbackNotifications /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKCU\Software\Policies\Microsoft\WindowsInkWorkspace" /v AllowSuggestedAppsInWindowsInkWorkspace /t REG_DWORD /d 0 /f | Out-Null

  # 'Disable Accessibility Keys Prompts
  hf_log_msg 'Disable Accessibility Keys Prompts '
  $path = 'HKCU:\Control Panel\Accessibility\'
  Set-ItemProperty -Path "$path\StickyKeys" -Name 'Flags' -Type String -Value '506'
  Set-ItemProperty -Path "$path\ToggleKeys" -Name 'Flags' -Type String -Value '58'
  Set-ItemProperty -Path "$path\Keyboard Response" -Name 'Flags' -Type String -Value '122'

  # "Disable Windows Timeline
  hf_log_msg "Disable Windows Timeline "
  Set-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\System' -Name 'EnableActivityFeed' -Value 0

  # Disable unused services
  hf_log_msg "Disable unused services "
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
  hf_service_disable $services

  # XPS Services
  hf_log_msg "Disable XPS "
  dism.exe /online /quiet /disable-feature /featurename:Printing-XPSServices-Features /norestart

  # Work Folders
  hf_log_msg "Disable Work Folders "
  dism.exe /online /quiet /disable-feature /featurename:WorkFolders-Client /norestart
  
  # Disable scheduled tasks
  hf_log_msg "Disable scheduled tasks "
  $tasks = @(
    'CCleaner Update'
    'CCleanerSkipUAC'
  )
  hf_scheduledtask_disable @tasks
}

function hf_optimize_explorer() {
  Invoke-Expression $hf_log_func
  hf_elevate_if_not_admin
  hf_reg_drives

  # Use small icons
  hf_log_msg "Use small icons "
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarSmallIcons -Value 1

  # Hide search button
  hf_log_msg "Hide search button "
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name SearchboxTaskbarMode -Value 0

  # Hide task view button
  hf_log_msg "Hide taskview button "
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowTaskViewButton -Value 0

  # Hide taskbar people icon
  hf_log_msg "Hide people button "
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Value 0

  hf_reg_new_path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
  hf_reg_new_path "HKLM:\Software\Policies\Microsoft\Windows\Explorer"
  
  # Disable file delete confirmation dialog
  hf_log_msg "Disable file delete confirmation dialog"
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "ConfirmFileDelete" -Value 0

  # Disable action center
  hf_log_msg "Hide action center button "
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "DisableNotificationCenter" -Value 1
  Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Value 1
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Value 0

  # Disable Bing
  hf_log_msg "Disable Bing search "
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /d "0" /t REG_DWORD /f  | Out-null
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v AllowSearchToUseLocation /d "0" /t REG_DWORD /f | Out-null
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v CortanaConsent /d "0" /t REG_DWORD /f | Out-null
  reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Windows Search" /v ConnectedSearchUseWeb /d "0" /t REG_DWORD /f | Out-null

  # Disable Cortana
  hf_log_msg "Disable Cortana"

  hf_reg_new_path "HKCU:\Software\Microsoft\Personalization\Settings"
  hf_reg_new_path "HKCU:\Software\Microsoft\InputPersonalization"
  hf_reg_new_path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore"
  hf_reg_new_path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search"

  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Value 0
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Value 1
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Value 1
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Value 0
  Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0

  # Hide icons in desktop
  hf_log_msg "Hide icons in desktop "
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 1

  # Hide recently explorer shortcut
  hf_log_msg "Hide recently explorer shortcut "
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -Value 0

  # Set explorer to open to 'This PC'
  hf_log_msg "Set explorer to open to 'This PC "
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name LaunchTo -Value 1

  # Disable show frequent in Quick acess
  hf_log_msg "Disable show frequent in Quick acess "
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name 'ShowFrequent' -Value 0

  # Set explorer how file extensions
  hf_log_msg "Set explorer show file extensions"
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideFileExt -Value 0

  # Disable store search for unknown extensions
  hf_log_msg "Disable store search unknown extensions"
  hf_reg_new_path "HKLM:\Software\Policies\Microsoft\Windows\Explorer"
  Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Explorer" -Name "NoUseStoreOpenWith" -Value 1

  # 'Hide Most used Apps in Start Menu'
  hf_log_msg 'Hide Most used Apps in Start Menu'
  Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Start_TrackProgs' -Value 0

  # 'Hide Recently used Apps in Start Menu'
  hf_log_msg 'Hide Recently used Apps in Start Menu'
  Set-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\Explorer' -Name 'HideRecentlyAddedApps' -Value 1

  # Remove * from This PC
  # ----------------------------------------
  hf_log_msg "Remove user folders under This PC "
  # Remove Desktop from This PC
  Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" -ea 0
  Remove-Item "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" -ea 0
  # Remove Documents from This PC
  Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" -ea 0
  Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" -ea 0
  Remove-Item "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" -ea 0
  Remove-Item "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" -ea 0
  # Remove Downloads from This PC
  Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" -ea 0
  Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" -ea 0
  Remove-Item "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" -ea 0
  Remove-Item "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" -ea 0
  # Remove Music from This PC
  Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" -ea 0
  Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" -ea 0
  Remove-Item "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" -ea 0
  Remove-Item "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" -ea 0
  # Remove Pictures from This PC
  Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" -ea 0
  Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" -ea 0
  Remove-Item "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" -ea 0
  Remove-Item "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" -ea 0
  # Remove Videos from This PC
  Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" -ea 0
  Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" -ea 0
  Remove-Item "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" -ea 0
  Remove-Item "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" -ea 0
  # Remove 3D Objects from This PC
  Remove-Item "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -ea 0
  Remove-Item "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -ea 0

  # Remove unused context menus
  # ----------------------------------------
  hf_log_msg "Remove unused context menu"
  # 'Restore to previous versions'
  hf_log_msg_2nd "Restore to previous version"
  Remove-Item "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -ea 0
  Remove-Item "HKCR:\CLSID\{450D8FBA-AD25-11D0-98A8-0800361B1103}\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -ea 0
  Remove-Item "HKCR:\Directory\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -ea 0
  Remove-Item "HKCR:\Drive\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -ea 0

  # 'Share with'
  # ----------------------------------------
  hf_log_msg_2nd "Share with"
  Remove-Item -LiteralPath "HKCR:\*\shellex\ContextMenuHandlers\Sharing" -ea 0
  Remove-Item -Path "HKCR:\Directory\Background\shellex\ContextMenuHandlers\Sharing" -ea 0
  Remove-Item -Path "HKCR:\Directory\shellex\ContextMenuHandlers\Sharing" -ea 0
  Remove-Item -Path "HKCR:\Drive\shellex\ContextMenuHandlers\Sharing" -ea 0
  # for gitg
  hf_log_msg_2nd "gitg"
  Remove-Item "HKCR:\Directory\shell\gitg" -Recurse -ea 0
  # for add/play with vlc
  hf_log_msg_2nd "Add/play with vlc"
  Remove-Item "HKCR:\Directory\shell\AddToPlaylistVLC" -Recurse -ea 0
  Remove-Item "HKCR:\Directory\shell\PlayWithVLC" -Recurse -ea 0
  # for git bash
  hf_log_msg_2nd "Git bash"
  Remove-Item "HKCR:\Directory\shell\git_gui" -Recurse -ea 0
  Remove-Item "HKCR:\Directory\shell\git_shell" -Recurse -ea 0
  # "Open With"
  hf_log_msg_2nd "Open With "
  Remove-Item -LiteralPath 'HKCR:\*\shellex\OpenWithList' -ea 0
  # Pin To Start
  hf_log_msg_2nd "Pin To Start "
  Remove-Item -LiteralPath 'HKCR:\*\shellex\ContextMenuHandlers\{90AA3A4E-1CBA-4233-B8BB-535773D48449}' -ea 0
  Remove-Item -LiteralPath 'HKCR:\*\shellex\ContextMenuHandlers\{a2a9545d-a0c2-42b4-9708-a0b2badd77c8}' -ea 0
  Remove-Item 'HKCR:\Folder\shellex\ContextMenuHandlers\PintoStartScreen' -ea 0
  # 'Include in library'
  hf_log_msg_2nd "Include in library"
  Remove-Item "HKCR:\Folder\ShellEx\ContextMenuHandlers\Library Location" -ea 0
  Remove-Item "HKCR:\Folder\ShellEx\ContextMenuHandlers\Library Location" -ea 0
  # 'Send to'
  hf_log_msg_2nd "Send to"
  Remove-Item -Path "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\SendTo" -Recurse -ea 0
  # Disable Windows Defender'
  hf_log_msg_2nd "Windows Defender "
  Set-Item "HKCR:\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}\InprocServer32" "" -ea 0

  # restart explorer
  hf_explorer_restart
}

function hf_optimize_appx() {
  Invoke-Expression $hf_log_func
  hf_elevate_if_not_admin
  # microsoft
  $pkgs = @(
    'Microsoft.3DBuilder'
    'Microsoft.549981C3F5F10' # cortana
    'Microsoft.Appconnector'
    'Microsoft.BingNews'
    'Microsoft.BingSports'
    'Microsoft.BingWeather'
    'Microsoft.CommsPhone'
    'Microsoft.ConnectivityStore'
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
    'Microsoft.WindowsMaps'
    'Microsoft.WindowsPhone'
    'Microsoft.Xbox.TCUI'
    'Microsoft.XboxApp'
    'Microsoft.XboxGameOverlay'
    'Microsoft.XboxGamingOverlay'
    'Microsoft.XboxIdentityProvider'
    'Microsoft.XboxSpeechToTextOverlay'
    'Microsoft.YourPhone'
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
# office
# ---------------------------------------

function hf_office_sanity() {
  # disable hyperlink warning
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Office\16.0\Common\Security" -Name "DisableHyperlinkWarning" -Value 1
}

# ---------------------------------------
# network
# ---------------------------------------

function hf_network_list_wifi_SSIDs() {
  return (netsh wlan show net mode=bssid)
}

function hf_network_set_max_users_port() {
  Set-ItemProperty -Path "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters\\" -Name "MaxUserPort " -Value 0xffffffff
}

# ---------------------------------------
# link
# ---------------------------------------

function hf_link_create($desntination, $source) {
  cmd /c mklink /D $desntination $source
}

# ---------------------------------------
# scheduledtask
# ---------------------------------------

function hf_scheduledtask_list_enabled() {
  hf_ps_enable_scheduledtask_if_core
  Get-ScheduledTask | Where-Object { $_.State -eq "Ready" }
}

function hf_scheduledtask_list_enabled() {
  hf_ps_enable_scheduledtask_if_core
  Get-ScheduledTask | Where-Object { $_.State -eq "Disabled" }
}

function hf_scheduledtask_disable() {
  foreach ($name in $args) {
    Invoke-Expression $hf_log_func" "$name
    hf_ps_enable_scheduledtask_if_core
    Disable-ScheduledTask -TaskName $name | Out-null
  }
}

# ---------------------------------------
# service
# ---------------------------------------

function hf_service_list_running() {
  Get-Service | Where-Object { $_.Status -eq "Running" }
}

function hf_service_list_enabled() {
  Get-Service | Where-Object { $_.StartType -eq "Automatic" }
}

function hf_service_list_disabled() {
  Get-Service | Where-Object { $_.StartType -eq "Disabled" }
}

function hf_service_disable($name) {
  foreach ($name in $args) {
    Invoke-Expression $hf_log_func" "$name
    Get-Service -Name $name | Stop-Service -WarningAction SilentlyContinue
    Get-Service -Name $ame | Set-Service -StartupType Disabled -ea 0
  }
}

# ---------------------------------------
# winpackage
# ---------------------------------------

function hf_winpackage_list_enabled() {
  Get-WindowsPackage -Online | Where-Object PackageState -like Installed | ForEach-Object { $_.PackageName }
}

function hf_winpackage_disable_like() {
  Invoke-Expression $hf_log_func
  foreach ($name in $args) {
    $pkgs = Get-WindowsPackage -Online | Where-Object PackageState -like Installed | Where-Object PackageName -like $name
    if ($pkgs) {
      Invoke-Expression $hf_log_func" "$name
      $pkgs | ForEach-Object { Remove-WindowsPackage -Online -NoRestart $_ }
    }
  }
}

# ---------------------------------------
# appx
# ---------------------------------------

function hf_appx_list_installed() {
  Invoke-Expression $hf_log_func
  hf_ps_enable_appx_if_core
  Get-AppxPackage -AllUsers | Select-Object Name, PackageFullName
}

function hf_appx_install() {
  Invoke-Expression $hf_log_func
  hf_ps_enable_appx_if_core
  $pkgs_to_install = ""
  foreach ($name in $args) {
    if ( !(Get-AppxPackage -Name $name)) {
      $pkgs_to_install = "$pkgs_to_install $name"
    }
  }
  if ($pkgs_to_install) {
    hf_log_msg "pkgs_to_install=$pkgs_to_install"
    foreach ($pkg in $pkgs_to_install) {
      gsudo Get-AppxPackage -allusers $pkg | ForEach-Object { Add-AppxPackage -ea 0 -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" } | Out-null
    }
  }
}

function hf_appx_uninstall() {
  Invoke-Expression $hf_log_func
  hf_ps_enable_appx_if_core
  foreach ($name in $args) {
    if (Get-AppxPackage -Name $name) {
      hf_log_msg "uninstall $name"
      Get-AppxPackage -allusers $name | Remove-AppxPackage
    }
  }
}

function hf_appx_install_essentials() {
  Invoke-Expression $hf_log_func
  hf_ps_enable_appx_if_core
  $pkgs = @(
    'Microsoft.WindowsStore'
    'Microsoft.WindowsCalculator'
    'Microsoft.Windows.Photos'
    'Microsoft.WindowsFeedbackHub'
    'Microsoft.WindowsCamera'
    'Microsoft.WindowsSoundRecorder'
  )
  hf_appx_install @pkgs
}

# ---------------------------------------
# home
# ---------------------------------------


function hf_explorer_restore_desktop() {
  if (Test-Path "${env:userprofile}\Desktop") {
    mkdir "${env:userprofile}\Desktop"
  }
  reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Desktop" /t REG_SZ /d "C:\Users\${env:username}\Desktop" /f
  reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Desktop" /t REG_EXPAND_SZ /d "${env:userprofile}\Desktop" /f
  attrib +r -s -h "${env:userprofile}\Desktop"
}

function hf_home_hide_dotfiles() {
  Invoke-Expression $hf_log_func
  Get-ChildItem "${env:userprofile}\.*" | ForEach-Object { $_.Attributes += "Hidden" }
}

$HF_CLEAN_DIRS = @(
  'Application Data'
  'Cookies'
  'Local Settings'
  'Start Menu'
  '3D Objects'
  'Contacts'
  'Cookies'
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
)
function hf_home_clean_unused_dirs() {
  Invoke-Expression $hf_log_func
  $HF_CLEAN_DIRS | ForEach-Object { Remove-Item -Force -Recurse -ea 0 $_ }
}

# ---------------------------------------
# explorer
# ---------------------------------------

function hf_explorer_open_trash() {
  Start-Process explorer shell:recyclebinfolder
}

function hf_explorer_restart() {
  taskkill /f /im explorer.exe | Out-Null
  Start-Process explorer.exe
}

$CLEAN_SHORTCUTS = @(
  "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Access.lnk"
  "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Chocolatey Cleaner.lnk"
  "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Publisher.lnk"
  "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Office Tools\"
)

function hf_explorer_clean_unused_shortcuts() {
  Invoke-Expression $hf_log_func
  $CLEAN_SHORTCUTS | ForEach-Object { Remove-Item -Force -Recurse -ea 0 $_ }
}

# ---------------------------------------
# winget
# ---------------------------------------

function hf_winget_list_installed() {
  winget list
}

function hf_winget_settings() {
  winget settings
}

function hf_winget_upgrade() {
  winget upgrade --all --silent
}

function hf_winget_install() {
  Invoke-Expression $hf_log_func
  $pkgs_to_install = ""
  # get installed pkgs
  $tmpfile = New-TemporaryFile
  winget export $tmpfile | Out-null
  $pkgs = ((Get-Content $tmpfile | ConvertFrom-Json).Sources.Packages | ForEach-Object { Write-Output $_.PackageIdentifier }) -join " "
  # select to install
  foreach ($name in $args) {
    if (-not ([string]::IsNullOrEmpty("$name")) -and ($pkgs -notmatch "$name" )) {
      $pkgs_to_install = "$pkgs_to_install $name"
    }
  }
  if ($pkgs_to_install) {
    hf_log_msg "pkgs_to_install=$pkgs_to_install"
    foreach ($pkg in $pkgs_to_install) {
      Invoke-Expression "winget install --silent $pkg"
    }
  }
}

# ---------------------------------------
# choco
# ---------------------------------------

function hf_choco_install() {
  Invoke-Expression $hf_log_func
  if (!(Get-Command 'gsudo.exe' -ea 0)) {
    hf_install_gsudo
  }
  foreach ($name in $args) {
    $pkgs_to_install = ""
    $pkgs = choco list -l
    if (!($pkgs -Match "$name")) {
      $pkgs_to_install = "$pkgs_to_install $name"
    }
  }
  if ($pkgs_to_install) {
    hf_log_msg "pkgs_to_install=$pkgs_to_install"
    gsudo choco install -y --acceptlicense ($pkgs_to_install -join ";")
  }
}

function hf_choco_uninstall() {
  Invoke-Expression $hf_log_func
  gsudo choco uninstall -y --acceptlicense ($args -join ";")
}

function hf_choco_upgrade() {
  Invoke-Expression $hf_log_func
  choco outdated | Out-Null
  if ($LastExitCode -eq 2) {
    gsudo choco upgrade -y --acceptlicense all
  }
}

function hf_choco_list_installed() {
  Invoke-Expression $hf_log_func
  choco list -l
}

function hf_choco_clean() {
  Invoke-Expression $hf_log_func
  gsudo Invoke-Expression "$env:ChocolateyToolsLocation\BCURRAN3\choco-cleaner.ps1" | Out-Null
}

function hf_choco_delete_local_lib() {
  Invoke-Expression $hf_log_func
  gsduo rm -Recurse -Force "'C:\ProgramData\chocolatey\lib"
  gsduo rm -Recurse -Force "'C:\ProgramData\chocolatey\lib-bkp"
}

# ---------------------------------------
# wsl
# ---------------------------------------

function hf_wsl_root() {
  wsl -u root
}

function hf_wsl_list() {
  wsl -l -v
}

function hf_wsl_list_running() {
  wsl -l -v --running
}

function hf_wsl_get_default() {
  [System.Text.Encoding]::Unicode.GetString([System.Text.Encoding]::UTF8.GetBytes((wsl -l))) -split '\s\s+' | ForEach-Object {
    if ($_.Contains('(')) {
      return $_.Split(' ')[0]
    }
  }
}

function hf_wsl_get_default_version() {
  Foreach ($i in (wsl -l -v)) {
    if ($i.Contains('*')) {
      return $i.Split(' ')[-1]
    }
  }
}

function hf_wsl_terminate() {
  wsl -t (hf_wsl_get_default)
}

function hf_wsl_set_version2() {
  wsl --set-version (hf_wsl_get_default) 2
}

function hf_wsl_fix_home() {
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
  # use /Users in path for both windows and wsl
  wsl -u root bash -c 'if ! test -d /Users; then sudo ln -s /mnt/c/Users /Users; fi'

  hf_wsl_terminate

  # enable sudoer
  wsl -u root usermod -aG sudo "$env:UserName"
  wsl -u root usermod -aG root "$env:UserName"

  # change default folder to /mnt/c/Users/
  wsl -u root skill -KILL -u $env:UserName
  wsl -u root usermod -d /mnt/c/Users/$env:UserName $env:UserName
  
  # delete the folder at /home/ and create a link to one at /mnt/c/Users/
  wsl -u root rm -rf  /home/$env:UserName
  wsl -u root ln -s /mnt/c/Users/$env:UserName /home/$env:UserName

  # changing file permissions
  hf_log_msg "Changing file permissions "
  wsl -u root chown $env:UserName:$env:UserName /mnt/c/Users/$env:UserName/*
}


# ---------------------------------------
# keyboard
# ---------------------------------------

function hf_keyboard_lang_stgs_open() {
  cmd /c "rundll32.exe Shell32,Control_RunDLL input.dll,,{C07337D3-DB2C-4D0B-9A93-B722A6C106E2}"
}

function hf_keyboard_disable_shortcut_lang {
  Set-ItemProperty -Path 'HKCU:\Keyboard Layout\Toggle' -Name HotKey -Value 3
  Set-ItemProperty -Path 'HKCU:\Keyboard Layout\Toggle' -Name "Language Hotkey" -Value 3
}

function hf_keyboard_disable_shortcut_altgr() {
  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout" -Name "Scancode Map" -Value ([byte[]](0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x38, 0x00, 0x38, 0xe0, 0x00, 0x00, 0x00, 0x00))
}

# ---------------------------------------
# wt
# ---------------------------------------

function hf_wt_copy_skel_if_no_bash($path) {
  if ((Select-String $WT_SETTINGS -Pattern "bash").Length -eq 0) {
    Copy-Item $SKEL_WT\settings.json $WT_SETTINGS
  }
}

function hf_wt_settings($path) {
  Start-Process ${env:userprofile}\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
}

# ---------------------------------------
# vscode
# ---------------------------------------

function hf_vscode_copy_skel_if_no_bash() {
  if ((Select-String $VSCODE_SETTINGS -Pattern "bash").Length -eq 0) {
    Copy-Item $SKEL_VSCODE\settings.json $VSCODE_SETTINGS
    Copy-Item $SKEL_VSCODE\keybindings.json $VSCODE_KEYS
  }
}

# ---------------------------------------
# winupdate
# ---------------------------------------

function hf_winupdate_list() {
  Invoke-Expression $hf_log_func
  Get-WindowsUpdate
}

function hf_winupdate_list_last_installed() {
  Invoke-Expression $hf_log_func
  Get-WUHistory -Last 10 | Select-Object Date, Title, Result
}

function hf_winupdate_update() {
  Invoke-Expression $hf_log_func
  $(Install-WindowsUpdate -AcceptAll -IgnoreReboot) | Where-Object { 
    if ($_ -is [string]) {
      $_.Split('', [System.StringSplitOptions]::RemoveEmptyEntries) 
    } 
  }
}

# ---------------------------------------
# msys
# ---------------------------------------

function hf_msys_add_to_path() {
  hf_env_path_add "$MSYS_HOME\usr\bin"
  hf_env_path_add "$MSYS_HOME\mingw64\bin"
}

function hf_msys_sanity() {
  msysbash -c 'echo none / cygdrive binary,posix=0,noacl,user 0 0 > /etc/fstab'
  # mount /Users to use in both windows and WSL
  msysbash -c 'echo C:/Users/ /Users ntfs binary,noacl,auto 1 1 >>  /etc/fstab'
  # mount /Users/user-name
  msysbash -c 'echo C:/Users/$env:UserName /home/$env:UserName ntfs binary,noacl,auto 1 1 >> /etc/fstab'
  # mount /mnt/c/ like in WSL
  msysbash -c ' echo /c /mnt/c none bind >> /etc/fstab'
  # set home as /mnt/c/Users/user-name
  # msysbash -c "sed -i 's|db_home: cygwin desc|db_home: windows|g' /etc/nsswitch.conf"
  msysbash -c ' echo db_home: windows >> /etc/nsswitch.conf'
  hf_env_add "LANG" "en_US.UTF-8"
}

# ---------------------------------------
# install
# ---------------------------------------

function hf_install_choco() {
  Invoke-Expression $hf_log_func
  if (!(Get-Command 'choco.exe' -ea 0)) {
    hf_elevate_if_not_admin
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    hf_env_path_add "%ALLUSERSPROFILE%\chocolatey\bin"
    cmd /c 'setx ChocolateyToolsLocation C:\opt\'
    $chocotools = [Environment]::GetEnvironmentVariable('ChocolateyToolsLocation')
    hf_env_path_add $chocotools

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

    # enable use without restarting Powershell
    refreshenv
  }
}

function hf_install_gsudo() {
  Invoke-Expression $hf_log_func
  if (!(Get-Command 'gsudo.exe' -ea 0)) {
    hf_winget_install gsudo
    hf_env_path_add 'C:\Program Files (x86)\gsudo'
  }
}

function hf_install_winget() {
  Invoke-Expression $hf_log_func
  if (!(Get-Command 'winget.exe' -ea 0)) {
    hf_appx_install Microsoft.DesktopAppInstaller
  }
}

function hf_install_battle_steam() {
  Invoke-Expression $hf_log_func
  hf_winget_install Blizzard.BattleNet Valve.Steam
}

function hf_install_onedrive() {
  Invoke-Expression $hf_log_func
  $onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
  if (!(Test-Path $onedrive)) {
    $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
  }
  Start-Process $onedrive -NoNewWindow -Wait
}

function hf_install_wt() {
  hf_install_winget
  if (!(Get-Command 'wt.exe' -ea 0)) {
    hf_winget_install Microsoft.WindowsTerminal
  }
}

function hf_install_python() {
  hf_install_winget
  if (!(Test-Path "C:\Python*")) {
    gsudo choco install python
  }
}

function hf_install_wsl_ubuntu() {
  # this helper automate the process describred in https://docs.microsoft.com/en-us/windows/wsl/wsl2-install
  Invoke-Expression $hf_log_func

  # install winget
  if (!(Get-Command "winget.exe" -ea 0)) {
    hf_log_msg "INFO: winget is not installed, installing..."
    hf_install_winget
  } 
  # enable wsl feature (require restart)
  if (!(Get-Command 'wsl.exe' -ea 0)) {
    hf_log_msg "INFO: Windows features for WSL not enabled, enabling..."
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    hf_log_msg "INFO: restart windows and run hf_setup_ubuntu again"
    return
  }
  # install ubuntu
  if (!(Get-Command "ubuntu*.exe" -ea 0)) {
    hf_log_msg "INFO: Ubuntu is not installed, installing..."
    hf_winget_install Canonical.Ubuntu
  } 
  # configure ubuntu distro
  wsl -l | Out-null
  if ($LastExitCode -eq -1) {
    hf_log_msg "INFO: Ubuntu is not configured, running..."
    Invoke-Expression (Get-Command "ubuntu*.exe").Source
  }
  # enable wsl 2
  wsl -l -v | Out-null # -v is only avaliable in wsl 2
  if ($LastExitCode -eq -1) {
    Invoke-WebRequest -Uri "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" -Outfile $env:TEMP\wsl_update_x64.msi
    msiexec.exe /I "$env:TEMP\wsl_update_x64.msi"
  }
  # set to version 2
  if ((hf_wsl_get_default_version) -eq 1) {
    hf_wsl_set_version2 hf_wsl_get_default
  }
  # fix home user to \Users
  if (!(wsl echo '$HOME').Contains("Users")) {
    hf_wsl_fix_home
  }
}

function hf_install_git() {
  Invoke-Expression $hf_log_func
  if (!(Get-Command 'git.exe' -ea 0)) {
    hf_winget_install Git.Git
  }
}

function hf_install_vscode() {
  Invoke-Expression $hf_log_func
  if (!(Get-Command 'code.exe' -ea 0)) {
    hf_winget_install Microsoft.VisualStudioCode
  }
}

function hf_install_wget() {
  Invoke-Expression $hf_log_func
  $wget_path = "C:\Program Files (x86)\GnuWin32\bin\"
  if (!(Test-Path $wget_path)) {
    hf_winget_install GnuWin32.Wget
    hf_env_path_add "$wget_path"
  }
}

function hf_install_msys() {
  Invoke-Expression $hf_log_func
  if (!(Test-Path $MSYS_BASH)) {
    hf_winget_install msys2.msys2
    hf_msys_sanity
  }
}

# ---------------------------------------
# uninstall
# ---------------------------------------

function hf_uninstall_onedrive() {
  Invoke-Expression $hf_log_func
  Stop-Process -Name "OneDrive*"
  Start-Sleep 2
  $onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
  if (!(Test-Path $onedrive)) {
    $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
  }
  Start-Process $onedrive "/uninstall" -NoNewWindow -Wait
  Start-Sleep 2
}

# ---------------------------------------
# setup
# ---------------------------------------

function hf_setup_windows_sanity() {
  Invoke-Expression $hf_log_func
  hf_optimize_services
  hf_optimize_appx
  hf_optimize_explorer
  hf_keyboard_disable_shortcut_lang
  hf_keyboard_disable_shortcut_altgr
}

function hf_setup_windows_common_user() {
  Invoke-Expression $hf_log_func
  hf_setup_windows_sanity
  hf_winget_install Google.Chrome VideoLAN.VLC 7zip.7zip Piriform.CCleaner
}

function hf_setup_windows() {
  Invoke-Expression $hf_log_func
  hf_setup_windows_sanity
  # disable passwd
  hf_system_disable_password_policy
  # cleanup unused
  hf_home_clean_unused_dirs
  hf_home_hide_dotfiles
  hf_explorer_clean_unused_shortcuts
  # install choco, gsudo, winget
  hf_install_choco
  hf_install_gsudo
  hf_install_winget
  # install git, git-bash, wt, vscode
  hf_install_git
  hf_install_wget
  hf_install_python
  hf_install_wt
  hf_wt_copy_skel_if_no_bash
  hf_install_vscode
  hf_vscode_copy_skel_if_no_bash
}
