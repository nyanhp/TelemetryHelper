<#
.SYNOPSIS
    Configure the telemetry for a module
.DESCRIPTION
    Configure the telemetry for a module
.PARAMETER OptInVariableName
    The environment variable used to determine user-opt-in
.PARAMETER UserOptIn
    Override environment variable and opt-in
.PARAMETER StripPersonallyIdentifiableInformation
    Remove information such as the host name from telemetry
.PARAMETER ModuleName
    Auto-generated, used to select the proper configuration in case you have different modules
.PARAMETER PassThru
    Return the configuration object for further processing
.PARAMETER WhatIf
    Simulates the entire affair
.PARAMETER Confirm
    Requests confirmation that you really want to change the configuration
.EXAMPLE
    Set-THTelemetryConfiguration -UserOptIn $True

    Configures the basics and enables the user opt-in
#>
function Set-THTelemetryConfiguration
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Low")]
    param
    (
        [Parameter()]
        [string]
        $OptInVariableName = "$(Get-CallingModule)telemetryOptIn",

        [Parameter()]
        [bool]
        $UserOptIn = $false,

        [Parameter()]
        [bool]
        $StripPersonallyIdentifiableInformation = $true,

        [Parameter()]
        [string]
        $ModuleName = (Get-CallingModule),

        [Parameter()]
        [switch]
        $PassThru
    )

    if ($PSCmdlet.ShouldProcess("$ModuleName telemetry", "ACTIVATE!"))
    {
        if ($null -eq (Get-PSFConfigValue -FullName TelemetryHelper.TelemetryStore)[$ModuleName])
        {
            Initialize-THTelemetry -ModuleName $ModuleName
        }

        # Set object properties
        (Get-PSFConfigValue -FullName TelemetryHelper.TelemetryStore)[$ModuleName].StripPii = $StripPersonallyIdentifiableInformation

        # Register module-specific info
        Set-PSFConfig -Module 'TelemetryHelper' -Name "$($ModuleName).OptInVariable" -Value $OptInVariableName -Description 'The name of the environment variable used to indicate that telemetry should be sent' -PassThru | Register-PSFConfig
        Set-PSFConfig -Module 'TelemetryHelper' -Name "$($ModuleName).OptIn" -Value $false -Validation bool -Description 'Whether user opts into telemetry or not' -PassThru | Register-PSFConfig
        Set-PSFConfig -Module 'TelemetryHelper' -Name "$($ModuleName).RemovePII" -VAlue $true -Validation bool -Description "Whether information like the computer name should be stripped from the data that is sent" -PassThru | Register-PSFConfig


        if ($PassThru)
        {
            (Get-PSFConfigValue -FullName TelemetryHelper.TelemetryStore)[$ModuleName]
        }
    }
}
