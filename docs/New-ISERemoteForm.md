---
external help file: ISERemoteTab-help.xml
schema: 2.0.0
---

# New-ISERemoteForm
## SYNOPSIS
Create a WPF front end for New-ISERemoteTab.

## SYNTAX

```
New-ISERemoteForm [-CommonParameters]
```

## DESCRIPTION
Run this command to create a WPF form to create one or more remote ISE tabs using the New-ISERemoteTab function. The form should handle everything except additional PSSessionOptions.

The form will look in your current session for a variable called ISERemoteProfile which should be the path to a ps1 file with your remote profile script. 
You can set this in your PowerShell ISE Profile script or you can use the Save script setting checkbox to store the current file in the variable.
Note that this variable is only for the length of your PowerShell session.
This does NOT update your ISE profile.

In your PowerShell ISE profile script you can add lines like this to create a menu shortcut and define a default remote profile script:

    Import-Module ISERemoteTab
    $Display = "New Remote ISE Tab"
    $Action = {New-ISEREmoteForm}
    $Shortcut = "Ctrl+Shift+T"
    $ISERemoteProfile = "C:\Scripts\RemoteProfile.ps1"
    $psise.CurrentPowerShellTab.AddOnsMenu.Submenus.Add($Display,$Action,$shortcut) | Out-Null

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
PS C:\> New-ISERemoteForm
```

## PARAMETERS
### None
## INPUTS
### None
## OUTPUTS
### None
## NOTES
NAME        :  New-ISERemoteTabForm  
LAST UPDATED:  July 10, 2016  
AUTHOR      :  Jeff Hicks \(@JeffHicks\)

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

****************************************************************
DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED 
THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK. 
IF YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, 
DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING. 
****************************************************************

## RELATED LINKS
[New-ISERemoteTab]()


