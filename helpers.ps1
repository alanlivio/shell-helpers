#!/bin/powershell

# ---------------------------------------
# load env-cfg
# ---------------------------------------

$SCRIPT_NAME = "$PSScriptRoot\env.ps1"
$SCRIPT_DIR = $PSScriptRoot
$SCRIPT_CFG = "$SCRIPT_DIR\env-cfg.ps1"
if (Test-Path $SCRIPT_CFG) {
  Import-Module -Force -Global $SCRIPT_CFG
}

# ---------------------------------------
# alias
# ---------------------------------------
Set-Alias -Name grep -Value Select-String
Set-Alias -Name choco -Value C:\ProgramData\chocolatey\bin\choco.exe
Set-Alias -Name gsudo -Value C:\ProgramData\chocolatey\lib\gsudo\bin\gsudo.exe

# ---------------------------------------
# go home
# ---------------------------------------
Set-Location ~

# ---------------------------------------
# profile functions
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
# powershell functions
# ---------------------------------------

function hf_powershell_show_function($name) {
  Get-Content Function:\$name
}

function hf_powershell_enable_scripts() {
  Set-ExecutionPolicy unrestricted
}

function hf_powershell_profiles_list() {
  $profile | Select-Object -Property *
}

function hf_powershell_profiles_reset() {
  $profile.AllUsersAllHosts = "\Windows\System32\WindowsPowerShell\v1.0\profile.ps1"
  $profile.AllUsersCurrentHost = "\Windows\System32\WindowsPowerShell\v1.0\Microsoft.PowerShell_profile.ps1"
  $profile.CurrentUserAllHosts = "WindowsPowerShell\profile.ps1"
  $profile.CurrentUserCurrentHost = "WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
}

function hf_powershell_wait_for_fey {
  Write-Host -ForegroundColor YELLOW "`nPress any key to continue..."
  [Console]::ReadKey($true) | Out-Null
}

# ---------------------------------------
# system functions
# ---------------------------------------

function hf_system_rename($new_name) {
  Rename-Computer -NewName "$new_name"
}

Function hf_system_restart {
  Write-Host -ForegroundColor YELLOW "Restarting..."
  Restart-Computer
}

function hf_system_rename($new_name) {
  Rename-Computer -NewName "$new_name"
}

function hf_system_info() {
  cmd.exe /c systeminfo
}

function hf_system_disable_password_policy {
  Write-Host -ForegroundColor YELLOW $MyInvocation.MyCommand.ToString()
  $tmpfile = New-TemporaryFile
  secedit /export /cfg $tmpfile /quiet
  (Get-Content $tmpfile).Replace("PasswordComplexity = 1", "PasswordComplexity = 0").Replace("MaximumPasswordAge = 42", "MaximumPasswordAge = -1") | Out-File $tmpfile
  secedit /configure /db "$env:SYSTEMROOT\security\database\local.sdb" /cfg $tmpfile /areas SECURITYPOLICY | Out-Null
  Remove-Item -Path $tmpfile
}

function hf_system_path_add($addPath) {
  if (Test-Path $addPath) {
    $path = [Environment]::GetEnvironmentVariable('path', 'Machine')
    $regexAddPath = [regex]::Escape($addPath)
    $arrPath = $path -split ';' | Where-Object { $_ -notMatch 
      "^$regexAddPath\\?" }
    $newpath = ($arrPath + $addPath) -join ';'
    [Environment]::SetEnvironmentVariable("path", $newpath, 'Machine')
  }
  else {
    Throw "'$addPath' is not a valid path."
  }
}

# ---------------------------------------
# optimize functions
# ---------------------------------------


