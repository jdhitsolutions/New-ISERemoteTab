# New-ISERemoteTab

The module includes a PowerShell function to add new remote tabs in the PowerShell ISE. The default behavior of adding remote tabs in the ISE is very basic and offers no flexibility like specifying an alternate port. This module was created to address those limitations.

This command will create one or more remote tabs in the PowerShell ISE. You could use this to programmatically to open multiple remote tabs.

    PS C:\> New-ISERemoteTab -Computername $c -Credential globomantics\administrator -Authentication Default

The default behavior is to open tabs with your current credentials. But you can specify a single credential for all remote connections, or prompt for a credential for each connection. You might need this if some of the machines require different credentials.

The original function is described in greater detail at http://bit.ly/1lpMoNj.

This version of the module includes a second function (New-ISERemoteForm) to generate a WPF form to enter remote tab information. 
You can enter a single computer or multiple names separated by commas.

![Alt Remote ISE Tab](http://jdhitsolutions.com/blog/wp-content/uploads/2016/05/remoteIsetab_thumb.png "Remote Tab Form")

In your PowerShell ISE profile script you can add lines like this to create a menu shortcut:

    Import-Module ISERemoteTab

    $Display = "New Remote ISE Tab"
    $Action = {New-ISEREmoteForm}
    $Shortcut = "Ctrl+Shift+T"
    $ISERemoteProfile = "C:\Scripts\RemoteProfile.ps1"

    $psise.CurrentPowerShellTab.AddOnsMenu.Submenus.Add($Display,$Action,$shortcut) | Out-Null

After importing the module into the ISE be sure to read help and examples.
