# powershell_helpers

![terminal](https://upload.wikimedia.org/wikipedia/commons/a/af/PowerShell_Core_6.0_icon.png)

This project provide a set of helpers to be used in powershell cmd.
It intented to be used as [Powershell Profile](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7)

## How to use

Fetch the `powershell_helper_functions.ps1` , enable script execution and load:

``` powershell
Invoke-WebRequest raw.githubusercontent.com/alanlivio/powershell-helper-functions/master/powershell_helper_functions.ps1 -OutFile C:\Windows\System32\WindowsPowerShell\v1.0\powershell_helper_functions.ps1;`
  Set-ExecutionPolicy unrestricted -force;`
  Import-Module -Force -Global C:\Windows\System32\WindowsPowerShell\v1.0\powershell_helper_functions.ps1;`
  hf_profile_install
```