function hf_optimize_features() {
  # Visual to performace
  Write-Host -ForegroundColor YELLOW  "-- Visuals to performace ..."
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
  Write-Host -ForegroundColor YELLOW  "-- Remove Fax ..."
  Remove-Printer -Name "Fax" -ea 0

  # XPS Services
  Write-Host -ForegroundColor YELLOW  "-- Remove XPS ..."
  dism.exe /online /quiet /disable-feature /featurename:Printing-XPSServices-Features /norestart

  # Work Folders
  Write-Host -ForegroundColor YELLOW  "-- Remove Work Folders ..."
  dism.exe /online /quiet /disable-feature /featurename:WorkFolders-Client /norestart

  # WindowsMediaPlayer
  Write-Host -ForegroundColor YELLOW  "-- Remove WindowsMediaPlayer ..."
  dism.exe /online /quiet /disable-feature /featurename:WindowsMediaPlayer /norestart
  
  # Remove Lock screen
  Write-Host -ForegroundColor YELLOW  "-- Remove Lockscreen ..."
  If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" | Out-Null
  }
  Set-ItemProperty  -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreen" -Type DWord -Value 1 | Out-Null
  
  # Disable drives Autoplay
  Write-Host -ForegroundColor YELLOW "-- Disabling new drives Autoplay..."
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWord -Value 1  | Out-Null
  
  # Disable offering of Malicious Software Removal Tool through Windows Update
  Write-Host -ForegroundColor YELLOW "-- Disabling Malicious Software Removal Tool offering..."
  If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT" | Out-Null
  }
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT" -Name "DontOfferThroughWUAU" -Type DWord -Value 1
  
  # Disable Remote Assistance
  Write-Host -ForegroundColor YELLOW "-- Disabling Remote Assistance..."
  Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0
  
  # Disable AutoRotation Hotkeys
  Write-Host -ForegroundColor YELLOW "-- Disabling AutoRotation Hotkeys..."
  reg add "HKCU\Software\INTEL\DISPLAY\IGFXCUI\HotKeys" /v "Enable" /t REG_DWORD /d 0 /f | Out-Null
  
  # Disable Sticky keys prompt
  Write-Host -ForegroundColor YELLOW  "-- Disabling Sticky keys prompt..." 
  Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "506" | Out-Null
  
  # Disabling Autorun for all drives
  Write-Host -ForegroundColor YELLOW "-- Disabling Autorun for all drives..."
  If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
  }
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Type DWord -Value 255
  
  # Disable Autorun for all drives
  Write-Host -ForegroundColor YELLOW "-- Disabling Autorun for all drives..."
  If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
  }
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Type DWord -Value 255 | Out-Null
  
  # Disable error reporting
  Write-Host -ForegroundColor YELLOW  "-- Disable error reporting ..."
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f | Out-Null
  
  # Disable license checking
  Write-Host -ForegroundColor YELLOW  "-- Disable license checking ..."
  reg add "HKLM\Software\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" /v NoGenTicket /t REG_DWORD /d 1 /f | Out-Null
  
  # Disable tips
  Write-Host -ForegroundColor YELLOW  "-- Disable tips ..."
  reg add "HKCU\Software\Policies\Microsoft\Windows\CloudContent" /v DisableSoftLanding /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKCU\Software\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsSpotlightFeatures /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKCU\Software\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKCU\Software\Policies\Microsoft\Windows\DataCollection" /v DoNotShowFeedbackNotifications /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKCU\Software\Policies\Microsoft\WindowsInkWorkspace" /v AllowSuggestedAppsInWindowsInkWorkspace /t REG_DWORD /d 0 /f | Out-Null
  
  # Disable Telemetry services
  Write-Host -ForegroundColor YELLOW  "-- Disable Telemetry services ..."
  foreach ($service in @(
      "*diagnosticshub.standardcollector.service*" # Diagnostics Hub 
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
    )) {
    Write-Host -ForegroundColor YELLOW  "   Stopping and disabling $service..."
    Get-Service -Name $service | Stop-Service -WarningAction SilentlyContinue 
    Get-Service -Name $service | Set-Service -StartupType Disabled -ea 0 
  }
}
  
