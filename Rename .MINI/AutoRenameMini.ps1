<# 
    .Description
    This script will subscribe to File events in your LDScan folder and if .mini files are ever written they will be re-written to .miniscn
    This script solves a problem where scan files would appear in your ldscan folder but never get used cause they are the incorrect file extension.
    
    .Notes
    After running this script you can see that you have an event by running the following command in powershell
        Get-EventSubscriber
    If you feel that you need to remove the event for whatever reason you can do so with the following command
        Unregister-Event -SourceIdentifier OnMiniScanStored
    
#>
$folder = "$env:LDMS_HOME\LDScan"
$filter = '*.mini'
$fsw = New-Object IO.FileSystemWatcher $folder, $filter -Property @{
    IncludeSubdirectories = $false
    NotifyFilter          = [IO.NotifyFilters]'FileName, LastWrite'
}

$onCreated = Register-ObjectEvent $fsw Created -SourceIdentifier OnMiniScanStored -Action {
    $obj = @{
        Path = $Event.SourceEventArgs.FullPath
        Name = $Event.SourceEventArgs.Name
        ChangeType = $Event.SourceEventArgs.ChangeType
        TimeStamp = $Event.TimeGenerated
    }
    Rename-Item -Path $obj.Path -NewName $obj.Path.Replace("`.mini", ".miniscn")
}