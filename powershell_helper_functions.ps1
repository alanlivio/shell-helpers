# author: Alan Livio <alan@telemidia.puc-rio.br>
# URL:    https://github.com/alanlivio/powershell-helper-functions

# ---------------------------------------
# load powershell_helper_functions_cfg
# ---------------------------------------

$SCRIPT_NAME = "$PSScriptRoot\powershell_helper_functions.ps1"
$SCRIPT_DIR = $PSScriptRoot
$SCRIPT_CFG = "$SCRIPT_DIR\powershell_helper_functions_cfg.ps1"
if (Test-Path $SCRIPT_CFG) {
  Import-Module -Force -Global $SCRIPT_CFG
}

# ---------------------------------------
# alias
# ---------------------------------------
Set-Alias -Name grep -Value Select-String

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

# ---------------------------------------
# system functions
# ---------------------------------------

function hf_system_rename($new_name) {
  Rename-Computer -NewName "$new_name"
}

# https://superuser.com/questions/1246790/can-i-disable-windows-10-animations-with-a-batch-file
function hf_system_adjust_visual_to_performace() {
  New-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name 'VisualFXSetting' -Value 2 -PropertyType DWORD -Force | Out-Null
  New-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name 'EnableTransparency' -Value 0 -PropertyType DWORD -Force | Out-Null
}

function hf_system_disable_unused_features() {
  # https://gist.github.com/thoroc/86d354d029dda303598a

  # XPS Viewer
  Dism /online /Disable-Feature /FeatureName:Xps-Foundation-Xps-Viewer /quiet /norestart
  # XPS Services
  Dism /online /Disable-Feature /FeatureName:Printing-XPSServices-Features /quiet /norestart
  # Internet Explorer
  Dism /online /Disable-Feature /FeatureName:Internet-Explorer-Optional-amd64 /quiet /norestart
  # Work Folders
  Dism /online /Disable-Feature /FeatureName:WorkFolders-Client /quiet /norestart
  # Enabling .NET 3.5 framework because a lot of programs still use it
  Dism /online /Enable-Feature /FeatureName:NetFx3 /quiet /norestart

}
function hf_system_disable_unused_services() {
  # https://gist.github.com/thoroc/86d354d029dda303598a
  schtasks /Change /TN "Microsoft\Windows\Application Experience\ProgramDataUpdater" /Disable | out-null
  schtasks /Change /TN "Microsoft\Windows\AppID\SmartScreenSpecific" /Disable | out-null
  schtasks /Change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable | out-null
  schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable | out-null
  schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /Disable | out-null
  schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Disable | out-null
  schtasks /Change /TN "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /Disable | out-null
  schtasks /Change /TN "Microsoft\Windows\NetTrace\GatherNetworkInfo" /Disable | out-null
  schtasks /Change /TN "Microsoft\Windows\Windows Error Reporting\QueueReporting" /Disable | out-null

  cmd /c sc config DiagTrack start= disabled | out-null
  cmd /c sc config dmwappushservice start= disabled | out-null
  cmd /c sc config diagnosticshub.standardcollector.service start= disabled | out-null
  cmd /c sc config TrkWks start= disabled | out-null
  cmd /c sc config WMPNetworkSvc start= disabled | out-null
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
# explorer functions
# ---------------------------------------


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
  explorer $env:USERPROFILE
}

# ---------------------------------------
# store functions
# ---------------------------------------

function hf_store_list_installed() {
  Write-Host $MyInvocation.MyCommand.ToString() -ForegroundColor YELLOW
  Get-AppxPackage -AllUsers | Select-Object Name, PackageFullName
}

