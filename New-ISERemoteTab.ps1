#requires -version 4.0


Function New-ISERemoteTab {

<#
.Synopsis
Create remote tabs in the PowerShell ISE.

.Description
This command will create one or more remote tabs in the PowerShell ISE. You could use this to programmatically to open multiple remote tabs.

The default behavior is to open tabs with your current credentials. But you can specify a single credential for all remote connections, or prompt for a credential for each connection. You might need this if some of the machines require different credentials.

.Parameter Computername
The name of the server to connect. This parameter has an alias of CN.

.Parameter Credential
A PSCredential or user name to be used for all specified computers. Note that if you specify a credential, it will temporarily be exported to disk so that each new PowerShell tab can re-use it. The file is deleted at the end of the command.

.Parameter PromptforCredential
Use this parameter if you want to prompt for a credential for each connection. No credential information is written to disk.

.Example
PS C:\> New-ISERemoteTab chi-dc01

.Example
PS C:\> Get-Content c:\work\chi.txt | New-ISERemoteTab -credential mydomain\administrator

Create remote tabs for each computer in the list using alternate credentials.

.Example
PS C:\> New-ISERemoteTab dmz-srv01,dmz,srv02,dmz,srv03 -prompt

Create remote tabs for each computer and prompt for a unique set of credentials for each.

.Notes
Last Updated: 29 November 2015
Author      : @JeffHicks
version     : 1.0

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************

.Link
Enter-PSSession

#>

[cmdletbinding(DefaultParameterSetName="Credential")]

Param(
[Parameter(
    Position = 0,
    Mandatory,
    HelpMessage = "Enter the name of a remote computer",
    ValueFromPipeline,
    ValueFromPipelineByPropertyName
)]
[ValidateNotNullorEmpty()]
[Alias("cn")]
[string[]]$Computername,

[Parameter(ParameterSetName="Credential")]
[Alias("RunAs")]
[System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty,

[Parameter(ParameterSetName="Prompt")]
[switch]$PromptForCredential

)

Begin {
    Write-Verbose "Starting: $($MyInvocation.Mycommand)"  

    #disable PowerShell profiles in new ISE tabs which speeds up the process
    #thanks for Tobias Weltner for the guidance on this
    Write-Verbose "temporarily disabling PowerShell profiles in new tabs"
    $type = ([Microsoft.Windows.PowerShell.Gui.Internal.MainWindow].Assembly.GetTypes()).Where({ $_.Name -eq 'PSGInternalHost' })
    $currentField = $type.GetField('current', 'NonPublic,Static')
    $noprofileField = $type.GetField('noProfile', 'NonPublic,Instance')
    $pshost = $currentField.GetValue($type)
    $noprofileField.SetValue($pshost,$True)
    
    #dynamically build the Enter-PSSession Commmand
    $cmdstring = "Enter-PSSession -computername {0}"

    if ($credential.username -AND $pscmdlet.ParameterSetName -eq "credential") {
        #export credential to a temporary local file because each new tab is a new session
        $credPath = [System.IO.Path]::GetTempFileName()
        $credential | Export-Clixml -Path $credpath
        Write-Verbose "Exporting credential for $($credential.username) to $credpath"
        $cmdstring+= " -credential (Import-Clixml -path $credpath)"  
    }

} #begin

Process {
foreach ($computer in $computername) {
    
    Write-Verbose "Processing: $computer"
    #insert each computername
    $cmd = $cmdstring -f $computer
    
    $newtab = $psise.powershelltabs.Add()
    #change the tab name
    $newTab.DisplayName = $Computer.ToUpper()
    
    #wait for new tab to be created
    Do {
      Start-Sleep -Milliseconds 10
    } until ($newTab.CanInvoke)
    

    if ($PromptForCredential) {
        Write-Verbose "Prompting for credential"
        $NewTab.invoke("`$cred = Get-Credential -message 'Enter a credential for $($newtab.DisplayName)' -username $env:userdomain\$env:username")
         Do {
          Start-Sleep -Milliseconds 10
        } until ($newTab.CanInvoke)
    
        $cmd+= ' -credential $cred'
        
    } #if prompt for credential

    Write-Verbose "Executing: $cmd"
    $newtab.Invoke($cmd)
    
    Do {
      #wait until ready
      start-Sleep -Milliseconds 10
    } until ($newTab.CanInvoke)
    
    #run some initial commands in each remote session
    "Set-Location -path 'C:\'","Clear-Host","WhoAmI",'$PSVersionTable' | foreach {
        Write-Verbose "[$($newTab.Displayname)] Invoking $_"
        $newTab.Invoke($_)
        #wait for command to complete
        Do {
          Start-Sleep -Milliseconds 10
        } until ($newTab.CanInvoke)
    
    } #foreach command
 } #foreach computer
} #process

End {

    #re-enable PowerShell profiles
    Write-Verbose "Re-enabling PowerShell ISE profiles"
    $noprofileField.SetValue($pshost,$False)

   #delete credential file if it exists
    if (Test-Path -path $credPath) {
        Write-Verbose "Deleting $credpath"
        del $credPath -Force
    }

    Write-Verbose "Ending: $($MyInvocation.Mycommand)"
 
} #end

} #end function 

#define an alias
Set-Alias -Name nrt -Value New-ISERemoteTab
