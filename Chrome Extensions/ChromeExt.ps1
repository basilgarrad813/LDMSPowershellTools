$parentdir = "C:\Users\"

$users = Get-ChildItem $parentdir




if(Get-WmiObject -List | where { $_.Name -ne "LDChromeExtension"}){
        

$newClass = New-Object System.Management.ManagementClass `
            ("root\cimv2", [String]::Empty, $null); 

        $newClass["__CLASS"] = "LDChromeExtension"; 

        $newClass.Qualifiers.Add("Static", $true)

        $newClass.Properties.Add("Name", `
            [System.Management.CimType]::String, $false)

        $newClass.Properties["Name"].Qualifiers.Add("Key", $true)

        $newClass.Properties.Add("ID", `
            [System.Management.CimType]::String, $false)

        $newClass.Properties["ID"].Qualifiers.Add("Key", $true)

        $newClass.Properties.Add("Version", `
            [System.Management.CimType]::String, $false)

        $newClass.Properties["Version"].Qualifiers.Add("Key", $true)

        
        $newClass.Put()

          
}
else{

#Clear existing entries to re-enumerate extensions
Get-WmiObject LDChromeExtension | Remove-WmiObject
     
}

Foreach($user in $users){

    $targetdir = $parentdir + $user.ToString() + "\AppData\Local\Google\Chrome\User Data\Default\Extensions"

    #get extension folders

    $extensions = Get-ChildItem $targetdir -ErrorAction SilentlyContinue

    Foreach($ext in $extensions){

        #continue if error
        Set-Location $targetdir\$ext -ErrorAction SilentlyContinue

        #get subfolders in extension folder - usually named the version of the extension

        $folders = (Get-ChildItem).Name

            Foreach($folder in $folders){

            Set-Location $folder -ErrorAction SilentlyContinue

            #convert manifest.json to object

            $json = Get-Content manifest.json -Raw | ConvertFrom-Json

            $obj = New-Object System.Object
    
            #get name and version from json and add to object

            $obj | Add-Member -MemberType NoteProperty -Name Name -Value $json.name
            $obj | Add-Member -MemberType NoteProperty -Name Version -Value $json.version

            #get app id from extension folder name and add to object

            $obj | Add-Member -MemberType NoteProperty -Name ID -Value $ext.ToString()

            #check if name contains __MSG_ - that means the manifest didn't contain the real name, so we need to check the chrome store using the app id

                if($obj.Name.Contains("__MSG_")){

                #build the url for the exstension's page

                $url = "https://chrome.google.com/webstore/detail/" + $obj.ID

                #download page and scrape the title out of <title></title>

                $wc = New-Object System.Net.WebClient

                    try{
                        $data = $wc.downloadstring($url)    
                        #scrape the title
                        $titletag = [regex] '(?<=<title>)([\S\s]*?)(?=</title>)' 
                        #trim the title
                        $title = $titletag.Match($data).value.trim()    
                        $obj.Name = $title
                    }
                    catch{
                        #if something goes wrong, like the download fails, set the name to unknown
                        $obj.Name = "Unknown"
                    }

                }
                #add an entry to the name that notes the extension was gathered locally if it didn't need to hit the web store
                if(!$obj.Name.Contains("Unknown")){

                    if(!$obj.Name.Contains("Chrome Web Store")){
                    $obj.Name += " - Local"
                    }
                }
            
            Set-WmiInstance -Class LDChromeExtension -Puttype CreateOnly -Argument @{Name = $obj.Name; ID = $obj.ID; Version = $obj.Version} -ErrorAction SilentlyContinue
        }
    }
}