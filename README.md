# powershell_profile

![terminal](https://upload.wikimedia.org/wikipedia/commons/a/af/PowerShell_Core_6.0_icon.png)

This project made easy bash profile configuration and have helper functions to be used in powershell cmd.

## How to use 

1. Download and enable script exececution.
```powershell
Invoke-WebRequest raw.githubusercontent.com/alanlivio/powershell_profile/master/powershell_profile.ps1 -OutFile C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1
Set-ExecutionPolicy unrestricted
```

2. Force load (optional)
```powershell
Import-Module -Force -Global C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1
```
