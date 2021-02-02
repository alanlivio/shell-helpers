<h1 align="center">shell-helpers</h1>

This project offers different helper functions for both `bash` and `pwsh` to support: configure OS, install software, media convertion, git, etc.

## helpers for Gnome-based Ubuntu

* `hf_init_ubuntu_gnome`: configure Gnome Shell (e.g., disable unused services/features, dark mode) and install essential software (e.g., git, curl, python, pip, vscode).
* `hf_update_clean`: configure/upgrade packges using variables (PKGS_APT, PKGS_PYTHON, PKGS_SNAP, PKGS_SNAP_CLASSIC, PKGS_REMOVE_APT) in .bashrc or helpers-cfg.sh, and cleanup.

## helpers for macOS

* `hf_init_mac`: install essential software (brew, bash last version, python, pip, vscode)
* `hf_update_clean`: configure/upgrade packges using variables (PKGS_BREW) in .bashrc or helpers-cfg.sh, and cleanup.

## helpers for Windows

In Windows Powershell:

* `hf_init_windows`: configure Windows shell (e.g., disable unused services/features, configure explorer, remove unused appx, dark mode) and essential suftware (e.g., choco, vscode).
* `hf_install_common_user_software`: install common user software (i.e., googlechrome, vlc, 7zip, ccleaner, FoxitReader, google-backup-and-sync).
* `hf_install_wsl_ubuntu_and_windowsterminal`: install WSL/Ubuntu (version 2, fixed home) and Windowserminal. It requires system restart then run it again.
* `hf_install_msys`: install msys (Cygwin-based) with bash to build GNU-based win32 applications
* `hf_install_battle_steam`: install Battle.net and Steam

In wsl bash:

* `hf_init_wsl`: install essential software (e.g., git, curl, python, pip).
* `hf_update_clean`: configure/upgrade packges using variables (PKGS_APT, PKGS_PYTHON, PKGS_REMOVE_APT) in .bashrc or helpers-cfg.sh, and cleanup.

In msys bash:

* `hf_init_msys`: install essential software (e.g., git, curl, python, pip).
* `hf_update_clean`: configure/upgrade packges using variables (PKGS_MSYS) in .bashrc or helpers-cfg.sh, and cleanup.

### Recommended  Windows/WSL steps

1. In admin powershell, run:  
  1.1) `hf_init_windows`  
  1.2) `hf_install_common_user_software`  
  1.3) `hf_install_wsl_ubuntu_and_windowsterminal` (it requeres restart and, when done, run it again)  
2. Run the Ubuntu app and configure your user name/password.  
3. In Ubuntu in WindowsTerminal, run:  
  3.1) `hf_init_wsl`  
  3.2) Configure variables at .bashrc or helpers-cfg.sh (PKGS_APT, PKGS_PYTHON, PKGS_REMOVE_APT)  
  3.3) `hf_update_clean` (usually run to mainten the system updated)

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
