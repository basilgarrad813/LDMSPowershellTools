param($ServerName = $null) 
 
$objReg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $ServerName) 
$objRegKey = $objReg.OpenSubKey("SYSTEM\\Currentcontrolset\\Services\\TCPIP\\Linkage" ) 
$arrItem = $objRegKey.GetValue("Bind") 
 
Write-Host "" 
Write-Host "HostName : " $ServerName.ToUpper() 
Write-Host "" 
foreach ($item in $arrItem) {  
    $item = $item -replace "\\device\\", "" 
    $objRegKey = $objReg.OpenSubKey("SYSTEM\\Currentcontrolset\\Control\Network\\{4D36E972-E325-11CE-BFC1-08002be10318}\\" + $item + "\\Connection") 
    $strBind = $objRegKey.GetValue("Name") 
    Write-Host "NIC      : " $strBind 
     
    $objRegKeyIP = $objReg.OpenSubKey("SYSTEM\\Currentcontrolset\\Services\\TCPIP\\Parameters\\Interfaces\\" + $item ) 
    $arrItemIP = $objRegKeyIP.GetValue("IPAddress") 
     
    foreach ($itemIP in $arrItemIP) { 
        If ($itemIP -eq $null) { 
            Write-Host "IP       :  NOT ASSIGNED"  
        } 
        Else { 
            Write-Host "IP       : " $itemIP 
        } 
    Write-Host "" 
    } 
     
} 