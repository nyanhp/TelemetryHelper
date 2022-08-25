@{
    # Script module or binary module file associated with this manifest
    RootModule           = 'TelemetryHelper.psm1'
	
    # Version number of this module.
    ModuleVersion        = '1.4.0'
	
    CompatiblePSEditions = 'Core', 'Desktop'
	
    # ID used to uniquely identify this module
    GUID                 = 'b4ebcde7-2c74-4d86-b43a-8736ae2617f1'
	
    # Author of this module
    Author               = 'Jan-Hendrik Peters'
	
    # Company or vendor of this module
    CompanyName          = 'Jan-Hendrik Peters'
	
    # Copyright statement for this module
    Copyright            = 'Copyright (c) 2019 Jan-Hendrik Peters'
	
    # Description of the functionality provided by this module
    Description          = 'This module helps you integrate telemetry with ApplicationInsights into your own PowerShell module'
	
    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion    = '5.1'
	
    # Modules that must be imported into the global environment prior to importing
    # this module
    RequiredModules      = @(
        @{ ModuleName='PSFramework'; ModuleVersion='1.7.237' }
    )
	
    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies   = @('bin\net452\TelemetryHelper.dll')
	
    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @('xml\TelemetryHelper.Types.ps1xml')
	
    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @('xml\TelemetryHelper.Format.ps1xml')
	
    # Functions to export from this module
    FunctionsToExport    = @(
        'Add-THAppInsightsInstrumentationKey'
        'Initialize-THTelemetry'
        'Get-THTelemetryConfiguration'
        'Send-THEvent'
        'Send-THTrace'
        'Send-THMetric'
        'Send-THException'
        'Set-THTelemetryConfiguration'
    )
	
    # Cmdlets to export from this module
    CmdletsToExport      = ''
	
    # Variables to export from this module
    VariablesToExport    = ''
	
    # Aliases to export from this module
    AliasesToExport      = ''
	
    # List of all modules packaged with this module
    ModuleList           = @()
	
    # List of all files packaged with this module
    FileList             = @()
	
    # Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{
		
        #Support for PowerShellGet galleries.
        PSData = @{
			
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Telemetry', 'ApplicationInsights')
			
            # A URL to the license for this module.
            # LicenseUri = ''
			
            # A URL to the main website for this project.
            # ProjectUri = ''
			
            # A URL to an icon representing this module.
            # IconUri = ''
			
            # ReleaseNotes of this module
            # ReleaseNotes = ''
			
        } # End of PSData hashtable
		
    } # End of PrivateData hashtable
}