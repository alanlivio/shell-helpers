
# ---------------------------------------
# user functions
# ---------------------------------------

function hf_user_reload() {
  Import-Module -Force -Global \Users\alan\gdrive\env\scripts\powershell_helper_functions.ps1
}

function hf_user_profile_init() {
  New-Item $PROFILE -Type File -Force
  Write-Output "Import-Module -Force -Global \Users\alan\gdrive\env\scripts\powershell_helper_functions.ps1" > $PROFILE
  Write-Output "cd ~" >> $PROFILE
}

# ---------------------------------------
# powershell functions
# ---------------------------------------

function hf_powershell_enable_script() {
  Set-ExecutionPolicy unrestricted
}

# ---------------------------------------
# clean functions
# ---------------------------------------

function hf_clean() {
  Write-Output "hf_clean"
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

# ---------------------------------------
# install functions
# ---------------------------------------

function hf_install_vscode_packages() {
  Write-Output "vscode packages"
  $PKGS = ""
  # text edit
  $PKGS += "mkloubert.vscode-remote-workspace henriiik.vscode-sort stkb.rewrap formulahendry.auto-close-tag "
  # docker
  # $PKGS+="peterjausovec.vscode-docker "
  # Copy-Itemp
  $PKGS += "ms-vscode.Copy-Itemptools twxs.cmake matthewferreira.Copy-Itempcheck "
  # python
  $PKGS += "ms-python.python "
  # html-css
  $PKGS += "techer.open-in-browser mkaufman.HTMLHint "
  # xml
  $PKGS += "DotJoshJohnson.xml "
  # javascript
  $PKGS += "dbaeumer.vscode-eslint msjsdiag.debugger-for-chrome "
  # python
  $PKGS += "ms-python.python "
  # typescript
  $PKGS += "eg2.tslint "
  # dart
  $PKGS += "Dart-Code.dart-code "
  # lua
  $PKGS += "trixnz.vscode-lua satoren.lualint "
  # java
  # $PKGS+="redhat.java vscjava.vscode-java-pack "
  $PKGS += "vscjava.vscode-java-pack "
  # markdown
  $PKGS += "mrmlnc.vscode-remark davidanson.vscode-markdownlint "
  # latex
  $PKGS += "James-Yu.latex-workshop "
  # bash
  $PKGS += "timonwong.shellcheck "
  # powershell
  $PKGS += "ms-vscode.powershell "

  hf_vscode_install_packages $PKGS
}

function hf_choco_boostrap() {
  Write-Output "boostrap windows env"
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  Set-Variable "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
  cmd /c 'setx ChocolateyToolsLocation C:\opt\'

  choco -y --acceptlicense --no-progress enable -n allowGlobalConfirmation
  choco -y --acceptlicense --no-progress disable -n showNonElevatedWarnings
  choco -y --acceptlicense --no-progress disable -n showDownloadProgress
  choco -y --acceptlicense --no-progress enable -n removePackageInformationOnUninstall
  choco install -y --acceptlicense --no-progress google-backup-and-sync visualstudiocode
}

function hf_packages_store() {
  Write-Output "packages store remove unused"
  "Microsoft.XboxGameOverlay Microsoft.GetHelp Microsoft.XboxApp Microsoft.Xbox.TCUI Microsoft.XboxSpeechToTextOverlay Microsoft.Wallet Facebook.Facebook 9E2F88E3.Twitter Microsoft.MinecraftUWP A278AB0D.MarchofEmpires Microsoft.Messaging Microsoft.Appconnector Microsoft.BingNews Microsoft.SkypeApp Microsoft.BingSports Microsoft.CommsPhone Microsoft.ConnectivityStore Microsoft.Office.Sway Microsoft.WindowsPhone Microsoft.XboxIdentityProvider Microsoft.StorePurchaseApp Microsoft.DesktopAppInstaller Microsoft.BingWeather Microsoft.MicrosoftStickyNotes Microsoft.MicrosoftSolitaireCollection Microsoft.OneConnect Microsoft.People Microsoft.ZuneMusic Microsoft.ZuneVideo Microsoft.Getstarted Microsoft.XboxApp microsoft.windowscommunicationsapps Microsoft.WindowsCamera Microsoft.WindowsSoundRecorder Microsoft.WindowsMaps Microsoft.3DBuilder Microsoft.WindowsFeedbackHub Microsoft.MicrosoftOfficeHub Microsoft.WindowsAlarms Microsoft.3DBuilder Microsoft.OneDrive 89006A2E.AutodeskSketchBook A278AB0D.DisneyMagicKingdoms king.com.BubbleWitch3Saga king.com.CandyCrushSodaSaga Microsoft.Print3D".Split(" ") | ForEach-Object {Get-AppxPackage -allusers $_ |remove-AppxPackage}
}

function hf_store_list_installed() {
  Get-AppxPackage -AllUsers | Select-Object Name, PackageFullName
}

# ---------------------------------------
# network functions
# ---------------------------------------

function hf_choco_install_packages_essentials() {
  Write-Output "packages choco"
  choco install -y --acceptlicense --no-progress firefox google-backup-and-sync visualstudiocode FoxitReader 7zip vlc ccleaner zotero-standalone libreoffice pdfsam
  choco upgrade -y --acceptlicense --no-progress all
}

function hf_choco_install_packages_dev() {
  Write-Output "packages choco dev"
  choco install -y --acceptlicense --no-progress shellcheck git gitg jdk8 unity-android android-studio android-sdk msys2 shellcheck cmake nsis nodejs rufus dependencywalker
}

function hf_choco_install_packages_user() {
  Write-Output "packages choco user"
  choco install -y --acceptlicense --no-progress battle.net steam deluge stremio
}

# ---------------------------------------
# network functions
# ---------------------------------------

function hf_network_get_wifi_SSIDs() {
  return (netsh wlan show net mode=bssid)
}

# ---------------------------------------
# explorer functions
# ---------------------------------------

function hf_explorer_open_start_menu() {
  explorer '%ProgramData%\Microsoft\Windows\Start Menu\Programs'
}

# ---------------------------------------
# windows functions
# ---------------------------------------

function hf_windows_update() {
  control update
  wuauclt /detectnow /updatenow
}

function hf_windows_remove_ondrive() {
  Write-Output "remove onedrive"
  cmd /c 'IF EXIST "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" REG Delete "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f'
  cmd /c 'IF EXIST "HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" REG Delete "HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f'
  cmd /c 'REG ADD "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v System.IsPinnedToNameSpaceTree /d "0" /t REG_DWORD /f'
}

function hf_windows_disable_unused_menu() {
  Write-Output "remove context menu unused"
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
# config functions
# ---------------------------------------

function hf_config_install() {
  Copy-Item ~/gdrive/env/home/.bashrc ~/
  Copy-Item ~/gdrive/env/home/.vimrc ~/
  Copy-Item ~/gdrive/env/home/.gitconfig ~/
  Copy-Item ~/gdrive/env/home/.profile ~/
  if ( -Not (Test-Path -Path ~/AppData/Roaming/Code/User/ ) ) {
    mkdir -p ~/AppData/Roaming/Code/User/
  }
  Copy-Item ~/gdrive/env/home/.config/Code/User/settings.json ~/AppData/Roaming/Code/User/settings.json
  Copy-Item ~/gdrive/env/home/.config/Code/keybindings.json ~/AppData/Roaming/Code/User/keybindings.json
  Copy-Item ~/gdrive/env/home/.inputrc ~/.inputrc
}

function hf_config_backup() {
  Copy-Item ~/.bashrc ~/gdrive/env/home/
  Copy-Item ~/.vimrc ~/gdrive/env/home/
  Copy-Item ~/.gitconfig ~/gdrive/env/home/
  Copy-Item ~/.profile ~/gdrive/env/home/
  Copy-Item ~/AppData/Roaming/Code/User/settings.json ~/gdrive/env/home/.config/Code/User/settings.json
  Copy-Item ~/AppData/Roaming/Code/User/keybindings.json ~/gdrive/env/home/.config/Code/keybindings.json
  Copy-Item ~/.inputrc ~/gdrive/env/home/.inputrc
}

function hf_config_diff() {
  Compare-Object $(Get-Content ~/.bashrc) $(Get-Content ~/gdrive/env/home/.bashrc)
  Compare-Object $(Get-Content ~/.vimrc) $(Get-Content ~/gdrive/env/home/.vimrc)
  Compare-Object $(Get-Content ~/.gitconfig) $(Get-Content ~/gdrive/env/home/.gitconfig)
  Compare-Object $(Get-Content ~/.profile) $(Get-Content ~/gdrive/env/home/.profile)
  Compare-Object $(Get-Content ~/AppData/Roaming/Code/User/settings.json) $(Get-Content ~/gdrive/env/home/.config/Code/User/settings.json)
  Compare-Object $(Get-Content ~/AppData/Roaming/Code/User/keybindings.json) $(Get-Content ~/gdrive/env/home/.config/Code/keybindings.json)
}