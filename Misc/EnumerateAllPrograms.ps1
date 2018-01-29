$array = @()

    #Set name of computer to check

    $computername= $env:COMPUTERNAME

    #Define the variable to hold the location of Currently Installed Programs

    $UninstallKey=”SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall” 

    #Create an instance of the Registry Object and open the HKLM base key

    $reg=[microsoft.win32.registrykey]::OpenRemoteBaseKey(‘LocalMachine’,$computername) 

    #Drill down into the Uninstall key using the OpenSubKey Method

    $regkey=$reg.OpenSubKey($UninstallKey) 

    #Retrieve an array of string that contain all the subkey names

    $subkeys=$regkey.GetSubKeyNames() 

    #Open each Subkey and return the required values for each

    foreach($key in $subkeys){

        $thisKey=$UninstallKey+”\\”+$key 

        $thisSubKey=$reg.OpenSubKey($thisKey) 

        $obj = New-Object PSObject

        $obj | Add-Member -MemberType NoteProperty -Name “ComputerName” -Value $computername

        $obj | Add-Member -MemberType NoteProperty -Name “DisplayName” -Value $($thisSubKey.GetValue(“DisplayName”))

        $obj | Add-Member -MemberType NoteProperty -Name “DisplayVersion” -Value $($thisSubKey.GetValue(“DisplayVersion”))

        $obj | Add-Member -MemberType NoteProperty -Name “InstallLocation” -Value $($thisSubKey.GetValue(“InstallLocation”))

        $obj | Add-Member -MemberType NoteProperty -Name “Publisher” -Value $($thisSubKey.GetValue(“Publisher”))
        $obj | Add-Member -MemberType NoteProperty -Name "KeyFound" -Value $($thisKey.ToString())

        $array += $obj

    } 

$array | Where-Object { $_.DisplayName } | select ComputerName, DisplayName, DisplayVersion, Publisher, KeyFound

$array2 = @()

    #Set name of computer to check

    $computername= "localhost" 

    #Define the variable to hold the location of Currently Installed Programs

    $UninstallKey=”SOFTWARE\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall” 

    #Create an instance of the Registry Object and open the HKLM base key

    $reg=[microsoft.win32.registrykey]::OpenRemoteBaseKey(‘LocalMachine’,$computername) 

    #Drill down into the Uninstall key using the OpenSubKey Method

    $regkey=$reg.OpenSubKey($UninstallKey) 

    #Retrieve an array of string that contain all the subkey names

    $subkeys=$regkey.GetSubKeyNames() 

    #Open each Subkey and return the required values for each

    foreach($key in $subkeys){

        $thisKey=$UninstallKey+”\\”+$key 

        $thisSubKey=$reg.OpenSubKey($thisKey) 

        $obj = New-Object PSObject

        $obj | Add-Member -MemberType NoteProperty -Name “ComputerName” -Value $computername

        $obj | Add-Member -MemberType NoteProperty -Name “DisplayName” -Value $($thisSubKey.GetValue(“DisplayName”))

        $obj | Add-Member -MemberType NoteProperty -Name “DisplayVersion” -Value $($thisSubKey.GetValue(“DisplayVersion”))

        $obj | Add-Member -MemberType NoteProperty -Name “InstallLocation” -Value $($thisSubKey.GetValue(“InstallLocation”))

        $obj | Add-Member -MemberType NoteProperty -Name “Publisher” -Value $($thisSubKey.GetValue(“Publisher”))
        $obj | Add-Member -MemberType NoteProperty -Name "KeyFound" -Value $($thisKey.ToString())

        $array2 += $obj

    } 

$array2 | Where-Object { $_.DisplayName } | select ComputerName, DisplayName, DisplayVersion, Publisher, KeyFound