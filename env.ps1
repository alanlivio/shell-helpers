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

Function Restart {
  Write-Host -ForegroundColor YELLOW "Restarting..."
  Restart-Computer
}

function hf_system_rename($new_name) {
  Rename-Computer -NewName "$new_name"
}

function hf_system_win_version() {
  Get-ComputerInfo | Select-Object windowsversion
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
  New-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name 'VisualFXSetting' -Value 2 -PropertyType DWORD -Force | Out-Null
  New-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name 'EnableTransparency' -Value 0 -PropertyType DWORD -Force | Out-Null
  Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Type String -Value 0 | Out-Null
  Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type String -Value 0 | Out-Null
  Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Type Binary -Value ([byte[]](144,18,3,128,16,0,0,0)) | Out-Null
  Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Type String -Value 0 | Out-Null
  Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Type DWord -Value 0 | Out-Null
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Type DWord -Value 0 | Out-Null
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Type DWord -Value 0 | Out-Null
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Type DWord -Value 0 | Out-Null
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Type DWord -Value 0 | Out-Null
  
  # Fax
  Write-Host -ForegroundColor YELLOW  "-- Remove Fax ..."
  Remove-Printer -Name "Fax" -ErrorAction SilentlyContinue

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
  
  # Remove OneDrive
  Write-Host -ForegroundColor YELLOW  "-- Remove OneDrive ..."
  c:\\Windows\\SysWOW64\\OneDriveSetup.exe /uninstall
  
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
  reg add "HKEY_CURRENT_USER\Software\INTEL\DISPLAY\IGFXCUI\HotKeys" /v "Enable" /t REG_DWORD /d 0 /f | Out-Null
  
  # Disable Sticky keys prompt
  Write-Host -ForegroundColor YELLOW  "-- Disabling Sticky keys prompt..." 
  Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "506" | Out-Null
  
  # Disabling Autorun for all drives...
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
  
  # Disable Telemetry services
  Write-Host -ForegroundColor YELLOW  "-- Disable Telemetry services ..."
  foreach ($service in @(
      "*diagnosticshub.standardcollector.service*" # Diagnostics Hub 
      "*dmwappushservice*" # Device Management WAP Push message Routing Service
      "*diagsvc*" # Diagnostic Execution Service
      "*DiagTrack*" # Connected User Experiences and Telemetry
      "*lfsvc*" # Geolocation Service
      "*MapsBroker*" # Downloaded Maps Manager
      "*NetTcpPortSharing*" # Net.Tcp Port Sharing Service
      "*RetailDemo*" # Retail Demo Service
      "*RemoteRegistry*" # Remote Registry
      "*RemoteAccess*" # Routing and Remote Access (routing services to businesses in LAN)
      "*TrkWks*" # Distributed Link Tracking Client
      "*xbgm*"
      "*XblAuthManager*" # Xbox Live Auth Manager
      "*XboxNetApiSvc*" # Xbox Live Networking Service
      "*XblGameSave*" # Xbox Live Game Save
    )) {
    Write-Host -ForegroundColor YELLOW  "   Stopping and disabling $service..."
    Get-Service -Name $service | Stop-Service -WarningAction SilentlyContinue | Out-Null
    Get-Service -Name $service | Set-Service -StartupType Disabled -ea 0 | Out-Null
  }
  
  # Disable Xbox services
  Write-Host -ForegroundColor YELLOW  "-- Disable Xbox  services ..."
  foreach ($service in @(
      "*HomeGroupListener*"
    )) {
    Write-Host -ForegroundColor YELLOW  "   Stopping and disabling $service..."
    Get-Service -Name $service | Stop-Service -WarningAction SilentlyContinue | Out-Null
    Get-Service -Name $service | Set-Service -StartupType Disabled -ea 0 | Out-Null
  }
  
  # Disable more services
  Write-Host -ForegroundColor YELLOW  "-- Disable more services ..."
  reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d 0 /f | Out-Null
  reg add "HKLM\SYSTEM\ControlSet001\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /v Start /t REG_DWORD /d 0 /f | Out-Null
  reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v AITEnable /t REG_DWORD /d 0 /f | Out-Null
  reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v DisableInventory /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v DisablePCA /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v DisableUAR /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" /v "EnabledV9" /t REG_DWORD /d 0 /f | Out-Null
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /t REG_DWORD /d 0 /f | Out-Null
  reg add "HKCU\Software\Microsoft\Internet Explorer\PhishingFilter" /v "EnabledV9" /t REG_DWORD /d 0 /f | Out-Null
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoRecentDocsHistory" /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\CompatTelRunner.exe" /v Debugger /t REG_SZ /d "%windir%\System32\taskkill.exe" /f | Out-Null
  reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\DeviceCensus.exe" /v Debugger /t REG_SZ /d "%windir%\System32\taskkill.exe" /f | Out-Null
  
  # Disable error reporting
  Write-Host -ForegroundColor YELLOW  "-- Disable error reporting ..."
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f | Out-Null
  
  # Disable license checking
  Write-Host -ForegroundColor YELLOW  "-- Disable license checking ..."
  reg add "HKLM\Software\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" /v NoGenTicket /t REG_DWORD /d 1 /f | Out-Null
  
  # Disable tips
  Write-Host -ForegroundColor YELLOW  "-- Disable tips ..."
  reg add "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v DisableSoftLanding /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsSpotlightFeatures /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKLM\Software\Policies\Microsoft\Windows\DataCollection" /v DoNotShowFeedbackNotifications /t REG_DWORD /d 1 /f | Out-Null
  reg add "HKLM\Software\Policies\Microsoft\WindowsInkWorkspace" /v AllowSuggestedAppsInWindowsInkWorkspace /t REG_DWORD /d 0 /f | Out-Null
  
  # Disable Scheduled tasks
  Write-Host -ForegroundColor YELLOW  "-- Disable tasks ..."
  foreach ($task in @(
    "*AitAgent*"
    "*AnalyzeSystem*"
    "*Appraiser*"
    "*CloudExperienceHost*"
    "*Consolidator*"
    "*DiskDiagnosticDataCollector*"
    "*DsSvcCleanup*"
    "*DsSvcCleanup*"
    "*EnableLicenseAcquisition*"
    "*FamilySafetyMonitor*"
    "*FamilySafetyMonitorToastTask*"
    "*FamilySafetyRefresh*"
    "*FamilySafetyRefreshTask*"
    "*FamilySafetyUpload*"
    "*GatherNetworkInfo*"
    "*KernelCeipTask*"
    "*License Validation*"
    "*LicenseAcquisition*"
    "*LoginCheck*"
    "*Proxy*"
    "*QueueReporting*"
    "*RecommendedTroubleshootingScanner*"
    "*SmartScreenSpecific*"
    "*StartupAppTask*"
    "*TempSignedLicenseExchange*"
    "*UsbCeip*"
    "*UsbCeip*"
    "*WinSAT*"
    "*XblGameSaveTask*"
    "*XblGameSaveTaskLogon*"
  )) {
    Write-Host -ForegroundColor YELLOW  " Disabling $task..."
    Get-ScheduledTask -TaskName $task | Disable-ScheduledTask -ea 0 | Out-Null
  }
}

