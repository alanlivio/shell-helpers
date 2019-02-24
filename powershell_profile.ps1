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
# profile functions
# ---------------------------------------

function hf_profile_install(){
  Write-Output "Import-Module -Force -Global $SCRIPT_NAME" > C:\Windows\System32\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
}

function hf_profile_reload(){
  Import-Module -Force -Global $SCRIPT_NAME
}

# ---------------------------------------
# go home
# ---------------------------------------
Set-Location ~

# ---------------------------------------
# powershell functions
# ---------------------------------------
function hf_powershell_enable_scripts(){
  Set-ExecutionPolicy unrestricted
}

function hf_powershell_profiles_list()
{
  $profile | Select-Object -Property *
}

function hf_powershell_profiles_reset(){
  $profile.AllUsersAllHosts="\Windows\System32\WindowsPowerShell\v1.0\profile.ps1"
  $profile.AllUsersCurrentHost="\Windows\System32\WindowsPowerShell\v1.0\Microsoft.PowerShell_profile.ps1"
  $profile.CurrentUserAllHosts="WindowsPowerShell\profile.ps1"
  $profile.CurrentUserCurrentHost="WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
}

# ---------------------------------------
# install functions
# ---------------------------------------
function hf_install_chocolatey() {
  Write-Output "install chocolatey"
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  Set-Variable "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
  cmd /c 'setx ChocolateyToolsLocation C:\opt\'

  choco -y --acceptlicense --no-progress enable -n allowGlobalConfirmation
  choco -y --acceptlicense --no-progress disable -n showNonElevatedWarnings
  choco -y --acceptlicense --no-progress disable -n showDownloadProgress
  choco -y --acceptlicense --no-progress enable -n removePackageInformationOnUninstall
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
  Get-AppxPackage -AllUsers | Select-Object Name, PackageFullName
}

# ---------------------------------------
# remove functions
# ---------------------------------------

function hf_remove_unused_folders(){
  Write-Output "remove unused folders"
  $folders = @("Favorites/", "OneDrive/", "Pictures/", "Public/", "Templates/", "Videos/", "Music/", "Links/", "Saved Games/", "Searches/", "SendTo/", "PrintHood", "MicrosoftEdgeBackups/", "IntelGraphicsProfiles/", "Contacts/", "3D Objects/", "Recent/", "NetHood/",
  "Local Settings/")
  $folders | ForEach-Object {Remove-Item -Force -Recurse -ErrorAction Ignore $_}
}

function hf_remove_tiles_from_start_menu(){
(New-Object -Com Shell.Application).
    NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').
    Items() |
  %{ $_.Verbs() } |
  ?{$_.Name -match 'Un.*pin from Start'} |
  %{$_.DoIt()}
}

function hf_enable_dark_mode() {
  Write-Output "enable dark mode"
  reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d 00000000 /f
}

function hf_remove_unused_this_pc_folders() {
  Write-Output "remove this pc folders"
  reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" /f
  reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" /f
  reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" /f
  reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" /f
  reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" /f
  reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" /f
  reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" /f
  reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" /f
  reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" /f
  reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" /f
  reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" /f
  reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" /f
  reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" /f
  reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /f
  reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" /f
  reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /f
  reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" /f
  reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" /f
  reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" /f
  reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" /f
  reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" /f
  reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /f
  reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" /f
  reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /f
}

function hf_remove_unused_ondrive() {
  Write-Output "remove onedrive"
  reg delete "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f
  reg delete "HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f
  reg add "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v System.IsPinnedToNameSpaceTree /d "0" /t REG_DWORD /f
}

function hf_remove_unused_store_packages() {
  Write-Output "packages store remove unused"
  "Microsoft.XboxGameOverlay Microsoft.GetHelp Microsoft.XboxApp Microsoft.Xbox.TCUI Microsoft.XboxSpeechToTextOverlay Microsoft.Wallet Facebook.Facebook 9E2F88E3.Twitter Microsoft.MinecraftUWP A278AB0D.MarchofEmpires Microsoft.Messaging Microsoft.Appconnector Microsoft.BingNews Microsoft.SkypeApp Microsoft.BingSports Microsoft.CommsPhone Microsoft.ConnectivityStore Microsoft.Office.Sway Microsoft.WindowsPhone Microsoft.XboxIdentityProvider Microsoft.StorePurchaseApp Microsoft.DesktopAppInstaller Microsoft.BingWeather Microsoft.MicrosoftStickyNotes Microsoft.MicrosoftSolitaireCollection Microsoft.OneConnect Microsoft.People Microsoft.ZuneMusic Microsoft.ZuneVideo Microsoft.Getstarted Microsoft.XboxApp microsoft.windowscommunicationsapps Microsoft.WindowsCamera Microsoft.WindowsSoundRecorder Microsoft.WindowsMaps Microsoft.3DBuilder Microsoft.WindowsFeedbackHub Microsoft.MicrosoftOfficeHub Microsoft.WindowsAlarms Microsoft.3DBuilder Microsoft.OneDrive 89006A2E.AutodeskSketchBook A278AB0D.DisneyMagicKingdoms king.com.BubbleWitch3Saga king.com.CandyCrushSodaSaga Microsoft.Print3D Microsoft.Office.OneNote Microsoft.Microsoft3DViewer Microsoft.XboxGamingOverlay Microsoft.MSPaint".Split(" ") | ForEach-Object{Get-AppxPackage -allusers $_ |remove-AppxPackage}
}

function hf_remove_context_menu_unused() {
  Write-Output "remove context menu unused"
  # * Sharing
  cmd /c 'IF EXIST "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\ModernSharing" reg delete "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\ModernSharing" /f'
  cmd /c 'IF EXIST "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\Sharing" reg delete "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\Sharing" /f'
  cmd /c 'IF EXIST "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\EPP" reg delete "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\EPP" /f'
  # AllFilesystemObjects
  cmd /c 'IF EXIST "HKEY_CLASSES_ROOT\AllFilesystemObjects\shellex\ContextMenuHandlers\SendTo" reg delete "HKEY_CLASSES_ROOT\AllFilesystemObjects\shellex\ContextMenuHandlers\SendTo" /f'
  cmd /c 'IF EXIST "HKEY_CLASSES_ROOT\AllFilesystemObjects\shellex\ContextMenuHandlers\CopyAsPathMenu" reg delete "HKEY_CLASSES_ROOT\AllFilesystemObjects\shellex\ContextMenuHandlers\CopyAsPathMenu" /f'
  # Directory
  cmd /c 'IF EXIST "HKEY_CLASSES_ROOT\Directory\shellex\ContextMenuHandlers\Sharing" reg delete "HKEY_CLASSES_ROOT\Directory\shellex\ContextMenuHandlers\Sharing" /f'
}

# ---------------------------------------
# update functions
# ---------------------------------------

function hf_windows_update() {
  control update
  wuauclt /detectnow /updatenow
}

# ---------------------------------------
# windows function
# ---------------------------------------
function hf_windows_sanity() {
  hf_remove_unused_folders
  hf_remove_unused_this_pc_folders
  hf_remove_all_from_start_menu
  hf_remove_unused_ondrive
  hf_remove_unused_store_packages
  hf_remove_context_menu_unused
}
function hf_windows_init() {
  hf_windows_sanity
  hf_install_chocolatey
  choco install -y --acceptlicense --no-progress GoogleChrome vscode spotify google-backup-and-sync msys2
}