<h1 align="center">shell-helpers</h1>

This project offers different helpers functions for both `bash` and `pwsh` to support: configure OS, install software, media convertion, git, etc.

## helpers for configure OS

In particular, there are helpers to support create a minimal developer environment in different OSs:

| cmd shells | graphical shells | terminals | code editors |
| :-: | :-: | :-: | :-: |
| <img width="56" height="56" src="https://upload.wikimedia.org/wikipedia/commons/2/20/Bash_Logo_black_and_white_icon_only.svg"><img width="56" height="56" src="https://upload.wikimedia.org/wikipedia/commons/a/af/PowerShell_Core_6.0_icon.png"> | <img width="56" height="56" src="https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Gnome-start-here.svg/1024px-Gnome-start-here.svg.png"> <img width="56" height="56" src="https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Windows_logo_-_2012.svg/1024px-Windows_logo_-_2012.svg.png"> | <img width="56" height="56" src="https://upload.wikimedia.org/wikipedia/commons/0/01/Windows_Terminal_Logo_256x256.png"> <img width="56" height="56" src="https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/GNOME_Terminal_icon_2019.svg/1024px-GNOME_Terminal_icon_2019.svg.png"> |  <img width="56" height="56" src="https://upload.wikimedia.org/wikipedia/commons/2/2d/Visual_Studio_Code_1.18_icon.svg">

* in linux, the main bash helpers are:
  + `hf_init_gnome`: configure Gnome shell (e.g., disable unused services/features, dark mode) and gnome terminal, install essential software (e.g., googlechrome, VScode, insync).

* In windows, the main powershell helpers are:
  + `hf_init_windows`: configure Windows shell (e.g., disable unused services/features, configure explorer, remove unused appx, dark mode)
  + `hf_init_common_user_software`: install windows software (e.g., googlechrome, vlc, ccleaner, FoxitReader).
  + `hf_init_ubuntu_and_windowsterminal`: install WSL/Ubuntu (version 2, fixed home) and Windowserminal
  + `hf_init_msys`: install msys (Cygwin-based) with bash to build GNU-based win32 applications

* In macOS, the main bash helpers are:
  + `hf_init_mac`: install essential software (brew, bash last version)

## How to install

* To enable helpers in bash (Ubuntu, macOS, or WSL), the shell-helpers can be used as a [Bash Startup File](https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html).
To do that, fetch helpers.sh and insert the following command at the end of your `~/.bashrc` :

  ``` bash
  wget -O ~/.config/helpers.sh https://raw.githubusercontent.com/alanlivio/shell-helpers/master/helpers.sh &&\
  echo "source ~/.config/helpers.sh" >> ~/.bashrc &&\
  source ~/.bashrc
  ```

* To enable helpers in powershell (Windows), the shell-helpers can be used as a [PowerShell Profile](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7).
To do that, fetch helpers.ps1 and import it as powershell module:

  ``` powershell
  Invoke-WebRequest https://raw.githubusercontent.com/alanlivio/shell-helpers/master/helpers.ps1 -OutFile C:\Windows\System32\WindowsPowerShell\v1.0\helpers.ps1;`
  Set-ExecutionPolicy unrestricted -force;`
  Import-Module -Force -Global C:\Windows\System32\WindowsPowerShell\v1.0\helpers.ps1;`
  hf_profile_install
  ```

## References

Other github projects were used as inspiration and reference.

bash references:
* https://github.com/mdo/config
* https://github.com/jenkins-x/dev-env
* https://github.com/jsutcodes/.bashrc_helper
* https://github.com/aspiers/shell-env

powershell references:
* https://github.com/yiskang/PowerShellRc
* https://github.com/matt-beamish/Oh-My-Powershell
* https://gitlab.com/sgur/powershellrc/
* wsl
  + https://github.com/TylerLeonhardt/PSWsl
* optimize services
  + https://gist.github.com/chadr/e17308cad6c472e05de3796599d4e142
  + https://github.com/adolfintel/Windows10-Privacy
  + https://gist.github.com/alirobe/7f3b34ad89a159e6daa1
  + https://github.com/RanzigeButter/fyWin10/blob/master/fyWin10.ps1
* optimize explorer
  + https://github.com/madbomb122/Win10Script/blob/master/Win10-Menu.ps1
  + https://github.com/Sycnex/Windows10Debloater/blob/master/Windows10Debloater.ps1
  + https://github.com/W4RH4WK/Debloat-Windows-10/tree/master/scripts
  + https://github.com/Disassembler0/Win10-Initial-Setup-Script/blob/master/Win10.psm1
