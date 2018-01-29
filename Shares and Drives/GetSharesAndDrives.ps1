[cmdletbinding()] 

 
param([Parameter(ValueFromPipeline=$True, 
    ValueFromPipelineByPropertyName=$True)]$Computer = '.')  

$parentdir = "C:\Users\"

$users = Get-ChildItem $parentdir




if(Get-WmiObject -List | where { $_.Name -ne "LDNetworkDrive"}){
$newClass = New-Object System.Management.ManagementClass `
            ("root\cimv2", [String]::Empty, $null); 

        $newClass["__CLASS"] = "LDNetworkDrive"; 

        $newClass.Qualifiers.Add("Static", $true)

        $newClass.Properties.Add("Letter", `
            [System.Management.CimType]::String, $false)

        $newClass.Properties["Letter"].Qualifiers.Add("Key", $true)

           $newClass.Properties.Add("Path", `
            [System.Management.CimType]::String, $false)

        $newClass.Properties["Path"].Qualifiers.Add("Key", $true)

                   $newClass.Properties.Add("User", `
            [System.Management.CimType]::String, $false)

        $newClass.Properties["User"].Qualifiers.Add("Key", $true)

        
        $newClass.Put()          
}
else{

#Clear existing entries to re-enumerate
Get-WmiObject LDNetworkDrive | Remove-WmiObject
     
}

if(Get-WmiObject -List | where { $_.Name -ne "LDLocalShare"}){


$newClass = New-Object System.Management.ManagementClass `
            ("root\cimv2", [String]::Empty, $null); 

        $newClass["__CLASS"] = "LDLocalShare"; 

        $newClass.Qualifiers.Add("Static", $true)

        $newClass.Properties.Add("Name", `
            [System.Management.CimType]::String, $false)

        $newClass.Properties["Name"].Qualifiers.Add("Key", $true)

        $newClass.Properties.Add("Path", `
            [System.Management.CimType]::String, $false)

        $newClass.Properties["Path"].Qualifiers.Add("Key", $true)

        $newClass.Properties.Add("Permissions", `
            [System.Management.CimType]::String, $false)

        $newClass.Properties["Permissions"].Qualifiers.Add("Key", $true)

        
        $newClass.Put()
          
}
else{

#Clear existing entries to re-enumerate
Get-WmiObject LDLocalShare | Remove-WmiObject
     
}    

 
$shares = gwmi -Class win32_share -ComputerName $computer | select -ExpandProperty Name  
  
foreach ($share in $shares) { 


$sharename = $share | Out-String



try {  

    try{
  
       $sharename = $sharename.TrimEnd();

       
       if($sharename -eq "IPC$"){continue}

       $cmd = 'net share ' + "'" + $sharename + "'"
    }

    catch

    {


    }

    $shareinfo = Invoke-Expression $cmd | out-string
    

    #Getting name substring

    $start = 0

    $finish = $shareinfo.IndexOf("`r")

    $namesubstring = $shareinfo.Substring($start, $finish)

    #Getting path substring

    $start = $namesubstring.Length + 1
    
    $finish = $shareinfo.IndexOf("`r", $start)

    $pathsubstring = $shareinfo.Substring($start, $finish - $start + 1).Trim()

    #Extract name from namesubstring


    $start = $namesubstring.trim().Length - $sharename.Length

    $name = $namesubstring.Substring($start).Trim()

    write-host "Name is $name"

    #Extract path from pathsubstring    
    
    $start = $pathsubstring.IndexOf(":") - 1
    

    $path = $pathsubstring.Substring($start).Trim()

    write-host "Path is $path"

    
    #Get permissions substring
    
    $start = $shareinfo.lastindexof("Permission")

    $finish = $shareinfo.trim().length
    
    $permsubstring = $shareinfo.Substring($start,$finish - $start + 1) 

    #Write-host "Permisssions substring is $permsubstring"
      
    #Extract permissions from permission substring

    $permissions = $permsubstring.Substring(18).Trim().Replace("`r`n", ";")   
    $permissions = $permissions -replace '\s+', ' '
    $permissions = $permissions.Substring(0, $permissions.LastIndexOf(";") - 1);

    Set-WmiInstance -Class LDLocalShare -Puttype CreateOnly -Argument @{Name = $name; Path = $path; Permissions = $permissions}
              
               
        } 
    catch  
        { 
        #Write-host "Failed on $share"
        Write-Host $_.exception | format-list -force
        #Write-Host ""       
         }  
    #$ACL  
   # Write-Host $('=' * 50)  
    } # end foreach $share



function Get-MappedDrives($ComputerName){
  $output = @()
  if(Test-Connection -ComputerName $ComputerName -Count 1 -Quiet){
    $Hive = [long]$HIVE_HKU = 2147483651
    $sessions = Get-WmiObject -ComputerName $ComputerName -Class win32_process | ?{$_.name -eq "explorer.exe"}

    if($sessions){

      foreach($explorer in $sessions){
        $sid = ($explorer.GetOwnerSid()).sid

        $owner  = $explorer.GetOwner()

        $RegProv = get-WmiObject -List -Namespace "root\default" -ComputerName $ComputerName | Where-Object {$_.Name -eq "StdRegProv"}

        $DriveList = $RegProv.EnumKey($Hive, "$($sid)\Network")

        if($DriveList.sNames.count -gt 0){

          foreach($drive in $DriveList.sNames){

          $output += "$($drive)`t$(($RegProv.GetStringValue($Hive, "$($sid)\Network\$($drive)", "RemotePath")).sValue)`t$($owner.user)"

          }

        }else{write-debug "No mapped drives on $($ComputerName)"}

      }

    }else{write-debug "explorer.exe not running on $($ComputerName)"}

  }else{write-debug "Can't connect to $($ComputerName)"}

  return $output
}

try{


$mappeddrives = Get-MappedDrives($env:COMPUTERNAME)

    foreach($drive in $mappeddrives){

    $driveletter = $drive.Substring(0, 1)

    $pathstart = $drive.indexof("\\")

    $path = $drive.substring($pathstart, ($drive.length - $pathstart))

    #$path = $path.substring(0, ($path.indexof('`t') - 1))

    $user = $path.Substring($path.IndexOf("\", 2), ($path.Length - $path.IndexOf("\", 2)))

    $user = $user -replace '[^a-zA-Z0-9]', ' '

    $user = $user.Trim()

    $user = $user.substring($user.indexof(' '), $user.length - $user.IndexOf(" ")).trim()


    $path = $path.substring(0, ($path.length - $user.length)).trim()

    Write-output "Drive Letter is $driveletter"
    Write-output "Path is $path"
    Write-output "User is $user"

    Set-WmiInstance -Class LDNetworkDrive -Puttype CreateOnly -Argument @{Letter = $driveletter; Path = $path; User = $user}


    <#$user = $user.substring(

    $user = $user.substring($user.indexof(" "), $user.length - $user.idexof(" "))
    

    Write-host $drive.Substring($pathstart, $drive.IndexOf(" ", $pathstart + 1))

    $mappedpath = $drive.Substring($pathstart, )
    Write-host "mapped path is $mappedpath"#>


}
}
catch
{
Write-output $_.exception | format-list -force
}








