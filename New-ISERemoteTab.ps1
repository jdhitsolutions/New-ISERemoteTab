#requires -version 4.0
#requires -module ISE

Function New-ISERemoteTab {

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
