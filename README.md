<h1 align="center">shell-env</h1>
<p align="center">
  shells:<img width="56" height="56" src="https://upload.wikimedia.org/wikipedia/commons/2/20/Bash_Logo_black_and_white_icon_only.svg">
  <img width="56" height="56" src="https://upload.wikimedia.org/wikipedia/commons/a/af/PowerShell_Core_6.0_icon.png">
  terminals:<img width="56" height="56" src="https://upload.wikimedia.org/wikipedia/commons/0/01/Windows_Terminal_Logo_256x256.png">
  <img width="56" height="56" src="https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/GNOME_Terminal_icon_2019.svg/1024px-GNOME_Terminal_icon_2019.svg.png">
  editors: <img width="56" height="56" src="https://upload.wikimedia.org/wikipedia/commons/2/2d/Visual_Studio_Code_1.18_icon.svg">
</p>

This project aims at support create minimal programmer shell environment in different operating systems.  
Its configures cmd shells, graphical shells, terminals, and code editors.  
In particular, it supports helper functions for:

- in Ubuntu
  - install essential software (e.g., VScode)
  - configure Gnome shell (e.g., disable unused features, dark mode)
  - configure terminals (GnomeTerminal, VSCode Integrated Terminal)
  - configure VSCode
  
- in Windows
  - install essential software (msys2, VScode)
  - configure Windows shell (e.g., disable unused features, dark mode)
  - configure terminals (PowerShell, msys2, VSCode Integrated Terminal)
  - configure VSCode

## How to use in Ubuntu

The shell-env can be used as a [Bash Startup File](https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html).  
To do that, fetch helpers and insert the following command at the end of your `~/.bashrc`:

```bash
wget -O ~/.env/helpers.sh https://raw.githubusercontent.com/alanlivio/shell-env/master/helpers.sh &&\
  echo "source ~/.env/helpers.sh" >> ~/.bashrc &&\
  source ~/.bashrc
```

## How to use in Windows

The shell-env can be used as a [PowerShell Profile](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7).  
To do that, fetch helpers and import it as powershell module:

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/alanlivio/shell-env/master/helpers.ps1 -OutFile C:\Windows\System32\WindowsPowerShell\v1.0\helpers.ps1;`
  Set-ExecutionPolicy unrestricted -force;`
  Import-Module -Force -Global C:\Windows\System32\WindowsPowerShell\v1.0\helpers.ps1;`
  hf_profile_install
```
