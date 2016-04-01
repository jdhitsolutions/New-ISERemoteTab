#requires -version 4.0

. $psScriptroot\New-ISERemoteTab.ps1
. $psScriptroot\New-ISERemoteTabForm.ps1

Export-ModuleMember -Function New-ISERemoteTab,New-ISERemoteForm -Alias nrt