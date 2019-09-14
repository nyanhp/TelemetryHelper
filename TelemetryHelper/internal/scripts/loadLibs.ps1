$typeLoaded = try
{
    [de.janhendrikpeters.TelemetryHelper]
    Write-PSFMessage -Message 'Type imported'
}
catch
{
    Write-PSFMessage -Message 'Type not imported yet'
    $false
}

if (-not $typeLoaded -and $PSVersionTable.PSEdition -eq 'Core')
{
    Write-PSFMessage -Message "Loading core type from $($script:ModuleRoot)\bin\core\TelemetryHelper.dll"
    Add-Type -Path "$($script:ModuleRoot)\bin\core\TelemetryHelper.dll"
}

if (-not $typeLoaded -and $PSVersionTable.PSEdition -eq 'Desktop')
{
    Write-PSFMessage -Message "Loading full type from $($script:ModuleRoot)\bin\core\TelemetryHelper.dll"
    Add-Type -Path "$($script:ModuleRoot)\bin\full\TelemetryHelper.dll"
}