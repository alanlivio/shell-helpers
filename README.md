<h1 align="center">shell.env</h1>
<p align="center">
  shells:<img width="56" height="56" src="https://upload.wikimedia.org/wikipedia/commons/2/20/Bash_Logo_black_and_white_icon_only.svg">
  <img width="56" height="56" src="https://upload.wikimedia.org/wikipedia/commons/a/af/PowerShell_Core_6.0_icon.png">
  terminals:<img width="56" height="56" src="https://upload.wikimedia.org/wikipedia/commons/0/01/Windows_Terminal_Logo_256x256.png">
  <img width="56" height="56" src="https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/GNOME_Terminal_icon_2019.svg/1024px-GNOME_Terminal_icon_2019.svg.png">
  editors: <img width="56" height="56" src="https://upload.wikimedia.org/wikipedia/commons/2/2d/Visual_Studio_Code_1.18_icon.svg">
</p>

A programmer minimal enviorment include: shell, terminals, and code editors.  
This project aimg at support create such an enviroment in different operation systems.  
In particular, it supports helper function to:

- in Ubuntu
  - install essential software (e.g., VScode)
  - Gnome sanity (e.g., disable unused features, dark mode)
  - configure terminals (GnomeTerminal, VSCode Integrated Terminal)
  - configure VSCode
  
- in Windows
   - install essential software (msys2, VScode)
   - Windows sanity (e.g., disable unused features, dark mode)
   - configure terminals (PowerShell, msys2, VSCode Integrated Terminal)
   - configure VSCode

## How to use in Ubuntu

The shell.env can be used as a [Bash Startup File](https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html).  
To do that, fetch and insert the following command at the end of your `~/.bashrc`:

```bash
wget -O ~/.env/bash_helpers.sh https://raw.githubusercontent.com/alanlivio/bash-helpers/master/bash_helpers.sh &&\
  echo "source ~/.env/bash_helpers.sh" >> ~/.bashrc &&\
  source ~/.bashrc
```

## How to use in Windows

The shell.env can be used as a [PowerShell Profile](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7).  
To do that, fetch powershell-helpers andmport it as module:

```powershell
Invoke-WebRequest raw.githubusercontent.com/alanlivio/powershell-helper-functions/master/powershell_helpers.ps1 -OutFile C:\Windows\System32\WindowsPowerShell\v1.0\powershell_helpers.ps1;`
  Set-ExecutionPolicy unrestricted -force;`
  Import-Module -Force -Global C:\Windows\System32\WindowsPowerShell\v1.0\powershell_helpers.ps1;`
  hf_profile_install
```
