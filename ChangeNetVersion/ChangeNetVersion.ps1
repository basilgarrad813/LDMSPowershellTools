<#

ChangeNetVersion

Current Version: 2.0

History:

2.0 - Change interctivity to allow for scripted runs. Changed command to script param. 

1.0 - Initial release.



#>


#Check if running in elevated mode
param (
[string]$action
)

  $wid=[System.Security.Principal.WindowsIdentity]::GetCurrent()
  $prp=new-object System.Security.Principal.WindowsPrincipal($wid)
  $adm=[System.Security.Principal.WindowsBuiltInRole]::Administrator
  $IsAdmin=$prp.IsInRole($adm)
  if (!$IsAdmin)
  {
  
    write-output "This script must be run in an elevated powershell session. Exiting..."
    exit
  }


$install = [string]::Compare($action, "install", $True)

$restore = [string]::Compare($action, "restore", $True)

$delete = [string]::Compare($action, "delete", $True)

#Write-Host ("install is $install, restore is $restore")

if($install -eq '0') 
{
    $currentUser = $env:UserDomain + "\" + $env:UserName

Function Enable-Ownership { # Loads advapi32.dll to allow for modification of registry properties via .NET pipe
  param($Privilege)
  $Definition = @'
using System;
using System.Runtime.InteropServices;
public class AdjPriv {
  [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
  internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall,
    ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr rele);
  [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
  internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr phtok);
  [DllImport("advapi32.dll", SetLastError = true)]
  internal static extern bool LookupPrivilegeValue(string host, string name,
    ref long pluid);
  [StructLayout(LayoutKind.Sequential, Pack = 1)]
  internal struct TokPriv1Luid {
    public int Count;
    public long Luid;
    public int Attr;
  }
  internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
  internal const int TOKEN_QUERY = 0x00000008;
  internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;
  public static bool EnablePrivilege(long processHandle, string privilege) {
    bool retVal;
    TokPriv1Luid tp;
    IntPtr hproc = new IntPtr(processHandle);
    IntPtr htok = IntPtr.Zero;
    retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY,
      ref htok);
    tp.Count = 1;
    tp.Luid = 0;
    tp.Attr = SE_PRIVILEGE_ENABLED;
    retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
    retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero,
      IntPtr.Zero);
    return retVal;
  }
}
'@
  $ProcessHandle = (Get-Process -id $pid).Handle
  $type = Add-Type $definition -PassThru
  $type[0]::EnablePrivilege($processHandle, $Privilege)
}

do {} until (Enable-Ownership SeTakeOwnershipPrivilege) #Allow ownership modification to change owner to current user


# Set owner of key to current user and then set acl to allow current user full control 
$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(
  'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Client\1033',
  'ReadWriteSubTree', 'TakeOwnership')
$owner = [Security.Principal.NTAccount]$currentUser
$acl = $key.GetAccessControl()
$acl.SetOwner($owner)
$key.SetAccessControl($acl)
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ($currentUser,"FullControl","Allow")
$acl.SetAccessRule($rule)
$key.SetAccessControl($acl)

# Set owner of key to current user and then set acl to allow current user full control 

$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(
  'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full',
  'ReadWriteSubTree', 'TakeOwnership')
$owner = [Security.Principal.NTAccount]$currentUser
$acl = $key.GetAccessControl()
$acl.SetOwner($owner)
$key.SetAccessControl($acl)
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ($currentUser,"FullControl","Allow")
$acl.SetAccessRule($rule)
$key.SetAccessControl($acl)

# Set owner of key to current user and then set acl to allow current user full control 

$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(
  'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\1033',
  'ReadWriteSubTree', 'TakeOwnership')
$owner = [Security.Principal.NTAccount]$currentUser
$acl = $key.GetAccessControl()
$acl.SetOwner($owner)
$key.SetAccessControl($acl)
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ($currentUser,"FullControl","Allow")
$acl.SetAccessRule($rule)
$key.SetAccessControl($acl)

# Set owner of key to current user and then set acl to allow current user full control 

$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(
  'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Client',
  'ReadWriteSubTree', 'TakeOwnership')
