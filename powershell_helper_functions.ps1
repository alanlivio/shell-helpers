
function hf_powershell_profile(){
  New-Item $PROFILE -Type File -Force
  echo "Import-Module -Force -Global \Users\alan\gdrive\env\scripts\powershell_helper_functions.ps1" > $PROFILE
  echo "cd ~" >> $PROFILE
}

function hf_powershell_enable_script(){
  Set-ExecutionPolicy unrestricted
}

function hf_reload(){
  Import-Module -Force -Global \Users\alan\gdrive\env\scripts\powershell_helper_functions.ps1
}

function hf_clean(){
    echo "hf_clean"
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


function hf_choco_boostrap() {
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

function hf_packages_store() {
  echo "packages store remove unused"
  "Microsoft.XboxGameOverlay Microsoft.GetHelp Microsoft.XboxApp Microsoft.Xbox.TCUI Microsoft.XboxSpeechToTextOverlay Microsoft.Wallet Facebook.Facebook 9E2F88E3.Twitter Microsoft.MinecraftUWP A278AB0D.MarchofEmpires Microsoft.Messaging Microsoft.Appconnector Microsoft.BingNews Microsoft.SkypeApp Microsoft.BingSports Microsoft.CommsPhone Microsoft.ConnectivityStore Microsoft.Office.Sway Microsoft.WindowsPhone Microsoft.XboxIdentityProvider Microsoft.StorePurchaseApp Microsoft.DesktopAppInstaller Microsoft.BingWeather Microsoft.MicrosoftStickyNotes Microsoft.MicrosoftSolitaireCollection Microsoft.OneConnect Microsoft.People Microsoft.ZuneMusic Microsoft.ZuneVideo Microsoft.Getstarted Microsoft.XboxApp microsoft.windowscommunicationsapps Microsoft.WindowsCamera Microsoft.WindowsSoundRecorder Microsoft.WindowsMaps Microsoft.3DBuilder Microsoft.WindowsFeedbackHub Microsoft.MicrosoftOfficeHub Microsoft.WindowsAlarms Microsoft.3DBuilder Microsoft.OneDrive 89006A2E.AutodeskSketchBook A278AB0D.DisneyMagicKingdoms king.com.BubbleWitch3Saga king.com.CandyCrushSodaSaga Microsoft.Print3D".Split(" ") | Foreach{Get-AppxPackage -allusers $_ |remove-AppxPackage}
}

function hf_get_wifi_SSIDs() {
    return (netsh wlan show net mode=bssid)
}

function hf_open_start-menu() {
  explorer '%ProgramData%\Microsoft\Windows\Start Menu\Programs'
}

function hf_store_list_installed() {
  Get-AppxPackage -AllUsers | Select Name, PackageFullName
}

function hf_remove_ondrive() {
  echo "remove onedrive"
  cmd /c 'IF EXIST "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" REG Delete "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f'
  cmd /c 'IF EXIST "HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" REG Delete "HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f'
  cmd /c 'REG ADD "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v System.IsPinnedToNameSpaceTree /d "0" /t REG_DWORD /f'
}

function hf_context_menu_unused() {
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

function hf_packages_choco() {
  echo "packages choco"
  choco install -y --acceptlicense --no-progress firefox google-backup-and-sync visualstudiocode FoxitReader 7zip vlc ccleaner shellcheck git zotero-standalone libreoffice pdfsam
  choco upgrade -y --acceptlicense --no-progress all
}

function hf_packages_choco_dev() {
  echo "packages choco dev"
  choco install -y --acceptlicense --no-progress msys2 cppcheck cmake nsis nodejs rufus git gitg dependencywalker
}

function hf_packages_choco_user() {
  echo "packages choco user"
  choco install -y --acceptlicense --no-progress battle.net steam deluge stremio
}

function hf_update() {
  control update
  wuauclt /detectnow /updatenow
}

function hf_config_install() {
  cp ~/gdrive/env/home/.bashrc ~/
  cp ~/gdrive/env/home/.vimrc ~/
  cp ~/gdrive/env/home/.gitconfig ~/
  cp ~/gdrive/env/home/.profile ~/
  if( -Not (Test-Path -Path ~/AppData/Roaming/Code/User/ ) ){
    mkdir -p ~/AppData/Roaming/Code/User/
  }
  cp ~/gdrive/env/home/.config/Code/User/settings.json ~/AppData/Roaming/Code/User/settings.json
  cp ~/gdrive/env/home/.config/Code/keybindings.json ~/AppData/Roaming/Code/User/keybindings.json
  cp ~/gdrive/env/home/.inputrc ~/.inputrc
}

function hf_config_backup() {
  cp ~/.bashrc ~/gdrive/env/home/
  cp ~/.vimrc ~/gdrive/env/home/
  cp ~/.gitconfig ~/gdrive/env/home/
  cp ~/.profile ~/gdrive/env/home/
  cp ~/AppData/Roaming/Code/User/settings.json \
    ~/gdrive/env/home/.config/Code/User/settings.json
  cp ~/AppData/Roaming/Code/User/keybindings.json \
    ~/gdrive/env/home/.config/Code/keybindings.json
  cp ~/.inputrc ~/gdrive/env/home/.inputrc
}

function hf_config_diff() {
  Compare-Object $(Get-Content ~/.bashrc) $(Get-Content ~/gdrive/env/home/.bashrc)
  Compare-Object $(Get-Content ~/.vimrc) $(Get-Content ~/gdrive/env/home/.vimrc)
  Compare-Object $(Get-Content ~/.gitconfig) $(Get-Content ~/gdrive/env/home/.gitconfig)
  Compare-Object $(Get-Content ~/.profile) $(Get-Content ~/gdrive/env/home/.profile)
  Compare-Object $(Get-Content ~/AppData/Roaming/Code/User/settings.json) $(Get-Content ~/gdrive/env/home/.config/Code/User/settings.json)
  Compare-Object $(Get-Content ~/AppData/Roaming/Code/User/keybindings.json) $(Get-Content ~/gdrive/env/home/.config/Code/keybindings.json)
}