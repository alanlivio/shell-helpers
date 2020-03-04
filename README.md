# powershell_profile

![terminal](https://upload.wikimedia.org/wikipedia/commons/a/af/PowerShell_Core_6.0_icon.png)

This project provide a set of helper functions to be used in powershell cmd.

## How to use

Fetch the  `powershell_helper_functions.ps1`, enable script execution and load:

```powershell
Invoke-WebRequest raw.githubusercontent.com/alanlivio/powershell-helper-functions/master/powershell_helper_functions.ps1 -OutFile C:\Windows\System32\WindowsPowerShell\v1.0\powershell_helper_functions.ps1;`
  Set-ExecutionPolicy unrestricted -force;`
  Import-Module -Force -Global C:\Windows\System32\WindowsPowerShell\v1.0\powershell_helper_functions.ps1;
  hf_profile_install
```
