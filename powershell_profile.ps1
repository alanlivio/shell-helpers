# ---------------------------------------
# Powershell helper functions.
# site: github.com/alanlivio/powershell_helper_functions
# ---------------------------------------

# ---------------------------------------
# powershell functions
# ---------------------------------------
function hf_powershell_enable_script(){
  Set-ExecutionPolicy unrestricted
}

function hf_powershell_show_profiles()
{
  $profile | Select-Object -Property *
}

# ---------------------------------------
# install functions
# ---------------------------------------
function hf_install_chocolatey() {
    echo "install chocolatey"
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
    cmd /c 'setx ChocolateyToolsLocation C:\opt\'

    choco -y --acceptlicense --no-progress enable -n allowGlobalConfirmation
    choco -y --acceptlicense --no-progress disable -n showNonElevatedWarnings
    choco -y --acceptlicense --no-progress disable -n showDownloadProgress
    choco -y --acceptlicense --no-progress enable -n removePackageInformationOnUninstall
    choco install -y --acceptlicense --no-progress google-backup-and-sync visualstudiocode
  }

# ---------------------------------------
# info functions
# ---------------------------------------

function hf_get_wifi_SSIDs() {
    return (netsh wlan show net mode=bssid)
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
  Get-AppxPackage -AllUsers | Select Name, PackageFullName
}

# ---------------------------------------
# remove functions
# ---------------------------------------

function hf_remove_unused_folders(){
  echo "remove unused folders"
  Remove-Item -Force -Recurse -ErrorAction Ignore "Favorites/"
  Remove-Item -Force -Recurse -ErrorAction Ignore "OneDrive/"
  Remove-Item -Force -Recurse -ErrorAction Ignore "Pictures/"
  Remove-Item -Force -Recurse -ErrorAction Ignore "Public/"
  Remove-Item -Force -Recurse -ErrorAction Ignore "Templates/"
  Remove-Item -Force -Recurse -ErrorAction Ignore "Videos/"
  Remove-Item -Force -Recurse -ErrorAction Ignore "Music/"
  Remove-Item -Force -Recurse -ErrorAction Ignore "Links/"
  Remove-Item -Force -Recurse -ErrorAction Ignore "Start Menu/"
  Remove-Item -Force -Recurse -ErrorAction Ignore "Saved Games/"
  Remove-Item -Force -Recurse -ErrorAction Ignore "Searches/"
  Remove-Item -Force -Recurse -ErrorAction Ignore "SendTo/"
  Remove-Item -Force -Recurse -ErrorAction Ignore "PrintHood"
  Remove-Item -Force -Recurse -ErrorAction Ignore "MicrosoftEdgeBackups/"
  Remove-Item -Force -Recurse -ErrorAction Ignore "IntelGraphicsProfiles/"
  Remove-Item -Force -Recurse -ErrorAction Ignore "Contacts/"
  Remove-Item -Force -Recurse -ErrorAction Ignore "3D Objects/"
  Remove-Item -Force -Recurse -ErrorAction Ignore "Recent"
  Remove-Item -Force -Recurse -ErrorAction Ignore "NetHood"
  Remove-Item -Force -Recurse -ErrorAction Ignore 'Local Settings'
}



function hf_remove_unused_this_pc_folders() {
  echo "remove this pc folders"
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
  echo "remove onedrive"
  reg delete "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f
  reg delete "HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f
  reg add "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v System.IsPinnedToNameSpaceTree /d "0" /t REG_DWORD /f
}

function hf_remove_unused_store_packages() {
  echo "packages store remove unused"
  "Microsoft.XboxGameOverlay Microsoft.GetHelp Microsoft.XboxApp Microsoft.Xbox.TCUI Microsoft.XboxSpeechToTextOverlay Microsoft.Wallet Facebook.Facebook 9E2F88E3.Twitter Microsoft.MinecraftUWP A278AB0D.MarchofEmpires Microsoft.Messaging Microsoft.Appconnector Microsoft.BingNews Microsoft.SkypeApp Microsoft.BingSports Microsoft.CommsPhone Microsoft.ConnectivityStore Microsoft.Office.Sway Microsoft.WindowsPhone Microsoft.XboxIdentityProvider Microsoft.StorePurchaseApp Microsoft.DesktopAppInstaller Microsoft.BingWeather Microsoft.MicrosoftStickyNotes Microsoft.MicrosoftSolitaireCollection Microsoft.OneConnect Microsoft.People Microsoft.ZuneMusic Microsoft.ZuneVideo Microsoft.Getstarted Microsoft.XboxApp microsoft.windowscommunicationsapps Microsoft.WindowsCamera Microsoft.WindowsSoundRecorder Microsoft.WindowsMaps Microsoft.3DBuilder Microsoft.WindowsFeedbackHub Microsoft.MicrosoftOfficeHub Microsoft.WindowsAlarms Microsoft.3DBuilder Microsoft.OneDrive 89006A2E.AutodeskSketchBook A278AB0D.DisneyMagicKingdoms king.com.BubbleWitch3Saga king.com.CandyCrushSodaSaga Microsoft.Print3D".Split(" ") | Foreach{Get-AppxPackage -allusers $_ |remove-AppxPackage}
}

function hf_remove_context_menu_unused() {
  echo "remove context menu unused"
  # * Sharing
  cmd /c 'IF EXIST "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\ModernSharing" REG Delete "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\ModernSharing" /f'
  cmd /c 'IF EXIST "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\Sharing" REG Delete "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\Sharing" /f'
  cmd /c 'IF EXIST "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\EPP" REG Delete "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\EPP" /f'
  # AllFilesystemObjects
  cmd /c 'IF EXIST "HKEY_CLASSES_ROOT\AllFilesystemObjects\shellex\ContextMenuHandlers\SendTo" REG Delete "HKEY_CLASSES_ROOT\AllFilesystemObjects\shellex\ContextMenuHandlers\SendTo" /f'
  cmd /c 'IF EXIST "HKEY_CLASSES_ROOT\AllFilesystemObjects\shellex\ContextMenuHandlers\CopyAsPathMenu" REG Delete "HKEY_CLASSES_ROOT\AllFilesystemObjects\shellex\ContextMenuHandlers\CopyAsPathMenu" /f'
  # Directory
  cmd /c 'IF EXIST "HKEY_CLASSES_ROOT\Directory\shellex\ContextMenuHandlers\Sharing" REG Delete "HKEY_CLASSES_ROOT\Directory\shellex\ContextMenuHandlers\Sharing" /f'
}

# ---------------------------------------
# update functions
# ---------------------------------------

function hf_windows_update() {
  control update
  wuauclt /detectnow /updatenow
}