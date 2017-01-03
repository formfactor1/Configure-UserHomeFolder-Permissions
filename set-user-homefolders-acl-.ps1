<#
.Disclaimer
This script is provided as is. I and the company I work for, are not responsible for the outcome of running this script and cannot be held responsible for its use.
Use at your own discrection and risk.
.Description
This Powershell script can be used to set permission for home folders and folders that are created via group policy.
The script allows you to create a baseline folder with the desired permission, and have those permissions set on all of the other folders.
The script also reads the username from the userhome directory and assigns only that user, and the users and groups from the baseline folder.
.How To Use
There are a few lines that need to be modified before you can use the script in your environmentm.
Change the path in line 18 for the baseline folder. Set the desired permissions on the baseline folder first. I.E any admin users and groups.
Change the path in line 21 and 24 to your root shared folder. 
.Created By Nathan Studebaker
#>
#Powershell script to set home folder permissions for all folders in the specified path

#Baseline folder
$BaselineFolder = Get-Item C:\test2\demo | Select-Object FullName

#Get username
$UserName=GET-CHILDITEM C:\test | Select-Object Name

#get all folders in path set below and place in variable, enter the path to the home folder below
$HomeFolders=GET-CHILDITEM C:\test | Select-Object FullName
 
ForEach($loginname in $UserName)
    {
        #set domain below
        $global:domianusername=’testnb\’+$loginname.Name
        $global:verifyusername='C:\test\'+$loginname.Name
    
#Loop to modify each folder in the path set above
Foreach ($Folder in $HomeFolders)
{
 #retrieve the acl that we wish to copy
 $Access=GET-ACL $BaseLineFolder.FullName 
 
Write-Host "Before If"
Write-Host $Folder.FullName
Write-host $global:verifyusername
If ($Folder.FullName -eq $global:verifyusername)
{
#Set Rights that will be changed in following variables
#for rights available see http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.filesystemrights.aspx
$FileSystemRights=[System.Security.AccessControl.FileSystemRights]"Modify"
$AccessControlType=[System.Security.AccessControl.AccessControlType]"Allow"
$InheritanceFlags=[System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
$PropagationFlags=[System.Security.AccessControl.PropagationFlags]"None"
#"InheritOnly"
$IdentityReference=$global:domianusername

#print what folder is being modified currently
Write-host "Changing permissions on:" $Folder.FullName

#Build command to modify folder ACL's and place in variable
$FileSystemAccessRule=New-Object System.Security.AccessControl.FileSystemAccessRule ($IdentityReference, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)
 
$Access.AddAccessRule($FileSystemAccessRule)
 
#Set ACL's on Folder being modified
 SET-ACL -Path $Folder.FullName -AclObject $Access
}
}
}
#NOTES

#use get-executionpolicy to view what the script execution polily is
#use Set-executionpolicy to set the policy options are Unrestricted | RemoteSigned | AllSigned | Restricted

#The possible values for Rights are 
# ListDirectory, ReadData, WriteData 
# CreateFiles, CreateDirectories, AppendData 
# ReadExtendedAttributes, WriteExtendedAttributes, Traverse
# ExecuteFile, DeleteSubdirectoriesAndFiles, ReadAttributes 
# WriteAttributes, Write, Delete 
# ReadPermissions, Read, ReadAndExecute 
# Modify, ChangePermissions, TakeOwnership
# Synchronize, FullControl