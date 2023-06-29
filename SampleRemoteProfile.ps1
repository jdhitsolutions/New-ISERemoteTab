#this is a sample remote profile script

#how long has this session been running?
$initiated = Get-Date

Function prompt {
    #display the session runtime without the milliseconds
    $ts = ((Get-Date) - $initiated).ToString().split(".")[0]
  #  Write-Host ">$ts< " -ForegroundColor yellow -nonewline
    Write-Host "$ts <REMOTE>  "  -NoNewline -ForegroundColor Red -BackgroundColor Yellow
    "PS $($executionContext.SessionState.Path.CurrentLocation)--> "
}

Set-Location -path 'C:\'
Clear-Host

Write-Host "Connected to " -nonewline
Write-Host "$env:Computername" -ForegroundColor Red -BackgroundColor Yellow -NoNewline
Write-Host " as $($env:userdomain)\$($env:username)"

$PSVersionTable

