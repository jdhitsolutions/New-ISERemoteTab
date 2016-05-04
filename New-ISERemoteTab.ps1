#requires -version 4.0
#requires -module ISE

Function New-ISERemoteTab {

<#
.SYNOPSIS
Create remote tabs in the PowerShell ISE.

.DESCRIPTION
This command will create one or more remote tabs in the PowerShell ISE. You could use this to programmatically to open multiple remote tabs.

The default behavior is to open tabs with your current credentials. But you can specify a single credential for all remote connections, or prompt for a credential for each connection. You might need this if some of the machines require different credentials.

The command also supports additional parameters from Enter-PSSession. Be aware that if you specify multiple machines and one of these parameters, such as UseSSL, that parameter will apply to all remote connections.

.PARAMETER Computername
The name of the server to connect. This parameter has an alias of CN.

.PARAMETER Credential
A PSCredential or user name to be used for all specified computers. Note that if you specify a credential, it will temporarily be exported to disk so that each new PowerShell tab can re-use it. The file is deleted at the end of the command.

This parameter has aliases of RunAs,Cred,and C.

.PARAMETER PromptforCredential
Use this parameter if you want to prompt for a credential for each connection. No credential information is written to disk.

.PARAMETER Authentication
Specifies the mechanism that is used to authenticate the user's credentials. Valid values are "Default", "Basic", "Credssp", "Digest", "Kerberos", "Negotiate", and "NegotiateWithImplicitCredential". The default value is "Default".

This parameter has aliases of Am and Auth.

.PARAMETER CertificateThumbprint
Specifies the digital public key certificate (X509) of a user account that has permission to perform this action. Enter the certificate thumbprint of the certificate.

This parameter has an alias of thumb.

.PARAMETER ConfigurationName
Specifies the session configuration that is used for the interactive session.

.PARAMETER Port
Specifies the network port on the remote computer used for this command. To connect to a remote computer, the remote computer must be listening on the port that the connection uses. The default ports are 5985 (the WinRM port for HTTP) and 5986 (the WinRM port for HTTPS).

.PARAMETER SessionOption
Sets advanced options for the session. Enter a SessionOption object, such as one that you create by using the New-PSSessionOption cmdlet, or a hash table in which the keys are session option names and the values are session option values.

.PARAMETER UseSSL
Uses the Secure Sockets Layer (SSL) protocol to establish a connection to the remote computer. By default, SSL is not used.

.PARAMETER Profile
The path to a local file with PowerShell commands to be executed remotely upon connection. Each command in the script must be on a single line. This is a way to run a profile script in the remote session. Here is an profile script example:

# Sample remote profile script
cd c:\
cls
Get-WMIObject Win32_OperatingSystem | Select @{Name="OS";Expression = {$_.Caption}},@{Name="PSVersion";Expression = {$PSVersionTable.PSVersion}}

Do not use any block comments in your remote profile script. See examples for additional help.

.EXAMPLE
PS C:\> New-ISERemoteTab chi-dc01
Create a new remote tab for computer CHI-DC01 with default settings.

.EXAMPLE
PS C:\> Get-Content c:\work\chi.txt | New-ISERemoteTab -credential mydomain\administrator
Create remote tabs for each computer in the list using alternate credentials. This is also the type of command that you could put in your ISE profile script to autocreate remote tabs.

.EXAMPLE
PS C:\> New-ISERemoteTab dmz-srv01,dmz,srv02,dmz,srv03 -prompt
Create remote tabs for each computer and prompt for a unique set of credentials for each.

.EXAMPLE
PS C:\> New-ISERemoteTab dmz-eft01 -Credential domain\administrator -Authentication CredSSP
Create a remote tab for dmz-eft01 with alternate credentials using CredSSP for authentication.

.EXAMPLE
PS C:\> New-ISERemoteTab dmz-eft01 -ConfigurationName Microsoft.Powershell32
Create a remote tab for dmz-eft01 using the 32-bit configuration settings. The display name for this tab would be "dmz-eft01 Microsoft.Powershell32".

.EXAMPLE
PS C:\> New-ISERemoteTab chi-core01,chi-core02 -profile c:\scripts\remote.ps1
Create remote tabs for computers CHI-CORE01 and CHI-CORE02. Upon connection remotely run the commands in the local file c:\scripts\remote.ps1.

.EXAMPLE
PS C:\> import-csv s:\computers.csv | where { test-wsman $_.computername -ErrorAction SilentlyContinue} | Out-GridView -Title "Select computers" -OutputMode Multiple | New-ISERemoteTab -Profile S:\RemoteProfile.ps1

Import a list of computers and filter those that respond to Test-WSMan. This list is then piped to Out-Gridview so that you can select one or more computers to connect to using a remote profile script and current credentials.
.NOTES
Last Updated: 30 March 2016
Author      : Jeff Hicks (http://twitter.com/JeffHicks)
Version     : 1.3.1

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************

.LINK
Enter-PSSession
Test-WSMan

.INPUTS
[string]

.OUTPUTS
none
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
[Alias("RunAs","cred","c")]
[ValidateNotNullorEmpty()]
[System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty,

[Parameter(ParameterSetName="Prompt")]
[switch]$PromptForCredential,

[ValidateSet("Basic","CredSSP", "Default", "Digest", "Kerberos", "Negotiate", "NegotiateWithImplicitCredential","None")]
[Alias('auth','am')]
[string]$Authentication,

[ValidateNotNullOrEmpty()]
[Alias("thumb")]
[string]$CertificateThumbprint,

[ValidateNotNullOrEmpty()]
[string]$ConfigurationName,

[ValidateNotNullOrEmpty()]
[ValidateRange(1, 2147483647)]
[int32]$Port,

[System.Management.Automation.Remoting.PSSessionOption]$SessionOption,

[Switch]$UseSSL,

[ValidateScript({
if (Test-Path $_) {
   $True
}
else {
   Throw "Cannot validate path $_"
}
})]
[string]$Profile

)

Begin {
    Write-Verbose "Starting: $($MyInvocation.Mycommand)"  
    Write-Verbose "Using parameter Set: $($pscmdlet.ParameterSetName)"
    Write-Verbose "PSBoundParameters"
    Write-Verbose ($PSBoundParameters | Out-String)

    #disable PowerShell profiles in new ISE tabs which speeds up the process
    #thanks for Tobias Weltner for the guidance on this.
    Write-Verbose "Temporarily disabling PowerShell profiles in new tabs"
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
        Write-Verbose "Exporting credential for $($credential.username) to $credpath"
        $credential | Export-Clixml -Path $credpath
        $cmdstring+= " -credential (Import-Clixml -path $credpath)"  
    }

    #export session option to cliXML so that it can be read into the scriptblock
    if ($SessionOption)  {
        $optPath = [System.IO.Path]::GetTempFileName()
        Write-Verbose "Exporting session options to $optPath"
        $sessionOption | Export-Clixml -Path $optPath
        $cmdstring += " -SessionOption (Import-cliXML -path $optPath)"
      }
             
    if ($Authentication)        {$cmdstring += " -authentication $Authentication"}
    if ($CertificateThumbprint) {$cmdstring += " -CertificateThumbprint $CertificateThumbprint"}
    if ($ConfigurationName)     {$cmdstring += " -configurationname $ConfigurationName"}
    if ($Port)                  {$cmdstring += " -Port $Port"}
    if ($UseSSL)                {$cmdstring += " -UseSSL"}

} #begin

Process {

    Write-Verbose "PSBoundParameters in Process"
    Write-Verbose ($PSBoundParameters | Out-String)

    #copy bound parameters to a new hashtable
    $testParams = $PSBoundParameters
    
    #remove invalid parameters
    if ($profile) {
        #remove profile parameter since Test-WSMan won't recognize it
        $testParams.remove("profile") | Out-Null
    }
    if ($SessionOption) {
        $testParams.remove("sessionoption") | Out-Null
    }
    if ($PromptForCredential) {
        $testParams.remove("promptforCredential") | Out-Null
    }

foreach ($computer in $computername) {
    
    Write-Verbose "Processing: $computer"
    #insert each computername
    $cmd = $cmdstring -f $computer
    
    #insert the current computer nto the parameters for Test-WSMan
    $testParams.Computername = $computer

    #remove configurationname from Test-WSMan
    $testparams.Remove("ConfigurationName") | Out-Null

    #Verify Computer is accessible with Test-WSMan
    Try {

        Test-WSMan @testParams -ErrorAction Stop | Out-Null

        $newtab = $psise.powershelltabs.Add()
        #change the tab name
        $newTab.DisplayName = $Computer.ToUpper()
        if ($ConfigurationName){$newtab.DisplayName += " $ConfigurationName"}
    
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
        if ($profile) {
            Write-Verbose "Launching commands from $profile"
            #get contents of profile script where there are words but no comments
            Get-Content $profile | where {$_ -match "\w+" -AND $_ -notmatch "#"} | 
            foreach {
                Write-Verbose "[$($newTab.Displayname)] Invoking $_"
                $newTab.Invoke($_)
                #wait for command to complete
                Do {
                  Start-Sleep -Milliseconds 10
                } until ($newTab.CanInvoke)
    
            } #foreach command
        } #if profile script
        
    } #Try
    Catch {
        Write-Warning "Can't create remote tab to $computer. $($_.exception.Message)."
    }
 } #foreach computer

} #process

End {

    #re-enable PowerShell profiles
    Write-Verbose "Re-enabling PowerShell ISE profiles"
    $noprofileField.SetValue($pshost,$False)

   #delete credential file if it exists
    if ($credpath -AND (Test-Path -path $credPath)) {
        Write-Verbose "Deleting $credpath"
        del $credPath -Force
    }

    #delete session option file if it exists
    if ($optpath -AND (Test-Path -path $optPath)) {
        Write-Verbose "Deleting $optpath"
        del $optPath -Force
    }
    Write-Verbose "Ending: $($MyInvocation.Mycommand)"
 
} #end

} #end function 

#define an alias
Set-Alias -Name nrt -Value New-ISERemoteTab
