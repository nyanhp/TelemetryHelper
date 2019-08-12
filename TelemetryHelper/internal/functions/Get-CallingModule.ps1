<#
.SYNOPSIS
    Internal function to determine the module name
.DESCRIPTION
    Internal function to determine the module name of the calling cmdlet
.EXAMPLE
    Get-CallingModule

    Returns either null or the module name
#>
function Get-CallingModule
{
    [OutputType([string])]
    [CmdletBinding()]
    param ( )
    
    $moduleName = foreach ($stackEntry in (Get-PSCallStack))
    {
        if ($stackEntry.InvocationInfo.MyCommand.ModuleName -eq 'TelemetryHelper') { continue }

        if ($null -ne $stackEntry.InvocationInfo.MyCommand.ModuleName)
        {
            $stackEntry.InvocationInfo.MyCommand.ModuleName
            break
        }
    }
    
    if ($moduleName)
    {
        Write-PSFMessage -Message "Determined module name $moduleName"
        return $moduleName
    }

    Stop-PSFFunction -Message "Unable to determine module name. Telemetry collection will not work properly."
}
