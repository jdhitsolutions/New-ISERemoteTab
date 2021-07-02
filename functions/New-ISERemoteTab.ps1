
Function New-ISERemoteTab {

    [cmdletbinding(DefaultParameterSetName = "ComputerCredential")]
    [alias("nrt")]
    [OutputType("None")]

    Param(
        [Parameter(
            Position = 0,
            Mandatory,
            HelpMessage = "Enter the name of a remote computer",
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = "ComputerCredential"
        )]
        [Parameter(ParameterSetName = "ComputerPrompt")]
        [ValidateNotNullorEmpty()]
        [Alias("cn")]
        [string[]]$Computername,

        [Parameter(
            ParameterSetName = "VMCredential",
            HelpMessage = "Specifies the name of a virtual machine. The connection will be made using PowerShell Direct."
        )]
        [Parameter(ParameterSetName = "VMPrompt")]
        [string]$VMName,

        [Parameter(ParameterSetName = "ComputerCredential")]
        [Parameter(ParameterSetName = "VMCredential")]
        [Alias("RunAs")]
        [ValidateNotNullorEmpty()]
        [PSCredential]$Credential,

        [Parameter(ParameterSetName = "ComputerPrompt")]
        [Parameter(ParameterSetName = "VMPrompt")]
        [switch]$PromptForCredential,

        [Parameter(ParameterSetName = "ComputerPrompt")]
        [Parameter(ParameterSetName = "ComputerCredential")]
        [ValidateSet("Basic", "CredSSP", "Default", "Digest", "Kerberos", "Negotiate", "NegotiateWithImplicitCredential", "None")]
        [Alias('auth', 'am')]
        [string]$Authentication,

        [Parameter(ParameterSetName = "ComputerPrompt")]
        [Parameter(ParameterSetName = "ComputerCredential")]
        [ValidateNotNullOrEmpty()]
        [Alias("thumb")]
        [string]$CertificateThumbprint,

        [ValidateNotNullOrEmpty()]
        [string]$ConfigurationName,

        [Parameter(ParameterSetName = "ComputerPrompt")]
        [Parameter(ParameterSetName = "ComputerCredential")]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1, 2147483647)]
        [int32]$Port,

        [Parameter(ParameterSetName = "ComputerPrompt")]
        [Parameter(ParameterSetName = "ComputerCredential")]
        [System.Management.Automation.Remoting.PSSessionOption]$SessionOption,

        [Parameter(ParameterSetName = "ComputerPrompt")]
        [Parameter(ParameterSetName = "ComputerCredential")]
        [Switch]$UseSSL,

        [ValidateScript( {
                if (Test-Path $_) {
                    $True
                }
                else {
                    Throw "Cannot validate path $_"
                }
            })]
        [string]$ProfileScript
    )

    Begin {
        Write-Verbose "Starting: $($MyInvocation.Mycommand)"
        Write-Verbose "Using parameter Set: $($pscmdlet.ParameterSetName)"
        Write-Verbose "PSBoundParameters"
        Write-Verbose ($PSBoundParameters | Out-String)

        #disable PowerShell profiles in new ISE tabs which speeds up the process
        #thanks for Tobias Weltner for the guidance on this.
        Write-Verbose "Temporarily disabling PowerShell profiles in new ISE tabs"
        $type = ([Microsoft.Windows.PowerShell.Gui.Internal.MainWindow].Assembly.GetTypes()).Where( { $_.Name -eq 'PSGInternalHost' })
        $currentField = $type.GetField('current', 'NonPublic,Static')
        $noprofileField = $type.GetField('noProfile', 'NonPublic,Instance')
        $pshost = $currentField.GetValue($type)
        $noprofileField.SetValue($pshost, $True)

        #dynamically build the Enter-PSSession Commmand as a string so that it can
        #be invoked
        if ($pscmdlet.ParameterSetName -like "VM*") {
            $cmdstring = "Enter-PSSession -VMName {0}"
        }
        else {
            $cmdstring = "Enter-PSSession -computername {0}"
        }

        if ($credential.username -AND $pscmdlet.ParameterSetName -like "*credential") {
            #export credential to a temporary local file because each new tab is a new session
            $credPath = [System.IO.Path]::GetTempFileName()
            Write-Verbose "Exporting credential for $($credential.username) to $credpath"
            $credential | Export-Clixml -Path $credpath
            $cmdstring += " -credential (Import-Clixml -path $credpath)"
        }

        #export session option to cliXML so that it can be read into the scriptblock
        if ($SessionOption) {
            $optPath = [System.IO.Path]::GetTempFileName()
            Write-Verbose "Exporting session options to $optPath"
            $sessionOption | Export-Clixml -Path $optPath
            $cmdstring += " -SessionOption (Import-cliXML -path $optPath)"
        }

        if ($Authentication) { $cmdstring += " -authentication $Authentication" }
        if ($CertificateThumbprint) { $cmdstring += " -CertificateThumbprint $CertificateThumbprint" }
        if ($ConfigurationName) { $cmdstring += " -configurationname $ConfigurationName" }
        if ($Port) { $cmdstring += " -Port $Port" }
        if ($UseSSL) { $cmdstring += " -UseSSL" }

    } #begin

    Process {

        Write-Verbose "PSBoundParameters in Process"
        Write-Verbose ($PSBoundParameters | Out-String)

        #copy bound parameters to a new hashtable
        $testParams = $PSBoundParameters

        #remove invalid parameters
        if ($ProfileScript) {
            #remove profile parameter since Test-WSMan won't recognize it
            [void]$testParams.remove("profilescript")
        }
        if ($SessionOption) {
            [void]$testParams.remove("sessionoption")
        }
        if ($PromptForCredential) {
            [void]$testParams.remove("promptforCredential")
        }

        #Using the ForEach() method to eke out a little bit better performance
        #when processing multiple computer names
        if ($pscmdlet.ParameterSetName -like "VM*") {
            if ($Credential -OR $PromptForCredential) {
                $Remote = $VMName
            }
            else {
                Write-Warning "You must specify a credential when connecting to a VM."
                #bail out
                Return
            }
        }
        else {
            $remote = $Computername
        }
        ($Remote).Foreach( {
                $computer = $_.ToUpper()
                Write-Verbose "Processing: $computer"
                #insert each computername
                $cmd = $cmdstring -f $computer

                Try {
                    if ($psise.powershelltabs.displayname -contains $computer) {
                        Throw "A tab with computername [$($computer.toUpper())] is already open."
                    }
                    $newtab = $psise.powershelltabs.Add()
                    #change the tab name
                    $newTab.DisplayName = $Computer.ToUpper()
                    if ($ConfigurationName) {
                        $newtab.DisplayName += " $ConfigurationName"
                    }

                    #wait for new tab to be created
                    Do {
                        Start-Sleep -Milliseconds 10
                    } until ($newTab.CanInvoke)

                    if ($PromptForCredential) {
                        Write-Verbose "Prompting for credential"
                        $NewTab.invoke("`$cred = Get-Credential -message 'Enter a credential for $($newtab.DisplayName)'")
                        Do {
                            Start-Sleep -Milliseconds 10
                        } until ($newTab.CanInvoke)

                        $cmd += ' -credential $cred'

                    } #if prompt for credential

                    Write-Verbose "Executing: $cmd"
                    #need to verify the Enter-PSSession command was successful
                    $newtab.Invoke($cmd)
                    do {
                        Start-Sleep -Milliseconds 50
                    } Until ($newtab.CanInvoke)

                    Write-Verbose $newtab.ConsolePane.Text
                    if ($newtab.ConsolePane.Text -notmatch 'error') {
                        Do {
                            #wait until ready
                            Start-Sleep -Milliseconds 10
                        } until ($newTab.CanInvoke)

                        #run some initial commands in each remote session
                        if ($ProfileScript) {
                            Write-Verbose "Launching commands from $profile"
                            $profilecontent = Get-Content -Path $ProfileScript -Raw
                            $sb = [scriptblock]::Create($profilecontent)
                            [void]$newtab.Invoke($sb)

                        } #if profile script
                        else {
                            $newtab.Invoke("clear-host")
                        }
                    }
                    else {
                        Write-Warning $newtab.ConsolePane.text
                    }
                } #Try
                Catch {
                    Write-Warning "Can't create remote tab to $computer. $($_.exception.Message)."
                }
            }) #foreach computer

    } #process

    End {

        #re-enable PowerShell profiles
        Write-Verbose "Re-enabling PowerShell ISE profiles"
        $noprofileField.SetValue($pshost, $False)

        #delete credential file if it exists
        if ($credpath -AND (Test-Path -Path $credPath)) {
            Write-Verbose "Deleting $credpath"
            Remove-Item $credPath -Force
        }

        #delete session option file if it exists
        if ($optpath -AND (Test-Path -Path $optPath)) {
            Write-Verbose "Deleting $optpath"
            Remove-Item $optPath -Force
        }
        Write-Verbose "Ending: $($MyInvocation.Mycommand)"

    } #end

} #end function

