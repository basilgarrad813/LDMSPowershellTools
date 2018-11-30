[cmdletbinding()] 

 
param([Parameter(ValueFromPipeline = $True, 
        ValueFromPipelineByPropertyName = $True)]$Computer = '.')  

$parentdir = "C:\Users\"

$users = Get-ChildItem $parentdir

if (Get-WmiObject -List | Where-Object { $_.Name -eq "LDNetworkDrive"}) {
    #Clear existing entries to re-enumerate
    Get-WmiObject LDNetworkDrive | Remove-WmiObject      
}
else {
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

if (Get-WmiObject -List | Where-Object { $_.Name -eq "LDLocalShare"}) {
    #Clear existing entries to re-enumerate
    Get-WmiObject LDLocalShare | Remove-WmiObject          
}
else {
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

 
$shares = Get-WmiObject -Class win32_share -ComputerName $computer | Select-Object -ExpandProperty Name  
  
foreach ($share in $shares) { 

    $sharename = $share | Out-String

    try {

        try {
  
            $sharename = $sharename.TrimEnd();       
            if ($sharename -eq "IPC$") {
                continue
            }
            $cmd = 'net share ' + "'" + $sharename + "'"
        }
        catch {
            Write-Host $_.exception | format-list -force
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
    
        $permsubstring = $shareinfo.Substring($start, $finish - $start + 1) 

        #Write-host "Permisssions substring is $permsubstring"
      
        #Extract permissions from permission substring

        $permissions = $permsubstring.Substring(18).Trim().Replace("`r`n", ";")   
        $permissions = $permissions -replace '\s+', ' '
        $permissions = $permissions.Substring(0, $permissions.LastIndexOf(";") - 1);

        Set-WmiInstance -Class LDLocalShare -Puttype CreateOnly -Argument @{Name = $name; Path = $path; Permissions = $permissions}              
               
    } 
    catch { 
        Write-Host $_.exception | format-list -force    
    }  
} # end foreach $share

function Get-MappedDrives($ComputerName) {
    $output = @()
    try {

        if (Test-Connection -ComputerName $ComputerName -Count 1) {
            $Hive = [long]$HIVE_HKU = 2147483651
            $sessions = Get-WmiObject -ComputerName $ComputerName -Class win32_process | Where-Object {$_.name -eq "explorer.exe"}

            if ($sessions) {

                $explorer = $sessions

                if ($sessions -is [array]) {
                    $explorer = $sessions[0]
                }
            
      
                $sid = ($explorer.GetOwnerSid()).sid

                $owner = $explorer.GetOwner()

                $RegProv = get-WmiObject -List -Namespace "root\default" -ComputerName $ComputerName | Where-Object {$_.Name -eq "StdRegProv"}

                $DriveList = $RegProv.EnumKey($Hive, "$($sid)\Network")

                if ($DriveList.sNames.count -gt 0) {

                    foreach ($drive in $DriveList.sNames) {

                        $output += "$($drive)`t$(($RegProv.GetStringValue($Hive, "$($sid)\Network\$($drive)", "RemotePath")).sValue)`t$($owner.user)"

                    }

                }
                else {
                    write-host "No mapped drives on $($ComputerName)"
                }

            }
            else {
                write-host "explorer.exe not running on $($ComputerName)"
            }

        }
        else {
            write-host "Can't connect to $($ComputerName)"
        }

        return $output

    }
    catch {
        Write-Host "An error occured obtaining explorer sessions"
    }

}

try {


    $mappeddrives = Get-MappedDrives($env:COMPUTERNAME)

    write-host $mappeddrives

    foreach ($drive in $mappeddrives) {

        $driveletter = $drive.Substring(0, 1)

        $pathstart = $drive.indexof("\\")

        $path = $drive.substring($pathstart, ($drive.length - $pathstart))

        $userStartIndex = $path.IndexOf("`t") + 1

        $userEndIndex = $path.Length - ($path.IndexOf("`t'") + 1)

        $user = $path.Substring($userStartIndex, $userEndIndex - $userStartIndex)

        $user = $user -replace '[^a-zA-Z0-9]', ' '

        $user = $user.Trim()

        $path = $path.substring(0, ($path.length - $user.length)).trim()

        Write-output "Drive Letter is $driveletter"
        Write-output "Path is $path"
        Write-output "User is $user"

        Set-WmiInstance -Class LDNetworkDrive -Puttype CreateOnly -Argument @{Letter = $driveletter; Path = $path; User = $user}
    }
}
catch {
    Write-output $_.exception | format-list -force
}


