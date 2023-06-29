---
external help file: ISERemoteTab-help.xml
schema: 2.0.0
---

# New-ISERemoteForm

## SYNOPSIS

Create a WPF front-end for New-ISERemoteTab.

## SYNTAX

```yaml
New-ISERemoteForm [-CommonParameters]
```

## DESCRIPTION

Run this command to create a WPF form to create one or more remote ISE tabs using the New-ISERemoteTab function. The form should handle everything except additional PSSessionOptions. If you require that level of control, you will need to use New-ISEREmoteTab. If you check the box for "Use VMName", incompatible form controls will be disabled. You will need to manually close the form.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\> New-ISERemoteForm
```

## PARAMETERS

### None

## INPUTS

### None

## OUTPUTS

### None

## NOTES

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[New-ISERemoteTab](New-ISRemoteTab.md)
