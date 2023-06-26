<#
This is an example configuration file

By default, it is enough to have a single one of them,
however if you have enough configuration settings to justify having multiple copies of it,
feel totally free to split them into multiple files.
#>

<#
# Example Configuration
Set-PSFConfig -Module 'TelemetryHelper' -Name 'Example.Setting' -Value 10 -Initialize -Validation 'integer' -Handler { } -Description "Example configuration setting. Your module can then use the setting using 'Get-PSFConfigValue'"
#>

Set-PSFConfig -Module 'TelemetryHelper' -Name 'Import.DoDotSource' -Value $true -Initialize -Validation 'bool' -Description "Whether the module files should be dotsourced on import. By default, the files of this module are read as string value and invoked, which is faster but worse on debugging."
Set-PSFConfig -Module 'TelemetryHelper' -Name 'Import.IndividualFiles' -Value $true -Initialize -Validation 'bool' -Description "Whether the module files should be imported individually. During the module build, all module code is compiled into few files, which are imported instead by default. Loading the compiled versions is faster, using the individual files is easier for debugging and testing out adjustments."

# Module-specific settings
Set-PSFConfig -Module 'TelemetryHelper' -Name 'TelemetryStore' -Value @{}

# Module telemetry settings
Set-PSFConfig -Module 'TelemetryHelper' -Name 'TelemetryHelper.ApplicationInsights.ConnectionString' -Value $null -Initialize -Validation string -Description 'Your ApplicationInsights connection string' -Hidden
Set-PSFConfig -Module 'TelemetryHelper' -Name 'TelemetryHelper.OptInVariable' -Value 'TelemetryHelperTelemetryOptIn' -Initialize -Validation string -Description 'The name of the environment variable used to indicate that telemetry should be sent'
Set-PSFConfig -Module 'TelemetryHelper' -Name 'TelemetryHelper.OptIn' -Value $false -Initialize -Validation bool -Description 'Whether user opts into telemetry or not'
Set-PSFConfig -Module 'TelemetryHelper' -Name 'TelemetryHelper.RemovePII' -VAlue $true -Initialize -Validation bool -Description "Whether information like the computer name should be stripped from the data that is sent"
