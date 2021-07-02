---
external help file: ISERemoteTab-help.xml
Module Name: ISERemoteTab
schema: 2.0.0
---

# New-ISERemoteTab

## SYNOPSIS

Create remote tabs in the PowerShell ISE.

## SYNTAX

### ComputerCredential (Default)

```yaml
New-ISERemoteTab -Computername <String[]> [-Credential <PSCredential>] [-Authentication <String>]  [-CertificateThumbprint <String>] [-ConfigurationName <String>] [-Port <Int32>]  [-SessionOption <PSSessionOption>] [-UseSSL] [-ProfileScript <String>] [<CommonParameters>]
```

### ComputerPrompt

```yaml
New-ISERemoteTab [-Computername <String[]>] [-PromptForCredential] [-Authentication <String>]  [-CertificateThumbprint <String>] [-ConfigurationName <String>] [-Port <Int32>] [-SessionOption <PSSessionOption>] [-UseSSL] [-ProfileScript <String>] [<CommonParameters>]
```

### VMPrompt

```yaml
New-ISERemoteTab [-VMName <String>] [-PromptForCredential] [-ConfigurationName <String>]  [-ProfileScript <String>] [<CommonParameters>]
```

### VMCredential

```yaml
New-ISERemoteTab [-VMName <String>] [-Credential <PSCredential>] [-ConfigurationName <String>] [-ProfileScript <String>] [<CommonParameters>]
```

## DESCRIPTION

This command will create one or more remote tabs in the PowerShell ISE. You could use this to programmatically to open multiple remote tabs. The default behavior is to open tabs with your current credentials. But you can specify a single credential for all remote connections, or prompt for a credential for each connection. You might need this if some of the machines require different credentials.

The command also supports additional parameters from Enter-PSSession.

Be aware that if you specify multiple machines and one of these parameters, such as UseSSL, that parameter will apply to all remote connections.

You can also specify a VMName instead of a computername to use PowerShell Direct. This is the equivalent of running Enter-PSSession with the VmName parameter. You will need to specify a credential when using this option.

Important: You must be in the PowerShell ISE to run this command.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\> New-ISERemoteTab chi-dc01
```

Create a new remote tab for computer CHI-DC01 with default settings.

### EXAMPLE 2

```powershell
PS C:\> Get-Content c:\work\chi.txt | New-ISERemoteTab -credential mydomain\administrator
```

Create remote tabs for each computer in the list using alternate credentials.
This is also the type of command that you could put in your ISE profile script to auto-create remote tabs.

### EXAMPLE 3

```powershell
PS C:\> New-ISERemoteTab dmz-srv01,dmz-srv02,dmz-srv03 -prompt
```

Create remote tabs for each computer and prompt for a unique set of credentials for each.

### EXAMPLE 4

```powershell
PS C:\> New-ISERemoteTab dmz-srv01 -Credential domain\administrator -Authentication CredSSP
```

Create a remote tab for dmz-srv01 with alternate credentials using CredSSP for authentication.

### EXAMPLE 5

```powershell
PS C:\> New-ISERemoteTab -vmname srv01 -ConfigurationName PowerShell.7 -credential $admin
```

Create a remote tab for SRV01 virtual machine using the PowerShell.7 session configuration.

### EXAMPLE 6

```powershell
PS C:\> New-ISERemoteTab chi-core01,chi-core02 -profile c:\scripts\remote.ps1
```

Create remote tabs for computers CHI-CORE01 and CHI-CORE02.
Upon connection remotely run the commands in the local file c:\scripts\remote.ps1.

### EXAMPLE 7

```powershell
PS C:\> import-csv s:\computers.csv | where { test-wsman $_.computername -ErrorAction SilentlyContinue} | Out-GridView -Title "Select computers" -OutputMode Multiple | New-ISERemoteTab -Profile S:\RemoteProfile.ps1
```

Import a list of computers and filter those that respond to Test-WSMan.
This list is then piped to Out-Gridview so that you can select one or more computers to connect to using a remote profile script and current credentials.

## PARAMETERS

### -Authentication

Specifies the mechanism that is used to authenticate the user's credentials.
Valid values are "Default", "Basic", "Credssp", "Digest", "Kerberos", "Negotiate", and "NegotiateWithImplicitCredential".

```yaml
Type: String
Parameter Sets: ComputerCredential, ComputerPrompt
Aliases: auth, am
Accepted values: Basic, CredSSP, Default, Digest, Kerberos, Negotiate, NegotiateWithImplicitCredential, None