function hf_optimize_features_advanced() {
  # Disable services
  Write-Host -ForegroundColor YELLOW  "-- Disable services ..."
  foreach ($service in @(
      "*AppleOSSMgr*" # bootcamp: Apple OS Switch Manager
      "*Bonjour Service*" # bootcamp: Bonjour Service
      "*ClickToRunSvc*" # Office Click-to-Run Service
      "*EventLog*" # Windows Event Log
      "*FoxitReaderUpdateService*" # Foxit Reader Update Service
      "*gupdate*" # Google Update Service (gupdate)
      "*gupdatem*" # Google Update Service (gupdatem)
      "*PcaSvc*" # Program Compatibility Assistant Service
      "*PhoneSvc*" # Phone Service
      "*SessionEnv*" # Remote Desktop Configuration
      "*SysMain*" # SysMain (Maintains and improves system performance)
      "*TermService*" # Remote Desktop Services
      "*Themes*" # Themes (Provides user experience theme management.)
      "*TroubleshootingSvc*" # Recommended Troubleshooting Service
      "*UevAgentService*" # User Experience Virtualization Service (application and OS settings roaming) !!!
      "*UmRdpService*" # Remote Desktop Services UserMode Port Redirector
      "*WbioSrvc*" # Windows Biometric Service
      "*wercplsupport*" # Problem Reports Control Panel Support
      "*WerSvc*" # Windows Error Reporting Service
      "*wisvc*" # Windows Insider Service
      "ndu" # Windows Network Data Usage Monitor
      # "*AppVClient*" # Microsoft App-V Client
      # "*AxInstSV*" # ActiveX Installer
      # "*BootCampService*" # bootcamp: Boot Camp Service
      # "*HomeGroupListener*"
      # "*SecurityHealthService*"
      # "*SharedAccess*" # Internet Connection Sharing (ICS)
      # "*shpamsvc*" # Shared PC Account Manager
      # "*ssh-agent*" # OpenSSH Authentication Agent
      # "*TabletInputService*" # Touch Keyboard and Handwriting Panel Service. # OBS removing the next will disable WindowsTerminal input https://github.com/microsoft/terminal/issues/4448
    )) {
    Write-Host -ForegroundColor YELLOW  "   Stopping and disabling $service..."
    Get-Service -Name $service | Stop-Service -WarningAction SilentlyContinue | Out-Null
    Get-Service -Name $service | Set-Service -StartupType Disabled -ea 0 | Out-Null
  }
  
  # Disable Scheduled tasks
  Write-Host -ForegroundColor YELLOW  "-- Disable tasks ..."
  foreach ($task in @(
    "*CCleaner*"
    "*GoogleCrashHandler*"
    "*cftmon*"
    "*SecurityHealthService*"
    "Windows Defender Cache Maintenance"
    "Windows Defender Cleanup"
    "Windows Defender Scheduled Scan"
    "Windows Defender Verification"
  )) {
    Write-Host -ForegroundColor YELLOW  "   Disabling $task..."
    Get-ScheduledTask -TaskName $task | Disable-ScheduledTask -ea 0 | Out-Null
  }
}

