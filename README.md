# New-ISERemoteTab
Function to add new remote tabs in the PowerShell ISE
This command will create one or more remote tabs in the PowerShell ISE. You could use this to programmatically to open multiple remote tabs.

The default behavior is to open tabs with your current credentials. But you can specify a single credential for all remote connections, or prompt for a credential for each connection. You might need this if some of the machines require different credentials.

The original function is described in greater detail at http://bit.ly/1lpMoNj.

This version of the module includes a function to generate a WPF form to enter remote tab information.
