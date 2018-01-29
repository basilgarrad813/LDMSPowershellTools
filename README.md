# LDMSPowershellTools
This is a repository to house various scripts to help address certain issues and workarounds. Each script should contain a description that lists what the purpose of that script is as well as anything else you'd need to know about how or why'd you use a particular script.


* ### ChangeNetVersion.ps1
  * Changes .NET version registry keys to mimic .NET 4.6.2. Accepts install, restore and delete as arguments. 
  
* ### GetSharedAndDrives.ps1
  * Creates LDNetworkDrive and LDLocalShare wmi classes, then creates instances of those classes with the following information
    * LDNetworkDrive - Contains Path, Drive Letter and User the drive is mapped under for mapped network drives.
    * LDLocalShare - Contains Path and Permissions for local shares. 
    
* ### EnumerateAllPrograms.ps1
  * Runs through the Uninstall registry key and outputs data about the installed program and the regkey used to identify it

* ### RenameMiniFiles.ps1
  * Listens to file creation events in the LDScan folder and if any .mini files are created they are renamed to .miniscn so that the inventory server can process them.

* ### ChromeExt.ps1
  * Creates LDChromeExtension wmi class and then creates instances of those classes with the following information:
    * Extension name, version and ID
    * More info: https://community.ivanti.com/docs/DOC-62736

* ### ALS_SVC Delete.ps1
  * Deletes all users with ALS_SVC in the name. This should only be used on LDMS 2016.3 and 2017.1. 2017.3 fixes the presence of several users by providing a single user with a constantly changing password

* ### ElevatingScript.ps1
  * Can be added to the beginning of a powershell script to make it self elevate
    * Grabs the current running powershell command/script and then create an elevated powershell process, passes in the same information, and then exists
    * If the current session is already elevated, no action is taken. 
    * Doesn't bypass UAC, so if UAC is configured, the end user will be prompted before elevation occurs.

* ### EnumerateAllPrograms.ps1
  * Checks all programs that can be found in the Uninstall regkeys, 32 and 64 bit. 
    * Displays Name, Version, Install Location and Publisher in a human readable format

* ### NicBindingOrder.ps1
  * Checks the current NIC binding order on Windows

* ### RestartLDServices.ps1
  * Restarts all Landesk and Managed Planet services





    



