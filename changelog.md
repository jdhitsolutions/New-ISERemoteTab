# Changelog for ISERemoteTab

## v2.1.0

+ Help updates.
+ Modified `-ProfileScript` parameter in `New-ISERemoteTab` to use `$ISEREmoteProfile` as the default. This is a continuation of [Issue #10](https://github.com/jdhitsolutions/New-ISERemoteTab/issues/10).
+ Updated `README.md`.

## v2.0.0

+ Updated License.
+ Modified `New-ISERemoteTab` to better support profiles so that prompt functions can be defined. [Issue #10](https://github.com/jdhitsolutions/New-ISERemoteTab/issues/10).
+ Changed the `-Profile` parameter in `New-ISERemoteTab` to `-ProfileScript` to avoid potential conflicts with the automatic `$Profile` variable. This also required an update to `New-ISERemoteTabForm`.
+ Updated commands to support PowerShell Direct and connecting to a Hyper-V virtual machine. [Issue #9](https://github.com/jdhitsolutions/New-ISERemoteTab/issues/9).
+ Added the `nrtf` alias for `New-ISERemoteTabForm`.
+ Removed the `cred` and `c` aliases for the `Credential` parameter in `New-ISERemoteTab`.
+ Removed code in `New-ISERemoteTab` to run `Test-WSMan`.
+ Added better error handling in `New-ISERemoteTab`.
+ Removed user name in `New-ISERemoteTab` when prompting for credential.
+ Reorganized module layout.
+ Updated `SampleRemoteProfile.ps1` with a demo prompt function.
+ Increased the required Windows PowerShell version to 5.1.
+ Help updates.
+ Updated `README.md`.

## v1.5.1

+ Updated author name in manifest

## v1.5.0

+ Modified `New-ISERemoteTab` to clear the host if not using a profile.
+ Update markdown help documents
+ Updated XML help file
+ increased module version number
+ created external help files

## v1.4.2

+ Fixed [Issue #6](https://github.com/jdhitsolutions/New-ISERemoteTab/issues/6) setting default focus to computername text box.
+ Fixed [Issue #5](https://github.com/jdhitsolutions/New-ISERemoteTab/issues/5) to save remote profile script setting.
+ Trimmed extra spaces in labels and elements.
+ Minor tweaks to form layout.
+ Added version number to form
+ Fixed [Issue #7](https://github.com/jdhitsolutions/New-ISERemoteTab/issues/7) that prevented session options from working

## v1.4.1

+ Modified `New-ISERemoteTabForm` to include a browse button for the remote profile script. [Issue #4](https://github.com/jdhitsolutions/New-ISERemoteTab/issues/4)

## v1.4

+ Revised help
+ Fixed a bug with the Test-WSMan code that was including the ConfigurationName parameter.
+ Added `New-ISERemoteTabForm.ps1`
+ Renamed and converted to a module.
+ Published to the PowerShell Gallery

## v1.3

+ revised help documentation
+ Added code to run `Test-WSMan` prior to creating a remote tab to verify computer is accessible
+ Added parameter to specify a local script with commands to be executed remotely upon startup
+ Added #Requires statement to require the ISE module which should restrict this command to the ISE
+ Added parameter validation attributes from other session related cmdlets
+ Added None to validation set for Authentication

## v1.2

+ Added additional remoting parameters
+ Updated help
+ fixed minor bug testing for and deleting temporary credential file

## v1.1

+ Added MIT License

## v1.0

+ Initial release