function hf_optimize_features_advanced() {
  # Disable services
  Write-Host -ForegroundColor YELLOW  "-- Disable services ..."
  foreach ($service in @(
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
    )) {
    Write-Host -ForegroundColor YELLOW  "   Stopping and disabling $service..."
    Get-Service -Name $service | Stop-Service -WarningAction SilentlyContinue 
    Get-Service -Name $service | Set-Service -StartupType Disabled -ea 0
  }
}

function hf_optimize_explorer() {
  
  # Use small icons
  Write-Host -ForegroundColor YELLOW  "-- Use small icons ..."
  New-ItemProperty -ea 0 -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarSmallIcons  -PropertyType DWORD -Value 1 -Force | Out-Null
  
  # Hide search button
  Write-Host -ForegroundColor YELLOW  "-- Hide search button ..."
  New-ItemProperty -ea 0 -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name SearchboxTaskbarMode -PropertyType DWORD -Value 0 -Force | Out-Null

  # Hide task view button
  Write-Host -ForegroundColor YELLOW  "-- Hide taskview button ..."
  Remove-Item -Path "HKCR:\Software\Microsoft\Windows\CurrentVersion\Explorer\MultiTaskingView\AllUpView" -Force -Recurse  -ea 0| Out-Null
  New-ItemProperty -ea 0 -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowTaskViewButton  -PropertyType DWORD -Value 0 -Force | Out-Null

  # Hide taskbar people icon
  Write-Host -ForegroundColor YELLOW  "-- Hide people button ..."
  if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
    New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" | Out-Null
  }
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWord -Value 0

  # Disabling file delete confirmation dialog
  Write-Host -ForegroundColor YELLOW  "-- Disabling file delete confirmation dialog..."
  Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "ConfirmFileDelete" -ea 0

  # Disable action center
  Write-Host -ForegroundColor YELLOW  "-- Hide action center button ..."
  if (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer")) {
    New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" | Out-Null
  }
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Type DWord -Value 1
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type DWord -Value 0
  
  # Disable Bing
  Write-Host -ForegroundColor YELLOW  "-- Disable Bing search ..."
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /d "0" /t REG_DWORD /f | Out-Null
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v AllowSearchToUseLocation /d "0" /t REG_DWORD /f | Out-Null
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v CortanaConsent /d "0" /t REG_DWORD /f | Out-Null
  reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v ConnectedSearchUseWeb  /d "0" /t REG_DWORD /f | Out-Null

  # Disable Cortana
  Write-Host -ForegroundColor YELLOW  "-- Disabling Cortana..."
  If (!(Test-Path "HKCU:\Software\Microsoft\Personalization\Settings")) {
    New-Item -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Force | Out-Null
  }
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
  If (!(Test-Path "HKCU:\Software\Microsoft\InputPersonalization")) {
    New-Item -Path "HKCU:\Software\Microsoft\InputPersonalization" -Force | Out-Null
  }
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1 | Out-Null
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1 | Out-Null
  If (!(Test-Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore")) {
    New-Item -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Force | Out-Null | Out-Null 
  } 
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0 | Out-Null
  If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
  }
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0

  # Remove AutoLogger file and restrict directory
  Write-Host -ForegroundColor YELLOW "-- Removing AutoLogger file and restricting directory..."
  $autoLoggerDir = "$env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger"
  If (Test-Path "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl") {
    Remove-Item "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl"  | Out-Null
  }
  icacls $autoLoggerDir /deny SYSTEM:`(OI`)`(CI`)F | Out-Null

  # Hide icons in desktop
  Write-Host -ForegroundColor YELLOW  "-- Hide icons in desktop ..."
  $Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
  Set-ItemProperty -Path $Path -Name "HideIcons" -Value 1

  # Hide recently explorer shortcut
  Write-Host -ForegroundColor YELLOW  "-- Hide recently explorer shortcut ..."
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -Type DWord -Value 0

  Write-Host -ForegroundColor YELLOW "-- Disable easy access keyboard ..."
  Set-ItemProperty "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" "506"
  Set-ItemProperty "HKCU:\Control Panel\Accessibility\Keyboard Response" "Flags" "122"
  Set-ItemProperty "HKCU:\Control Panel\Accessibility\ToggleKeys" "Flags" "58"

  # Set explorer to open to 'This PC'
  Write-Host -ForegroundColor YELLOW  "-- Set explorer to open to 'This PC' ..."
  New-ItemProperty -ea 0 -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name LaunchTo -PropertyType DWORD -Value 1 -Force | Out-Null
  
  # Disable show frequent in Quick acess
   Write-Host -ForegroundColor YELLOW  "-- Disable show frequent in Quick acess ..."
  New-ItemProperty -ea 0 -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name 'ShowFrequent' -Value 0 -PropertyType DWORD -Force | Out-Null
  
  # Remove * from This PC
  Write-Host -ForegroundColor YELLOW  "-- Removing user folders under This PC ..."
  
  # Remove Desktop from This PC
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" -ea 0 -Force | Out-Null
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" -ea 0 -Force | Out-Null
  
  # Remove Documents from This PC
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" -ea 0 -Force | Out-Null
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" -ea 0 -Force | Out-Null
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" -ea 0 -Force | Out-Null
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" -ea 0 -Force | Out-Null
  
  # Remove Downloads from This PC
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" -ea 0 -Force | Out-Null
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" -ea 0 -Force | Out-Null
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" -ea 0 -Force | Out-Null
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" -ea 0 -Force | Out-Null
  
  # Remove Music from This PC
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" -ea 0 -Force | Out-Null
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" -ea 0 -Force | Out-Null
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" -ea 0 -Force | Out-Null
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" -ea 0 -Force | Out-Null
  
  # Remove Pictures from This PC
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" -ea 0 -Force | Out-Null
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" -ea 0 -Force | Out-Null
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" -ea 0 -Force | Out-Null
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" -ea 0 -Force | Out-Null
  
  # Remove Videos from This PC
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" -ea 0 -Force | Out-Null
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" -ea 0 -Force | Out-Null
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" -ea 0 -Force | Out-Null
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" -ea 0 -Force | Out-Null
  
  # Remove 3D Objects from This PC
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -ea 0 -Force | Out-Null
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -ea 0 -Force | Out-Null

  # Set explorers how file extensions
  Write-Host -ForegroundColor YELLOW  "-- Set explorers how file extensions ..."  
  New-ItemProperty -ea 0 -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideFileExt -PropertyType DWORD -Value 0 -Force | Out-Null

  # Disable context menu 'Customize this folder'
  Write-Host -ForegroundColor YELLOW  "-- Disable context menu Customize this folder ...."  
  New-Item -ea 0 -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Force | Out-Null
  New-ItemProperty -ea 0 -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoCustomizeThisFolder -Value 1 -PropertyType DWORD -Force | Out-Null

  # Disable Windows Defender context menu item'
  Write-Host -ForegroundColor YELLOW  "-- Disable Windows Defender context menu item ..."
  Set-Item "HKLM:\SOFTWARE\Classes\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}\InprocServer32" ""

  # Disable context menu 'Restore to previous versions'
  Write-Host -ForegroundColor YELLOW  "-- Disable context menu 'Restore to previous version'..."  
  New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
  Remove-Item "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -ea 0 -Force | Out-Null
  Remove-Item "HKCR:\CLSID\{450D8FBA-AD25-11D0-98A8-0800361B1103}\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -ea 0 -Force | Out-Null
  Remove-Item "HKCR:\Directory\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -ea 0 -Force | Out-Null
  Remove-Item "HKCR:\Drive\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -ea 0 -Force | Out-Null

  # Disable context menu 'Share with'
  # Write-Host -ForegroundColor YELLOW  "-- Disable context menu 'Share with' ..."  
  # Remove-Item "HKCR:\*\shellex\ContextMenuHandlers\ModernSharing" -Recurse -ea 0 

  # Disable context menu 'Include in library'
  Write-Host -ForegroundColor YELLOW  "-- Disable context menu 'Include in library' ..."  
  New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -ea 0 | Out-Null
  Remove-Item "HKCR:\Folder\ShellEx\ContextMenuHandlers\Library Location" -ea 0 | Out-Null
  Remove-Item "HKLM:\SOFTWARE\Classes\Folder\ShellEx\ContextMenuHandlers\Library Location" -ea 0 | Out-Null

  # Disable context menu 'Send to'
  Write-Host -ForegroundColor YELLOW  "-- Disable context menu 'Send to' ..."  
  Remove-Item -Path "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\SendTo" -Force -Recurse -ea 0| Out-Null

  # Disable store search for unknown extensions
  Write-Host -ForegroundColor YELLOW  "-- Disable store search unknown extensions ..."  
  New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -ea 0 | Out-Null
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoUseStoreOpenWith" -Type DWord -Value 1
  
  # restart explorer
  hf_explorer_restart
}

