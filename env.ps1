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
  # https://github.com/adolfintel/Windows10-Privacy
  # https://gist.github.com/alirobe/7f3b34ad89a159e6daa1
  # https://github.com/RanzigeButter/fyWin10/blob/master/fyWin10.ps1
  # https://gist.github.com/chadr/e17308cad6c472e05de3796599d4e142
  
  # Visual to performace
  Write-Host -ForegroundColor YELLOW  "-- Visuals to performace ..."
  New-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name 'VisualFXSetting' -Value 2 -PropertyType DWORD -Force | Out-Null
  New-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name 'EnableTransparency' -Value 0 -PropertyType DWORD -Force | Out-Null
  
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
  
  # Disabledrives Autoplay
  Write-Host -ForegroundColor YELLOW "-- Disabling new drives Autoplay..."
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWord -Value 1  | Out-Null
  
  # Disable Autorun for all drives
  Write-Host -ForegroundColor YELLOW "-- Disabling Autorun for all drives..."
  If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
  }
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Type DWord -Value 255
  
  # Disable services
  Write-Host -ForegroundColor YELLOW  "-- Disable services ..."
  foreach ($service in @(
      "*diagnosticshub.standardcollector.service*"
      "*diagsvc*"
      "*DiagTrack*"
      "*dmwappushservice*"
      "*dmwappushsvc*"
      "*lfsvc*"
      "*MapsBroker*"
      "*OneSyncSvc*"
      "*PcaSvc*"
      "*PhoneSvc*"
      "*RetailDemo*"
      "*SessionEnv*"
      "*shpamsvc*"
      "*SysMain*"
      "*TermService*"
      "*TroubleshootingSvc*"
      "*UmRdpService*"
      "*WbioSrvc*"
      "*wercplsupport*"
      "*WerSvc*"
      "*xbgm*"
      "*XblAuthManager*"
      "*XblGameSave*"
      "*XboxNetApiSvc*"
    )) {
    Write-Host -ForegroundColor YELLOW  "  -- Stopping and disabling $service..."
    Get-Service -Name $service | Stop-Service -WarningAction SilentlyContinue | Out-Null
    Get-Service -Name $service | Set-Service -StartupType Disabled -ea 0 | Out-Null
  }
}

function hf_optimize_explorer() {
  
  # use small icons
  Write-Host -ForegroundColor YELLOW  "-- Use small icons ..."
  New-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarSmallIcons  -PropertyType DWORD -Value 1 -Force | Out-Null

  # hide search button
  Write-Host -ForegroundColor YELLOW  "-- Hide search button ..."
  New-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name SearchboxTaskbarMode -PropertyType DWORD -Value 0 -Force | Out-Null

  # hide task view button
  Write-Host -ForegroundColor YELLOW  "-- Hide taskview button ..."
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\Software\Microsoft\Windows\CurrentVersion\Explorer\MultiTaskingView\AllUpView" -Force -Recurse | Out-Null
  New-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowTaskViewButton  -PropertyType DWORD -Value 0 -Force | Out-Null

  # hide taskbar people icon
  Write-Host -ForegroundColor YELLOW  "-- Hide people button ..."
  if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
    New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" | Out-Null
  }
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWord -Value 0

  # disable action center
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

  # Hide icons in desktop
  Write-Host -ForegroundColor YELLOW  "-- Hide icons in desktop ..."
  $Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
  Set-ItemProperty -Path $Path -Name "HideIcons" -Value 1

  # Hide recently explorer shortcut
  Write-Host -ForegroundColor YELLOW  "-- Hide recently explorer shortcut ..."
  Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -Type DWord -Value 0

  # Set explorer to open to 'This PC'
  Write-Host -ForegroundColor YELLOW  "-- Set explorer to open to 'This PC' ..."
  New-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name LaunchTo -PropertyType DWORD -Value 1 -Force | Out-Null

  # Set explorers how file extensions
  Write-Host -ForegroundColor YELLOW  "-- Set explorers how file extensions ..."  
  New-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideFileExt -PropertyType DWORD -Value 0 -Force | Out-Null

  # Disable context menu 'Customize this folder'
  Write-Host -ForegroundColor YELLOW  "-- Disable context menu Customize this folder ...."  
  New-Item -ErrorAction SilentlyContinue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Force | Out-Null
  New-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoCustomizeThisFolder -Value 1 -PropertyType DWORD -Force | Out-Null

  # Disable context men 'Restore to previous versions'
  Write-Host -ForegroundColor YELLOW  "-- Disable context 'Restore to previous version'..."  
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -Force -Recurse | Out-Null
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\CLSID\{450D8FBA-AD25-11D0-98A8-0800361B1103}\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -Force -Recurse | Out-Null
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\Directory\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -Force -Recurse | Out-Null
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\Drive\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -Force -Recurse | Out-Null

  # Disable context menu 'Share with'
  Write-Host -ForegroundColor YELLOW  "-- Disable context menu 'Share with' ..."  
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\Directory\Background\shellex\ContextMenuHandlers\Sharing" -Force -Recurse | Out-Null
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\Directory\shellex\ContextMenuHandlers\Sharing" -Force -Recurse | Out-Null
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\Directory\shellex\CopyHookHandlers\Sharing" -Force -Recurse | Out-Null
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\Directory\shellex\PropertySheetHandlers\Sharing" -Force -Recurse | Out-Null
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\Drive\shellex\ContextMenuHandlers\Sharing" -Force -Recurse | Out-Null
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\Drive\shellex\PropertySheetHandlers\Sharing" -Force -Recurse | Out-Null
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\LibraryFolder\background\shellex\ContextMenuHandlers\Sharing" -Force -Recurse | Out-Null
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\UserLibraryFolder\shellex\ContextMenuHandlers\Sharing" -Force -Recurse | Out-Null
  New-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name SharingWizardOn -PropertyType DWORD -Value 0 -Force | Out-Null

  # Disable context menu 'Include in library'
  Write-Host -ForegroundColor YELLOW  "-- Disable context menu 'Include in library' ..."  
  Remove-Item -ErrorAction SilentlyContinue "HKCR:\Folder\ShellEx\ContextMenuHandlers\Library Location" -Force -Recurse | Out-Null
  Remove-Item -ErrorAction SilentlyContinue "HKLM:\SOFTWARE\Classes\Folder\ShellEx\ContextMenuHandlers\Library Location" -Force -Recurse | Out-Null

  # isable context menu 'Send to'
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
  choco upgrade -y --acceptlicense --no-progress
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

    choco feature enable -n allowGlobalConfirmation
    choco feature enable -n allowEmptyChecksumsSecure
    choco feature disable -n showNonElevatedWarnings
    choco feature disable -n showDownloadProgress
    choco feature enable -n removePackageInformationOnUninstall
    choco feature enable -n exitOnRebootDetected
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
  hf_choco_install GoogleChrome vlc 7zip ccleaner FoxitReader
}