$owner = [Security.Principal.NTAccount]$currentUser
$acl = $key.GetAccessControl()
$acl.SetOwner($owner)
$key.SetAccessControl($acl)
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ($currentUser,"FullControl","Allow")
$acl.SetAccessRule($rule)
$key.SetAccessControl($acl)

if(Test-Path Client.reg)
{
    write-output("Backed up Client regkey already found. Not backing up key")
}
else
{   # Export regkeys and supress overwrite prompt 

    Reg Export 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Client' 'Client.reg' /y
    write-output("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Client backed up")

}
if(Test-Path Client1033.reg)
{
    write-output("Backed up Client\1033 regkey already found. Not backing up key")
}
else
{   # Export regkeys and supress overwrite prompt 
    Reg Export 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Client' 'Client1033.reg' /y
    write-output("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Client\1033 backed up")
}
if(Test-Path Full.reg)
{
    write-output("Backed up Full regkey already found. Not backing up key")
}
else
{   # Export regkeys and supress overwrite prompt 
  
    Reg Export 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' 'Full.reg' /y
    write-output("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full backed up")
}
if(Test-Path Full1033.reg)
{
    write-output("Backed up Full\1033 regkey already found. Not backing up key")
}
else
{   # Export regkeys and supress overwrite prompt 

    Reg Export 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\1033' 'Full1033.reg' /y
    write-output("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\1033 backed up")
}


$registryPath = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Client\"

$Name = "Version"

$value = "4.6.01586"

Set-ItemProperty -Path $registryPath -Name $name -Value $value # Update value of key

$registryPath = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Client\1033"

$Name = "Version"

$value = "4.6.01586"

Set-ItemProperty -Path $registryPath -Name $name -Value $value # Update value of key

$registryPath = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"

$Name = "Version"

$value = "4.6.01586"

Set-ItemProperty -Path $registryPath -Name $name -Value $value # Update value of key

$registryPath = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\1033"

$Name = "Version"

$value = "4.6.01586"

Set-ItemProperty -Path $registryPath -Name $name -Value $value # Update value of key

write-output("Updated the $Name to represent $value")

  }


elseif($restore -eq '0') 

{
$failedrestores = 0
$keysfailed = ""

    if(Test-Path Client.reg)
    {
    reg import 'Client.reg'
    }
    else
    {
        $failedrestores = $failedrestores + 1
        $keysfailed = $keysfailed + "Client.reg "
    }

    if(Test-Path Client.reg)
    {
    reg import 'Client1033.reg'
    }
    else
    {
        $failedrestores = $failedrestores + 1
        $keysfailed = $keysfailed + "Client1033.reg "
    }

    if(Test-Path Client.reg)
    {
    reg import 'Full.reg'
    }
    else
    {
        $failedrestores = $failedrestores + 1
        $keysfailed = $keysfailed + "Full.reg "
    }

    if(Test-Path Client.reg)
    {
    reg import 'Full1033.reg'
    }
    else
    {
        $failedrestores = $failedrestores + 1
        $keysfailed = $keysfailed + "Full1033.reg "
    }

       if($failedrestores -gt 0)
       {
        write-output("$failedrestores keys failed to restore: $keysfailed")
       }
    
    }

elseif($delete -eq '0') 

{

    write-output("WARNING! YOU ARE ABOUT TO DELETE YOUR REGISTRY BACKUPS")
    $confirm = Read-Host -prompt "Type DELETE in CAPS to proceed with deletion"
    $DELETE = "DELETE"
    $check = [string]::Compare($confirm, $DELETE, $False)

    if($check -eq '0')
    {
            if(Test-Path Client.reg)
            {
    
            Remove-Item 'Client.reg'
            }


            if(Test-Path Client1033.reg)
            {
    
            Remove-Item 'Client1033.reg'
            }

            if(Test-Path Full.reg)
            {
    
            Remove-Item 'Full.reg'
            }

            if(Test-Path Full1033.reg)
            {
    
            Remove-Item 'Full1033.reg'
            }
            
            write-output("Keys deleted")
       
    }
    
    else 
    {
        write-output("DELETE not entered, keys not deleted. Exiting...")
        exit
    }
    

    }

else 
{

    write-output("Invalid input. Please enter Install or Restore")

}