function hf_optimize_store_apps() {
  Write-Host -ForegroundColor YELLOW $MyInvocation.MyCommand.ToString()

  # windows
  $pkgs = '
  A278AB0D.MarchofEmpires
  king.com.BubbleWitch3Saga
  king.com.FarmHeroesSaga_5.34.8.0_x86__kgqvnymyfvs32
  Microsoft.3DBuilder
  Microsoft.Appconnector
  Microsoft.BingNews
  Microsoft.BingSports
  Microsoft.BingWeather
  Microsoft.CommsPhone
  Microsoft.ConnectivityStore
  Microsoft.DesktopAppInstaller
  Microsoft.GetHelp
  Microsoft.Getstarted
  Microsoft.Messaging
  Microsoft.Microsoft3DViewer
  Microsoft.MicrosoftEdge.Stable
  Microsoft.MicrosoftOfficeHub
  Microsoft.MicrosoftSolitaireCollection
  Microsoft.MicrosoftStickyNotes
  Microsoft.MinecraftUWP
  Microsoft.MixedReality.Portal
  Microsoft.MSPaint
  Microsoft.Office.Desktop
  Microsoft.Office.OneNote
  Microsoft.Office.Sway
  Microsoft.MicrosoftOfficeHub
  Microsoft.OneConnect
  Microsoft.People
  Microsoft.Print3D
  Microsoft.StorePurchaseApp
  Microsoft.Wallet
  Microsoft.WindowsAlarms
  Microsoft.windowscommunicationsapps
  Microsoft.WindowsFeedbackHub
  Microsoft.WindowsMaps
  Microsoft.WindowsPhone
  Microsoft.Xbox.TCUI
  Microsoft.XboxApp
  Microsoft.XboxGameOverlay
  Microsoft.XboxGamingOverlay
  Microsoft.XboxIdentityProvider
  Microsoft.XboxSpeechToTextOverlay
  Microsoft.ZuneMusic
  Microsoft.ZuneVideo
  '
  $pkgs -split '\s+|,\s*' -ne '' | ForEach-Object { hf_store_uninstall_app $_ }

  # others
  $pkgs = 'Facebook.Facebook
  SpotifyAB.SpotifyMusic
  9E2F88E3.Twitter
  A278AB0D.DisneyMagicKingdoms
  king.com.CandyCrushFriends
  king.com.BubbleWitch3Saga
  king.com.CandyCrushSodaSaga
  king.com.FarmHeroesSaga
  7EE7776C.LinkedInforWindows
  king.com.CandyCrushSaga
  NORDCURRENT.COOKINGFEVER'
  $pkgs -split '\s+|,\s*' -ne '' | ForEach-Object { hf_store_uninstall_app $_ }
  
  $pkgs = 'App.Support.QuickAssist 
  *Hello-Face*
  *phone*'
  $pkgs -split '\s+|,\s*' -ne '' | ForEach-Object { hf_store_uninstall_package $_ }
}