function hf_optimize_explorer() {
  
  # Use small icons
  Write-Host -ForegroundColor YELLOW  "-- Use small icons ..."
  New-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarSmallIcons  -PropertyType DWORD -Value 1 -Force | Out-Null
  
  # Hide search button
  Write-Host -ForegroundColor YELLOW  "-- Hide search button ..."
  New-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name SearchboxTaskbarMode -PropertyType DWORD -Value 0 -Force | Out-Null

  # Hide task view button
  Write-Host -ForegroundColor YELLOW  "-- Hide taskview button ..."
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\Software\Microsoft\Windows\CurrentVersion\Explorer\MultiTaskingView\AllUpView" -Force -Recurse | Out-Null
  New-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowTaskViewButton  -PropertyType DWORD -Value 0 -Force | Out-Null

  # Hide taskbar people icon
  Write-Host -ForegroundColor YELLOW  "-- Hide people button ..."
  if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
    New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" | Out-Null
  }
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWord -Value 0

  # Disabling file delete confirmation dialog
  Write-Output "Disabling file delete confirmation dialog..."
  Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "ConfirmFileDelete" -ErrorAction SilentlyContinue

  # Disable action center
  Write-Host -ForegroundColor YELLOW  "-- Hide action center button ..."
  if (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer")) {
    New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" | Out-Null
  }
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Type DWord -Value 1
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type DWord -Value 0
  
  # Disable Bing
  Write-Host -ForegroundColor YELLOW  "-- Disable Bing search ..."
  reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /d "0" /t REG_DWORD /f | Out-Null
  reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search" /v AllowSearchToUseLocation /d "0" /t REG_DWORD /f | Out-Null
  reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search" /v CortanaConsent /d "0" /t REG_DWORD /f | Out-Null
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
      New-Item -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Force | Out-Null| Out-Null 
  } 
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0 | Out-Null
  If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
  }
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0

  # Remove AutoLogger file and restrict directory
  Write-Host -ForegroundColor YELLOW "Removing AutoLogger file and restricting directory..."
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

  Write-Host -ForegroundColor YELLOW "Disable easy access keyboard ..."
  Set-ItemProperty "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" "506"
  Set-ItemProperty "HKCU:\Control Panel\Accessibility\Keyboard Response" "Flags" "122"
  Set-ItemProperty "HKCU:\Control Panel\Accessibility\ToggleKeys" "Flags" "58"

  # Set explorer to open to 'This PC'
  Write-Host -ForegroundColor YELLOW  "-- Set explorer to open to 'This PC' ..."
  New-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name LaunchTo -PropertyType DWORD -Value 1 -Force | Out-Null

  # Remove * from This PC
  Write-Host -ForegroundColor YELLOW  "Removing user folders under This PC ..."
  
  # Remove Desktop from This PC
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}"
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}"
  
  # Remove Documents from This PC
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}"
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}"
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}"
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}"
  
  # Remove Downloads from This PC
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}"
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}"
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}"
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}"
  
  # Remove Music from This PC
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}"
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}"
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}"
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}"
  
  # Remove Pictures from This PC
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}"
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}"
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}"
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}"
  
  # Remove Videos from This PC
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}"
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}"
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}"
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}"
  
  # Remove 3D Objects from This PC
  Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
  Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"

  # Set explorers how file extensions
  Write-Host -ForegroundColor YELLOW  "-- Set explorers how file extensions ..."  
  New-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideFileExt -PropertyType DWORD -Value 0 -Force | Out-Null

  # Disable context menu 'Customize this folder'
  Write-Host -ForegroundColor YELLOW  "-- Disable context menu Customize this folder ...."  
  New-Item -ErrorAction SilentlyContinue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Force | Out-Null
  New-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoCustomizeThisFolder -Value 1 -PropertyType DWORD -Force | Out-Null

  # Disable Windows Defender context menu item'
  Write-Output "Disable Windows Defender context menu item ..."
  Set-Item "HKLM:\SOFTWARE\Classes\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}\InprocServer32" ""

  # Disable context menu 'Restore to previous versions'
  Write-Host -ForegroundColor YELLOW  "-- Disable context menu 'Restore to previous version'..."  
  New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
  foreach ($path in @(
      "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}"
      "HKCR:\CLSID\{450D8FBA-AD25-11D0-98A8-0800361B1103}\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}"
      "HKCR:\Directory\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}"
      "HKCR:\Drive\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}"
    )) {
    Remove-Item $path -Recurse -ea 0 -Force -Recurse | Out-Null
  }

  # Disable context menu 'Share with'
  Write-Host -ForegroundColor YELLOW  "-- Disable context menu 'Share with' ..."  
  Remove-Item "HKCR:\*\shellex\ContextMenuHandlers\ModernSharing" -Recurse -ea 0 

  # Disable context menu 'Include in library'
  Write-Host -ForegroundColor YELLOW  "-- Disable context menu 'Include in library' ..."  
  New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
  foreach ($path in @(
      "HKCR:\Folder\ShellEx\ContextMenuHandlers\Library Location"
      "HKLM:\SOFTWARE\Classes\Folder\ShellEx\ContextMenuHandlers\Library Location"
    )) {
    Remove-Item $path -Recurse -ea 0  | Out-Null
  }

  # Disable context menu 'Send to'
  Write-Host -ForegroundColor YELLOW  "-- Disable context menu 'Send to' ..."  
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\SendTo" -Force -Recurse | Out-Null

  # Disable store search for unknown extensions
  Write-Host -ForegroundColor YELLOW  "-- Disable store search for unknown extensions '..."  
  If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" | Out-Null
  }
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoUseStoreOpenWith" -Type DWord -Value 1
  
  # restart explorer
  hf_explorer_restart
}

