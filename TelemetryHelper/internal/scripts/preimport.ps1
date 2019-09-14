# Add all things you want to run before importing the main code

# Load libs
$typeLoaded = try
{
    [de.janhendrikpeters.TelemetryHelper]   
}
catch
{
    $false
}

if (-not $typeLoaded -and $PSVersionTable.PSEdition -eq 'Core')
{
    Add-Type -Path "$($script:ModuleRoot)\bin\core\TelemetryHelper.dll"
}

if (-not $typeLoaded -and $PSVersionTable.PSEdition -eq 'Desktop')
{
    Add-Type -Path "$($script:ModuleRoot)\bin\full\TelemetryHelper.dll"
}

# Load the strings used in messages
. Import-ModuleFile -Path "$($script:ModuleRoot)\internal\scripts\strings.ps1"