# ---------------------------------------
# network functions
# ---------------------------------------

function hf_network_list_wifi_SSIDs() {
  return (netsh wlan show net mode=bssid)
}

# ---------------------------------------
# link functions
# ---------------------------------------

function hf_link_create($desntination, $source) {
  cmd /c mklink /D $desntination $source
}

# ---------------------------------------
# store functions
# ---------------------------------------

function hf_store_list_installed() {
  Write-Host -ForegroundColor YELLOW $MyInvocation.MyCommand.ToString()
  Get-AppxPackage -AllUsers | Select-Object Name, PackageFullName
}

function hf_store_install($name) {
  Write-Host $MyInvocation.MyCommand.ToString() "$name"  -ForegroundColor YELLOW
  Get-AppxPackage -allusers $name | ForEach-Object { Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" }
}

function hf_store_uninstall_app($name) {
  Write-Host $MyInvocation.MyCommand.ToString() "$name"  -ForegroundColor YELLOW
  Get-AppxPackage -allusers $name | Remove-AppxPackage 
}

function hf_store_uninstall_package($name) {
  Write-Host $MyInvocation.MyCommand.ToString() "$name"  -ForegroundColor YELLOW
  Get-WindowsPackage -Online | Where-Object PackageName -like "$name" | Remove-WindowsPackage -Online -NoRestart
}

function hf_store_install_essentials() {
  Write-Host $MyInvocation.MyCommand.ToString()  -ForegroundColor YELLOW
  $pkgs = '
  Microsoft.WindowsStore
  Microsoft.WindowsCalculator
  Microsoft.Windows.Photos
  Microsoft.WindowsFeedbackHub
  Microsoft.WindowsTerminal
  Microsoft.WindowsCamera
  Microsoft.WindowsSoundRecorder
  '
  $pkgs -split '\s+|,\s*' -ne '' | ForEach-Object { hf_store_install $_ }
  
}

function hf_store_reinstall_all() {
  Get-AppXPackage -AllUsers | ForEach-Object { Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" }
}

# ---------------------------------------
# clean functions
# ---------------------------------------

function hf_clean_unused_folders() {
  Write-Host -ForegroundColor YELLOW $MyInvocation.MyCommand.ToString()
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
  $folders | ForEach-Object { Remove-Item -Force -Recurse -ErrorAction Ignore $_ }
}

function hf_clean_choco() {
  Write-Host -ForegroundColor YELLOW $MyInvocation.MyCommand.ToString()
  gsudo \tools\BCURRAN3\choco-cleaner.ps1 | Out-Null
}

# ---------------------------------------
# explorer functions
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

function hf_explorer_restart() {
  # restart
  taskkill /f /im explorer.exe | Out-Null
  Start-Process explorer.exe
}

# ---------------------------------------
# customize functions
# ---------------------------------------

function hf_enable_dark_mode() {
  Write-Host -ForegroundColor YELLOW $MyInvocation.MyCommand.ToString()
  reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d 00000000 /f | Out-Null
}

# ---------------------------------------
# permissions functions
# ---------------------------------------

function hf_adminstrator_user_enable() {
  Write-Host -ForegroundColor YELLOW $MyInvocation.MyCommand.ToString()
  net user administrator /active:yes
}

function hf_adminstrator_user_disable() {
  Write-Host -ForegroundColor YELLOW $MyInvocation.MyCommand.ToString()
  net user administrator /active:no
}

# ---------------------------------------
# update functions
# ---------------------------------------

function hf_windows_update() {
  Write-Host -ForegroundColor YELLOW $MyInvocation.MyCommand.ToString()
  control update
  wuauclt /detectnow /updatenow
}

# ---------------------------------------
# choco function
# ---------------------------------------

function hf_choco_install() {
  Write-Host -ForegroundColor YELLOW $MyInvocation.MyCommand.ToString() $args
  choco install -y --acceptlicense ($args -join ";")
}

function hf_choco_uninstall() {
  choco uninstall -y --acceptlicense ($args -join ";")
}

function hf_choco_upgrade() {
  choco upgrade -y --acceptlicense all
}

function hf_choco_list_installed() {
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

function hf_wsl_install_ubuntu() {
  hf_store_install CanonicalGroupLimited.UbuntuonWindows
}

function hf_wsl_enable_features() {
  Write-Output "-- (1) after hf_wsl_enable_features, reboot "
  Write-Output "-- (2) in PowerShell terminal, run hf_wsl_install_ubuntu"
  Write-Output "-- (3) after install ubuntu, in PowerShell terminal, run hf_wsl_fix_home_user"
  Write-Host -ForegroundColor YELLOW $MyInvocation.MyCommand.ToString()
  # https://docs.microsoft.com/en-us/windows/wsl/wsl2-install
  dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
  dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
}

function hf_wsl_fix_home_user() {
  Write-Host -ForegroundColor YELLOW $MyInvocation.MyCommand.ToString()

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
  Write-Host "changing file permissions" -ForegroundColor YELLOW
  wsl -u root chown $env:UserName:$env:UserName /mnt/c/Users/$env:UserName/*
  wsl -u root chown -R $env:UserName:$env:UserName /mnt/c/Users/$env:UserName/.ssh/*
}

# ---------------------------------------
# install function
# ---------------------------------------

function hf_install_chocolatey() {
  if (-Not (Get-Command 'choco' -ea 0)) {
    Write-Host -ForegroundColor YELLOW $MyInvocation.MyCommand.ToString()
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

function hf_install_battle_steam_stramio() {
  hf_choco_install battle.net steam stremio
}

function hf_install_msys() {
  hf_choco_install msys
  hf_system_path_add 'C:\tools\msys64\mingw64\bin'
}

function hf_install_onedrive() {
  $onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
  If (!(Test-Path $onedrive)) {
    $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
  }
  Start-Process $onedrive -NoNewWindow -Wait
}

function hf_uninstall_onedrive() {
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
# config functions
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
# init functions
# ---------------------------------------

function hf_init_windows_sanity() {
  Write-Host -ForegroundColor YELLOW $MyInvocation.MyCommand.ToString()
  hf_clean_unused_folders
  hf_system_disable_password_policy
  hf_optimize_features
  hf_optimize_store_apps
  hf_optimize_explorer
}

function hf_init_user_nomal() {
  Write-Host -ForegroundColor YELLOW $MyInvocation.MyCommand.ToString()
  Write-Output "-- (1) in other PowerShell terminal, run hf_init_windows_sanity"
  hf_install_chocolatey
  hf_choco_install google-backup-and-sync googlechrome vlc 7zip ccleaner FoxitReader
}

function hf_init_user_bash() {
  Write-Host -ForegroundColor YELLOW $MyInvocation.MyCommand.ToString()
  Write-Output "-- (1) install Ubuntu from https://www.microsoft.com/en-us/p/ubuntu/9nblggh4msv6"
  Write-Output "-- (2) install WindowsTerminal from https://www.microsoft.com/en-us/p/windows-terminal/9n0dx20hk701"
  Write-Output "-- (3) in other PowerShell terminal, run hf_config_install_wt <profiles.jon>"
  Write-Output "-- (4) in other PowerShell terminal, run hf_init_windows_sanity"
  hf_install_chocolatey
  hf_choco_install google-backup-and-sync googlechrome vscode gsudo powershell-core
  # latter: vlc 7zip ccleaner FoxitReader choco-cleaner
  hf_system_path_add 'C:\ProgramData\chocolatey\lib\gsudo\bin'
}