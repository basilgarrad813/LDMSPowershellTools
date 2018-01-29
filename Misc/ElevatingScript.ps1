<#

Add this to the beginning of your powershell script to make it self elevating

The script does the following:
* Checks to see if the script is already running in an elevated environment. If it is, this code skips over to the rest of the script as normal.
* If not running as admin, checks to see if the Windows operating system build number is 6000 (Windows Vista) or greater. Earlier builds did not support elevation via "Run As", so this won't work on those
* If that checks out, grabs the command line used to run this script, including any arguments.
* Starts a new elevated PowerShell process where the script runs again, using the data from the previous step. Once the script terminates, the elevated PowerShell window closes.

#>

if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
 }
}