Required: False
Position: Named
Default value: none
Accept pipeline input: False
Accept wildcard characters: False
```

### -CertificateThumbprint

Specifies the digital public key certificate \(X509\) of a user account that has permission to perform this action.
Enter the certificate thumbprint of the certificate.

```yaml
Type: String
Parameter Sets: ComputerCredential, ComputerPrompt
Aliases: thumb

Required: False
Position: Named
Default value: none
Accept pipeline input: False
Accept wildcard characters: False
```

### -Computername

The name of the server to connect.
This parameter has an alias of CN.

```yaml
Type: String[]
Parameter Sets: ComputerCredential
Aliases: cn

Required: True
Position: Named
Default value: none
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

```yaml
Type: String[]
Parameter Sets: ComputerPrompt
Aliases: cn

Required: False
Position: Named
Default value: none
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ConfigurationName

Specifies the session configuration that is used for the interactive session.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: none
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential

A PSCredential or user name to be used for all specified computers.
Note that if you specify a credential, it will temporarily be exported to disk so that each new PowerShell tab can re-use it.
The file is deleted at the end of the command.

```yaml
Type: PSCredential
Parameter Sets: ComputerCredential, VMCredential
Aliases: RunAs

Required: False
Position: Named
Default value: [System.Management.Automation.PSCredential]::Empty
Accept pipeline input: False
Accept wildcard characters: False
```

### -Port

Specifies the network port on the remote computer used for this command.
To connect to a remote computer, the remote computer must be listening on the port that the connection uses.
The default ports are 5985 \(the WinRM port for HTTP\) and 5986 \(the WinRM port for HTTPS\).

```yaml
Type: Int32
Parameter Sets: ComputerCredential, ComputerPrompt
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileScript

Specify the path to a profile script file.

hNormally, you do not have a traditional PowerShell profile script when you enter a remote PSSession. But you have the option to specify a profile script that will be executed in the remote session in place of a regular profile script. The form will look in your current session for a variable called ISERemoteProfile which is the path to a ps1 file with your remote profile script.

You can set this in your PowerShell ISE Profile script or you can use the Save script setting checkbox to store the current file in the variable.

Note that this variable is only for the length of your PowerShell session and does NOT update your ISE profile.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PromptForCredential

Use this parameter if you want to prompt for a credential for each connection.
No credential information is written to disk.

```yaml
Type: SwitchParameter
Parameter Sets: ComputerPrompt, VMPrompt
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SessionOption

Sets advanced options for the session.
Enter a SessionOption object, such as one that you create by using the New-PSSessionOption cmdlet, or a hash table in which the keys are session option names and the values are session option values.

```yaml
Type: PSSessionOption
Parameter Sets: ComputerCredential, ComputerPrompt
Aliases:

Required: False
Position: Named
Default value: none
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseSSL

Uses the Secure Sockets Layer \(SSL\) protocol to establish a connection to the remote computer.
By default, SSL is not used.

```yaml
Type: SwitchParameter
Parameter Sets: ComputerCredential, ComputerPrompt
Aliases:

Required: False
Position: Named
Default value: false
Accept pipeline input: False
Accept wildcard characters: False
```

### -VMName

Specify the name of Nyper-V virtual machines that you will connect to using PowerShell Direct.

```yaml
Type: String
Parameter Sets: VMPrompt, VMCredential
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [string]

## OUTPUTS

### none

## NOTES

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Enter-PSSession]()

[Test-WSMan]()

[New-ISERemoteForm](New-ISERemoteForm.md)
