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
function hf_install_choco() {
    echo "boostrap windows env"
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

function hf_remove(_unused_folders){
  echo "hf_remove"
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


function hf_remove_unused_ondrive() {
  echo "remove onedrive"
  cmd /c 'IF EXIST "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" REG Delete "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f'
  cmd /c 'IF EXIST "HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" REG Delete "HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f'
  cmd /c 'REG ADD "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v System.IsPinnedToNameSpaceTree /d "0" /t REG_DWORD /f'
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