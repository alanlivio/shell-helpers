# ---------------------------------------
# powershell_profile helper functions.
# site: github.com/alanlivio/powershell_profile
# ---------------------------------------

# ---------------------------------------
# load powershell_profile_cfg
# ---------------------------------------

$SCRIPT_NAME = "$PSScriptRoot\powershell_profile.ps1"
$SCRIPT_DIR = $PSScriptRoot
$SCRIPT_CFG = "$SCRIPT_DIR\powershell_profile_cfg.ps1"
if (Test-Path $SCRIPT_CFG) {
  Import-Module -Force -Global $SCRIPT_CFG
}
# ---------------------------------------
# go home
# ---------------------------------------
Set-Location ~

# ---------------------------------------
# profile functions
# ---------------------------------------

function hf_profile_install() {
  Write-Output "Import-Module -Force -Global $SCRIPT_NAME" > C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1
}

function hf_profile_reload() {
  Import-Module -Force -Global $SCRIPT_NAME
}

# ---------------------------------------
# powershell functions
# ---------------------------------------
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
# network functions
# ---------------------------------------

function hf_network_list_wifi_SSIDs() {
  return (netsh wlan show net mode=bssid)
}

# ---------------------------------------
# network functions
# ---------------------------------------

function hf_link_create($desntination, $source) {
  cmd /c mklink /D $desntination $source
}

# ---------------------------------------
# explorer functions
# ---------------------------------------

function hf_explorer_open_start_menu() {
  explorer '%ProgramData%\Microsoft\Windows\Start Menu\Programs'
}

# ---------------------------------------
# store functions
# ---------------------------------------

function hf_store_list_installed() {
  Write-Host $MyInvocation.MyCommand.ToString() -ForegroundColor YELLOW
  Get-AppxPackage -AllUsers | Select-Object Name, PackageFullName
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

function hf_disable_this_pc_folders() {
  Write-Host $MyInvocation.MyCommand.ToString() -ForegroundColor YELLOW
  $folders = @(
    "{088e3905-0323-4b02-9826-5d99428e115f}",
    "{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}",
    "{1CF1260C-4DD0-4ebb-811F-33C572699FDE}",
    "{24ad3ad4-a569-4530-98e1-ab02f9417aa8}",
    "{374DE290-123F-4565-9164-39C4925E467B}",
    "{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}",
    "{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}",
    "{A0953C92-50DC-43bf-BE83-3742FED03C9C}",
    "{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}",
    "{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}",
    "{d3162b92-9365-467a-956b-92703aca08af}",
    "{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}")
  $path1 = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\"
  $path2 = "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\"
  $folders | ForEach-Object { if ( Test-Path $path1$_) { reg delete $path1$_ /f } }
  $folders | ForEach-Object { if (Test-Path $path2$_) { reg delete $path2$_ /f }
  }
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
  reg delete "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f
  reg delete "HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f
  reg add "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v System.IsPinnedToNameSpaceTree /d "0" /t REG_DWORD /f
}

function hf_uninstall_not_essential_store_packages() {
  Write-Host $MyInvocation.MyCommand.ToString() -ForegroundColor YELLOW
  $pkgs = 'Microsoft.XboxGameOverlay
  Microsoft.GetHelp
  Microsoft.XboxApp
  Microsoft.Xbox.TCUI
  Microsoft.XboxSpeechToTextOverlay
  Microsoft.Wallet
  Microsoft.MinecraftUWP
  A278AB0D.MarchofEmpires
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
  Write-Output "packages store remove unused from others"
  "Facebook.Facebook SpotifyAB.SpotifyMusic 9E2F88E3.Twitter A278AB0D.DisneyMagicKingdoms king.com.CandyCrushFriends king.com.BubbleWitch3Saga king.com.CandyCrushSodaSaga 7EE7776C.LinkedInforWindows king.com.CandyCrushSaga NORDCURRENT.COOKINGFEVER".Split(" ") | ForEach-Object { Get-AppxPackage -allusers $_ | remove-AppxPackage }
}

function hf_disable_not_essential_context_menu() {
  Write-Host $MyInvocation.MyCommand.ToString() -ForegroundColor YELLOW
  # * Sharing
  if (Test-Path "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\ModernSharing") { reg delete "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\ModernSharing" /f }
  if (Test-Path "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\Sharing") { reg delete "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\Sharing" /f }
  if (Test-Path "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\EPP") { reg delete "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\EPP" /f }
  # AllFilesystemObjects
  if (Test-Path "HKEY_CLASSES_ROOT\AllFilesystemObjects\shellex\ContextMenuHandlers\SendTo") { reg delete "HKEY_CLASSES_ROOT\AllFilesystemObjects\shellex\ContextMenuHandlers\SendTo" /f }
  if (Test-Path "HKEY_CLASSES_ROOT\AllFilesystemObjects\shellex\ContextMenuHandlers\CopyAsPathMenu") { reg delete "HKEY_CLASSES_ROOT\AllFilesystemObjects\shellex\ContextMenuHandlers\CopyAsPathMenu" /f }
  # Directory
  if (Test-Path "HKEY_CLASSES_ROOT\Directory\shellex\ContextMenuHandlers\Sharing") { reg delete "HKEY_CLASSES_ROOT\Directory\shellex\ContextMenuHandlers\Sharing" /f }
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
# init function
# ---------------------------------------

function hf_windows_sanity() {
  Write-Host $MyInvocation.MyCommand.ToString() -ForegroundColor YELLOW
  hf_remove_unused_folders
  hf_disable_start_menu_bing
  hf_disable_this_pc_folders
  hf_disable_tiles_from_start_menu
  hf_disable_not_essential_context_menu
  hf_uninstall_not_essential_store_packages
  hf_uninstall_ondrive
}

function hf_install_chocolatey() {
  Write-Host $MyInvocation.MyCommand.ToString() -ForegroundColor YELLOW
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  Set-Variable "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
  cmd /c 'setx ChocolateyToolsLocation C:\opt\'

  choco -y --acceptlicense --no-progress enable -n allowGlobalConfirmation
  choco -y --acceptlicense --no-progress disable -n showNonElevatedWarnings
  choco -y --acceptlicense --no-progress disable -n showDownloadProgress
  choco -y --acceptlicense --no-progress enable -n removePackageInformationOnUninstall
  choco -y --acceptlicense feature enable -name=exitOnRebootDetected
}

function hf_install_bash() {
  Write-Host $MyInvocation.MyCommand.ToString() -ForegroundColor YELLOW
  choco install -y --acceptlicense --no-progress msys2
}

function hf_windows_init() {
  Write-Host $MyInvocation.MyCommand.ToString() -ForegroundColor YELLOW
  hf_windows_sanity
  hf_install_chocolatey
  hf_install_bash
}