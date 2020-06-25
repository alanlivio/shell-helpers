# powershell-helpers

![terminal](https://upload.wikimedia.org/wikipedia/commons/a/af/PowerShell_Core_6.0_icon.png)

This project provides a set of helpers to be used in PowerShell cmd.  

## How to use

To fetch powershell-helpers, run:

```powershell
Invoke-WebRequest raw.githubusercontent.com/alanlivio/powershell-helper-functions/master/powershell_helpers.ps1 -OutFile C:\Windows\System32\WindowsPowerShell\v1.0\powershell_helpers.ps1
```

The powershell-helpers can be used as a [PowerShell Profile](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7).  
To do that, run:

``` powershell
Set-ExecutionPolicy unrestricted -force;`
Import-Module -Force -Global C:\Windows\System32\WindowsPowerShell\v1.0\powershell_helpers.ps1;`
hf_profile_install
```
