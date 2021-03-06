#
# Module manifest for module 'ISERemoteTab'
#

@{

    RootModule            = 'ISERemoteTab.psm1'
    CompatiblePSEditions  = "Desktop"
    ModuleVersion         = '2.1.0'
    GUID                  = '7c53d0c1-09bb-4150-a55e-d3147d940c7b'
    Author                = 'Jeff Hicks'
    CompanyName           = 'JDH Information Technology Solutions, Inc.'
    Copyright             = '(c) 2016-2021 JDH Information Technology Solutions, Inc. All rights reserved.'
    Description           = 'Functions to add new remote tabs in the PowerShell ISE with additional options like SSL.'
    PowerShellVersion     = '5.1'
    PowerShellHostName    = 'Windows PowerShell ISE Host'
    PowerShellHostVersion = '5.1'
    FunctionsToExport     = 'New-ISERemoteTab', 'New-ISERemoteForm'
    AliasesToExport       = 'nrt', 'nrtf'

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData           = @{

        PSData = @{

            Tags                       = "ISE", "Remoting","PSSession"
            LicenseUri                 = 'https://github.com/jdhitsolutions/New-ISERemoteTab/blob/master/license.txt'
            ProjectUri                 = 'https://github.com/jdhitsolutions/New-ISERemoteTab'
            # IconUri = ''
            ExternalModuleDependencies = "ISE"
            # ReleaseNotes = ''

        } # End of PSData hashtable

    } # End of PrivateData hashtable

}