function hf_store_install($name) {
  Write-Host $MyInvocation.MyCommand.ToString() "$name"  -ForegroundColor YELLOW
  Get-AppxPackage -allusers $name | ForEach-Object { Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" }
}
function hf_store_install_essentials() {
  Write-Host $MyInvocation.MyCommand.ToString()  -ForegroundColor YELLOW
  hf_store_install Microsoft.WindowsStore
  hf_store_install Microsoft.WindowsCalculator
  hf_store_install Microsoft.Windows.Photos
}

# ---------------------------------------
# remove functions
# ---------------------------------------

function hf_remove_unused_folders() {
  Write-Host $MyInvocation.MyCommand.ToString() -ForegroundColor YELLOW
  $folders = @("Favorites/", "OneDrive/", "Pictures/", "Public/", "Templates/", "Videos/", "Music/", "Links/", "Saved Games/", "Searches/", "SendTo/", "PrintHood", "MicrosoftEdgeBackups/", "IntelGraphicsProfiles/", "Contacts/", "3D Objects/", "Recent/", "NetHood/",
    "Local Settings/")
  $folders | ForEach-Object { Remove-Item -Force -Recurse -ErrorAction Ignore $_ }
}

function hf_disable_tiles_from_start_menu() {
  Write-Host $MyInvocation.MyCommand.ToString() -ForegroundColor YELLOW
  (New-Object -Com Shell.Application).
  NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').
  Items() |
  ForEach-Object { $_.Verbs() } |
  Where-Object { $_.Name -match 'Un.*pin from Start' } |
  ForEach-Object { $_.DoIt() }
}

function hf_enable_dark_mode() {
  Write-Host $MyInvocation.MyCommand.ToString() -ForegroundColor YELLOW
  reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d 00000000 /f
}

function hf_disable_start_menu_bing() {
  Write-Host $MyInvocation.MyCommand.ToString() -ForegroundColor YELLOW
  reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /d "0" /t REG_DWORD /f
  reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search" /v AllowSearchToUseLocation /d "0" /t REG_DWORD /f
  reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search" /v CortanaConsent /d "0" /t REG_DWORD /f
  reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v ConnectedSearchUseWeb  /d "0" /t REG_DWORD /f
}

function hf_uninstall_ondrive() {
  Write-Host $MyInvocation.MyCommand.ToString() -ForegroundColor YELLOW
  c:\\Windows\\SysWOW64\\OneDriveSetup.exe /uninstall
}

function hf_uninstall_not_essential_store_packages() {
  Write-Host $MyInvocation.MyCommand.ToString() -ForegroundColor YELLOW

  # windows
  $pkgs = 'Microsoft.XboxGameOverlay
  Microsoft.GetHelp
  Microsoft.XboxApp
  Microsoft.Xbox.TCUI
  Microsoft.XboxSpeechToTextOverlay
  Microsoft.Wallet
  Microsoft.MinecraftUWP
  A278AB0D.MarchofEmpires
  king.com.CandyCrushFriends
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
  Microsoft.WindowsCamera
  Microsoft.WindowsSoundRecorder
  Microsoft.WindowsMaps
  Microsoft.3DBuilder
  Microsoft.WindowsFeedbackHub
  Microsoft.MicrosoftOfficeHub
  Microsoft.WindowsAlarms
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
  $pkgs -split '\s+|,\s*' -ne '' | ForEach-Object { Get-AppxPackage -allusers $_ | remove-AppxPackage }

  # others
  $pkgs = 'Facebook.Facebook
  SpotifyAB.SpotifyMusic
  9E2F88E3.Twitter
  A278AB0D.DisneyMagicKingdoms
  king.com.CandyCrushFriends
  king.com.BubbleWitch3Saga
  king.com.CandyCrushSodaSaga
  7EE7776C.LinkedInforWindows
  king.com.CandyCrushSaga
  NORDCURRENT.COOKINGFEVER'
  $pkgs -split '\s+|,\s*' -ne '' | ForEach-Object { Get-AppxPackage -allusers $_ | remove-AppxPackage }
}

function hf_explorer_sanity() {
  # https://gist.github.com/thoroc/86d354d029dda303598a
  Write-Host $MyInvocation.MyCommand.ToString() -ForegroundColor YELLOW

  # Set explorer to open to "This PC"
  New-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name LaunchTo -PropertyType DWORD -Value 1 -Force | Out-Null

  # Show file extensions
  New-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideFileExt -PropertyType DWORD -Value 0 -Force | Out-Null

  # Remove 'Customize this folder' from context menu
  New-Item -ErrorAction SilentlyContinue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Force | Out-Null
  New-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoCustomizeThisFolder -Value 1 -PropertyType DWORD -Force | Out-Null

  # Remove 'Restore to previous versions' from context menu (might be superflous, just in case)
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -Force -Recurse | Out-Null
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\CLSID\{450D8FBA-AD25-11D0-98A8-0800361B1103}\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -Force -Recurse | Out-Null
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\Directory\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -Force -Recurse | Out-Null
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\Drive\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -Force -Recurse | Out-Null

  # Remove 'Share with' from context menu (First 9 might be superflous, just in case)
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\Directory\Background\shellex\ContextMenuHandlers\Sharing" -Force -Recurse | Out-Null
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\Directory\shellex\ContextMenuHandlers\Sharing" -Force -Recurse | Out-Null
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\Directory\shellex\CopyHookHandlers\Sharing" -Force -Recurse | Out-Null
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\Directory\shellex\PropertySheetHandlers\Sharing" -Force -Recurse | Out-Null
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\Drive\shellex\ContextMenuHandlers\Sharing" -Force -Recurse | Out-Null
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\Drive\shellex\PropertySheetHandlers\Sharing" -Force -Recurse | Out-Null
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\LibraryFolder\background\shellex\ContextMenuHandlers\Sharing" -Force -Recurse | Out-Null
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\UserLibraryFolder\shellex\ContextMenuHandlers\Sharing" -Force -Recurse | Out-Null
  New-ItemProperty -ErrorAction SilentlyContinue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name SharingWizardOn -PropertyType DWORD -Value 0 -Force | Out-Null

  # Remove 'Include in library' from context menu (might be superflous, just in case)
  Remove-Item -ErrorAction SilentlyContinue "HKCR:\Folder\ShellEx\ContextMenuHandlers\Library Location" -Force -Recurse | Out-Null
  Remove-Item -ErrorAction SilentlyContinue "HKLM:\SOFTWARE\Classes\Folder\ShellEx\ContextMenuHandlers\Library Location" -Force -Recurse | Out-Null

  # Remove 'Send to' from context menu (might be superflous, just in case)
  Remove-Item -ErrorAction SilentlyContinue -Path "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\SendTo" -Force -Recurse | Out-Null

}

# ---------------------------------------
# permissions functions
# ---------------------------------------

function hf_adminstrator_user_enable() {
  Write-Host $MyInvocation.MyCommand.ToString() -ForegroundColor YELLOW
  net user administrator /active:yes
}

function hf_adminstrator_user_disable() {
  Write-Host $MyInvocation.MyCommand.ToString() -ForegroundColor YELLOW
  net user administrator /active:no
}

# ---------------------------------------
# update functions
# ---------------------------------------

function hf_windows_update() {
  Write-Host $MyInvocation.MyCommand.ToString() -ForegroundColor YELLOW
  control update
  wuauclt /detectnow /updatenow
}

# ---------------------------------------
# choco function
# ---------------------------------------

function hf_choco_cleaner() {
  \ProgramData\chocolatey\bin\Choco-Cleaner.ps1
}

function hf_choco_install() {
  choco install -y --acceptlicense --no-progress "$args"
}

function hf_choco_uninstall() {
  choco uninstall -y --acceptlicense --no-progress "$args"
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

function hf_wsl_fix_home_folder() {
  wsl -u root sudo usermod -d /mnt/c/Users/$env:UserName $env:UserName
}

# ---------------------------------------
# init function
# ---------------------------------------

function hf_windows_sanity() {
  Write-Host $MyInvocation.MyCommand.ToString() -ForegroundColor YELLOW
  hf_system_adjust_visual_to_performace
  hf_explorer_sanity
  hf_system_disable_unused_services
  hf_system_disable_unused_features
  hf_disable_tiles_from_start_menu
  hf_uninstall_not_essential_store_packages
  hf_uninstall_ondrive
  hf_disable_start_menu_bing
  hf_remove_unused_folders
}

function hf_install_chocolatey() {
  Write-Host $MyInvocation.MyCommand.ToString() -ForegroundColor YELLOW
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  Set-Variable "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
  cmd /c 'setx ChocolateyToolsLocation C:\opt\'

  hf_choco enable -n allowGlobalConfirmation
  hf_choco disable -n showNonElevatedWarnings
  hf_choco disable -n showDownloadProgress
  hf_choco enable -n removePackageInformationOnUninstall
  choco -y --acceptlicense feature enable -name=exitOnRebootDetected
}

function hf_install_msys() {
  Write-Host $MyInvocation.MyCommand.ToString() -ForegroundColor YELLOW
  hf_choco_install msys2
}

function hf_install_tesseract() {
  hf_choco_install tesseract --pre
}

function hf_install_chrome() {
  hf_choco_install "GoogleChrome"
}

function hf_install_firefox() {
  hf_choco_install "firefox"
}

function hf_install_vscode() {
  hf_choco_install "vscode"
}

function hf_install_gdrive() {
  hf_choco_install "google-backup-and-sync"
}

function hf_install_ccleaner() {
  hf_choco_install "ccleaner"
}

function hf_install_vlc() {
  hf_choco_install "vlc"
}

function hf_install_windows_terminal() {
  hf_choco_install "microsoft-windows-terminal"
}

function hf_install_gsudo() {
  hf_choco_install "gsudo"
}

function hf_install_shellcheck() {
  hf_choco_install "shellcheck"
}

function hf_install_7zip() {
  hf_choco_install "7zip"
}

function hf_install_driverbooster() {
  hf_choco_install "driverbooster"
}

function hf_install_gamer() {
  hf_choco_install "battle.net steam deluge stremio"
}

function hf_wt_install_settings($path) {
  Copy-Item $path C:\Users\alan\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\profiles.json
}

function hf_install_wsl() {
  # https://docs.microsoft.com/en-us/windows/wsl/wsl2-install
  dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
  dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

  # https://docs.microsoft.com/en-us/windows/wsl/install-manual
  $VERSION = 1804
  Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-$VERSION -OutFile $env:TEMP\Ubuntu.appx -UseBasicParsing
  Add-AppxPackage $env:TEMP\Ubuntu.appx
  Ubuntu$VERSION.exe
}

function hf_windows_init_normal_user() {
  Write-Host $MyInvocation.MyCommand.ToString() -ForegroundColor YELLOW
  hf_windows_sanity
  hf_install_chocolatey
  hf_install_chrome
  hf_install_vlc
  hf_install_7zip
  hf_install_ccleaner
  hf_install_driverbooster
}

function hf_windows_init_bash_user() {
  Write-Host $MyInvocation.MyCommand.ToString() -ForegroundColor YELLOW
  hf_windows_sanity
  hf_install_chocolatey
  hf_install_firefox
  hf_install_gsudo
  hf_install_wsl
  hf_install_windows_terminal
  hf_wsl_fix_home_folder
}
