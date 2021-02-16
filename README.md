<h1 align="center">shell-helpers</h1>

This project offers different helper functions for both `bash` and `powershell` to support: configure OS, install software, git, utilities, etc.

# How to install

To enable helpers in bash (Ubuntu, macOS, or WSL), the shell-helpers can be used as a [Bash Startup File](https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html). To do that, run the followings commands for fetch helpers.sh and load at `~/.bashrc` :

``` bash
  mkdir ~/.helpers/
  wget -O ~/.helpers/helpers.sh https://raw.githubusercontent.com/alanlivio/shell-helpers/master/helpers.sh &&\
  echo "source ~/.helpers/helpers.sh" >> ~/.bashrc &&\
  source ~/.bashrc
  ```

To enable helpers in powershell (Windows), the shell-helpers can be used as a [PowerShell Profile](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7). To do that, run the followings commands for fetch helpers.ps1 and import it as powershell module:

``` powershell
  mkdir ~/.helpers/;`
  Invoke-WebRequest -O ~/.helpers/helpers.ps1 https://raw.githubusercontent.com/alanlivio/shell-helpers/master/helpers.ps1;`
  Set-ExecutionPolicy unrestricted -force;`
  Write-Output "Import-Module -Force -Global ~/.helpers/helpers.ps1" > $Profile.AllUsersAllHosts
  ```

# Usage

## init Gnome-based Ubuntu

1. bash `hf_init_gnome`: configure Gnome Shell (e.g., disable unused services/features, dark mode) and install essential software (e.g., git, curl, python, pip, vscode).
2. bash `hf_update_clean` (run routinely): configure/upgrade packges using variables (PKGS_APT, PKGS_PYTHON, PKGS_SNAP, PKGS_SNAP_CLASSIC, PKGS_REMOVE_APT) in ~/.bashrc or ~/.helpers-cfg.sh, and cleanup.

## init macOS

1. bash `hf_init_mac`: install essential software (brew, bash last version, python, pip, vscode)
2. bash `hf_update_clean` (run routinely): configure/upgrade packges using variables (PKGS_BREW) in ~/.bashrc or ~/.helpers-cfg.sh, and cleanup.

## init Windows for common users

1. powershell `hf_init_common_user`: install common user software (i.e., googlechrome, vlc, 7zip, ccleaner, FoxitReader, google-backup-and-sync).
2. powershell `hf_install_battle_steam`(optional for gamers): install Battle.net and Steam

## init Windows

1. powershell `hf_init_windows`: configure Windows shell (e.g., disable unused services/features, configure explorer, remove unused appx, dark mode) and install essential software (e.g., choco, msys2 bash vscode).

## init WSL in Windows

1. powershell `hf_install_wsl_ubuntu_and_windowsterminal`: install WSL/Ubuntu (version 2, fixed home) and Windowserminal. This helper automate the process describred in [Microsoft WSL Tutorial](https://docs.microsoft.com/en-us/windows/wsl/wsl2-install)  
  1.1. After run, it requeres restart windows and run it again.  
  1.2. It aso require run Ubuntu app and configure your username/password.  
  1.1. Then run it again.
2. wsl bash `hf_init_wsl`: install essential software (e.g., git, curl, python, pip).
3. wsl bash `hf_update_clean` (run routinely): configure/upgrade packges using variables (PKGS_APT, PKGS_PYTHON, PKGS_REMOVE_APT) in ~/.bashrc or ~/.helpers-cfg.sh, and cleanup.

## init msys in Windows

1. powershell `hf_install_msys`: install msys (Cygwin-based) with bash to build GNU-based win32 applications
2. msys bash `hf_init_msys`: install essential software (e.g., git, curl, python, pip).
3. msys bash `hf_update_clean` (run routinely): configure/upgrade packges using variables (PKGS_MSYS) in ~/.bashrc or ~/.helpers-cfg.sh, and cleanup.

## Other helpers

There are other herpers related with install software (hf_install_\*), git (hf_git_\*), pdf manipulation (hf_pdf_\*), files compression (hf_compress_\*), etc. To see them, take a look at [helpers.ps1](helpers.ps1) and [helpers.sh](helpers.sh).

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