function hf_optimize_store_apps() {
  Write-Host -ForegroundColor YELLOW $MyInvocation.MyCommand.ToString()

  # windows
  $pkgs = '
  Microsoft.MicrosoftEdge.Stable
  Microsoft.XboxGameOverlay
  Microsoft.GetHelp
  Microsoft.XboxApp
  Microsoft.Xbox.TCUI
  Microsoft.XboxSpeechToTextOverlay
  Microsoft.Wallet
  Microsoft.MinecraftUWP
  A278AB0D.MarchofEmpires
  king.com.FarmHeroesSaga_5.34.8.0_x86__kgqvnymyfvs32
  king.com.BubbleWitch3Saga
  Microsoft.Messaging
  Microsoft.Appconnector
  Microsoft.BingNews
  Microsoft.SkypeApp
  Microsoft.BingSports
  Microsoft.CommsPhone
  Microsoft.ConnectivityStore
  Microsoft.Office.Sway
  Microsoft.WindowsPhone
  Microsoft.BingNews
  Microsoft.XboxIdentityProvider
  Microsoft.StorePurchaseApp
  Microsoft.DesktopAppInstaller
  Microsoft.BingWeather
  Microsoft.MicrosoftStickyNotes
  Microsoft.MicrosoftSolitaireCollection
  Microsoft.OneConnect
  Microsoft.People
  Microsoft.ZuneMusic
  Microsoft.ZuneVideo
  Microsoft.Getstarted
  Microsoft.XboxApp
  Microsoft.windowscommunicationsapps
  Microsoft.WindowsMaps
  Microsoft.3DBuilder
  Microsoft.WindowsFeedbackHub
  Microsoft.MicrosoftOfficeHub
  Microsoft.3DBuilder
  Microsoft.OneDrive
  Microsoft.Print3D
  Microsoft.Office.OneNote
  Microsoft.Microsoft3DViewer
  Microsoft.XboxGamingOverlay
  Microsoft.MSPaint
  Microsoft.Office.Desktop
  Microsoft.MicrosoftSolitaireCollection
  Microsoft.MixedReality.Portal'
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
# explorer functions
# ---------------------------------------

function hf_explorer_hide_dotfiles() {
  Get-ChildItem "$env:userprofile\.*" | ForEach-Object { $_.Attributes += "Hidden" }
}

function hf_explorer_remove_unused_folders() {
  Write-Host -ForegroundColor YELLOW $MyInvocation.MyCommand.ToString()
  $folders = @("Favorites/", "OneDrive/", "Pictures/", "Public/", "Templates/", "Videos/", "Music/", "Links/", "Saved Games/", "Searches/", "SendTo/", "PrintHood", "MicrosoftEdgeBackups/", "IntelGraphicsProfiles/", "Contacts/", "3D Objects/", "Recent/", "NetHood/")
  $folders | ForEach-Object { Remove-Item -Force -Recurse -ErrorAction Ignore $_ }
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
  reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d 00000000 /f | Out-Null
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

function hf_choco_cleaner() {
  hf_choco_install choco-cleaner
  \ProgramData\chocolatey\bin\Choco-Cleaner.ps1
}

function hf_choco_install() {
  choco install -y --acceptlicense --no-progress --ignorechecksum  ($args -join ";")
}

function hf_choco_uninstall() {
  choco uninstall -y --acceptlicense --no-progress ($args -join ";")
}

function hf_choco_upgrade() {
  choco upgrade -y --acceptlicense --no-progress  --ignorechecksum all
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
  wsl -u root touch /etc/wsl.conf
  wsl -u root  bash -c 'echo "[automount]" > /etc/wsl.conf'
  wsl -u root  bash -c 'echo "enabled=true" >> /etc/wsl.conf'
  wsl -u root  bash -c 'echo "root=/mnt" >> /etc/wsl.conf'
  wsl -u root  bash -c 'echo "mountFsTab=false" >> /etc/wsl.conf'
  wsl -u root  bash -c 'echo "options=\"metadata,uid=1000,gid=1000,umask=0022,fmask=11\"" >> /etc/wsl.conf'
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
  if (-Not (Get-Command 'choco' -errorAction SilentlyContinue)) {
    Write-Host -ForegroundColor YELLOW $MyInvocation.MyCommand.ToString()
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    Set-Variable "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
    cmd /c 'setx ChocolateyToolsLocation C:\opt\'

    choco feature disable -n checksumFiles
    choco feature disable -n showDownloadProgress
    choco feature disable -n showNonElevatedWarnings
    choco feature disable -n logValidationResultsOnWarnings
    choco feature enable -n allowEmptyChecksumsSecure
    choco feature enable -n allowGlobalConfirmation
    choco feature enable -n exitOnRebootDetected
    choco feature enable -n removePackageInformationOnUninstall
    choco feature enable -n useRememberedArgumentsForUpgrades
  }
}

function hf_install_battle_steam_stramio() {
  hf_choco_install battle.net steam stremio
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

function hf_windows_sanity() {
  Write-Host -ForegroundColor YELLOW $MyInvocation.MyCommand.ToString()
  hf_explorer_remove_unused_folders
  hf_system_disable_password_policy
  hf_optimize_features
  hf_optimize_store_apps
  hf_optimize_explorer
}

function hf_windows_init_user_nomal() {
  Write-Host -ForegroundColor YELLOW $MyInvocation.MyCommand.ToString()
  Write-Output "-- (1) in other PowerShell terminal, run hf_windows_sanity"
  hf_install_chocolatey
  hf_choco_install GoogleChrome vlc 7zip ccleaner FoxitReader
}

function hf_windows_init_user_bash() {
  Write-Host -ForegroundColor YELLOW $MyInvocation.MyCommand.ToString()
  Write-Output "-- (1) in other PowerShell terminal, run hf_windows_sanity"
  Write-Output "-- (2) in other PowerShell terminal, run hf_config_install_wt <profiles.jon>"
  hf_install_chocolatey
  hf_choco_install vscode gsudo msys2
  hf_system_path_add 'C:\ProgramData\chocolatey\lib\gsudo\bin'
  hf_system_path_add 'C:\tools\msys64\mingw64\bin'
  hf_choco_install GoogleChrome vlc 7zip ccleaner FoxitReader
}