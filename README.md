<h1 align="center">shell-helpers</h1>

This project offers different helpers functions for both `bash` and `pwsh` .
In particular, it supports creating a minimal developer environment in different operating systems by configure:

| cmd shells | graphical shells | terminals | code editors |
| :-: | :-: | :-: | :-: |
| <img width="56" height="56" src="https://upload.wikimedia.org/wikipedia/commons/2/20/Bash_Logo_black_and_white_icon_only.svg"><img width="56" height="56" src="https://upload.wikimedia.org/wikipedia/commons/a/af/PowerShell_Core_6.0_icon.png"> | <img width="56" height="56" src="https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Gnome-start-here.svg/1024px-Gnome-start-here.svg.png"> <img width="56" height="56" src="https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Windows_logo_-_2012.svg/1024px-Windows_logo_-_2012.svg.png"> | <img width="56" height="56" src="https://upload.wikimedia.org/wikipedia/commons/0/01/Windows_Terminal_Logo_256x256.png"> <img width="56" height="56" src="https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/GNOME_Terminal_icon_2019.svg/1024px-GNOME_Terminal_icon_2019.svg.png"> |  <img width="56" height="56" src="https://upload.wikimedia.org/wikipedia/commons/2/2d/Visual_Studio_Code_1.18_icon.svg">

In particular, there are helper functions for:

* in Ubuntu
  + install essential software (e.g., VScode)
  + configure Gnome shell (e.g., disable unused features, dark mode)
  + configure terminals (GnomeTerminal, VSCode Integrated Terminal)
  + configure VSCode

* in Windows
  + install essential software (msys2, WSL, VScode)
  + configure Windows shell (e.g., disable unused features, dark mode)
  + configure terminals (PowerShell, msys2, WSL, VSCode Integrated Terminal)
  + configure VSCode

* in macOS
  + install essential software (bash, VScode)
  + configure terminals (bash, VSCode Integrated Terminal)
  + configure VSCode

### How to use in Ubuntu, macOS, or WSL

The shell-helpers can be used as a [Bash Startup File](https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html).
To do that, fetch helpers.sh and insert the following command at the end of your `~/.bashrc` :

``` bash
wget -O ~/.config/helpers.sh https://raw.githubusercontent.com/alanlivio/shell-helpers/master/helpers.sh &&\
 echo "source ~/.config/helpers.sh" >> ~/.bashrc &&\
 source ~/.bashrc
```

### How to use in Windows

The shell-helpers can be used as a [PowerShell Profile](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7).
To do that, fetch helpers.ps1 and import it as powershell module:

``` powershell
Invoke-WebRequest https://raw.githubusercontent.com/alanlivio/shell-helpers/master/helpers.ps1 -OutFile C:\Windows\System32\WindowsPowerShell\v1.0\helpers.ps1;`
 Set-ExecutionPolicy unrestricted -force;`
 Import-Module -Force -Global C:\Windows\System32\WindowsPowerShell\v1.0\helpers.ps1;`
 hf_profile_install
```

### References and Thanks

Other projects were used as inspiration and reference.

sh helpers:

* https://github.com/mdo/config
* https://github.com/jenkins-x/dev-env
* https://github.com/jsutcodes/.bashrc_helper
* https://github.com/aspiers/shell-env

ps hepers:

* https://github.com/yiskang/PowerShellRc
* https://github.com/matt-beamish/Oh-My-Powershell
* https://gitlab.com/sgur/powershellrc/

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
