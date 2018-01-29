ChangeNetVersion.ps1

Params:

Install - Backs up the .NET registry keys to the directory the script is launched from, then changes the Version values to 4.6.01586
Restore - Checks for regkey backups and restores them
Delete - Deletes regkey backups after text authorization

Instructions:
Launch elevated powershell
Change directory to directory of ChangeNetVersion.ps1
Run ./ChangeNetVersion.ps1 with parameter of your choice

Example for the install: ./ChangeNetVersion.ps1 Install

You may need to run one of the below commands to allow for script execution
Set-ExecutionPolicy Unrestricted
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted

