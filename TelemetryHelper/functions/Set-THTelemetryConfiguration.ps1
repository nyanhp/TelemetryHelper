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
.PARAMETER CallingModule
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

        [Alias('ModuleName')]
        [Parameter()]
        [string]
        $CallingModule = (Get-CallingModule),

        [Parameter()]
        [switch]
        $PassThru
    )

    if ($PSCmdlet.ShouldProcess("$CallingModule telemetry", "ACTIVATE!"))
    {
        if ($null -eq (Get-PSFConfigValue -FullName TelemetryHelper.TelemetryStore)[$CallingModule])
        {
            Initialize-THTelemetry -ModuleName $CallingModule
        }

        # Set object properties
        (Get-PSFConfigValue -FullName TelemetryHelper.TelemetryStore)[$CallingModule].StripPii = $StripPersonallyIdentifiableInformation

        # Register module-specific info
        Set-PSFConfig -Module 'TelemetryHelper' -Name "$($CallingModule).OptInVariable" -Value $OptInVariableName -Description 'The name of the environment variable used to indicate that telemetry should be sent' -PassThru | Register-PSFConfig
        Set-PSFConfig -Module 'TelemetryHelper' -Name "$($CallingModule).OptIn" -Value $UserOptIn -Validation bool -Description 'Whether user opts into telemetry or not' -PassThru | Register-PSFConfig
        Set-PSFConfig -Module 'TelemetryHelper' -Name "$($CallingModule).RemovePII" -Value $StripPersonallyIdentifiableInformation -Validation bool -Description "Whether information like the computer name should be stripped from the data that is sent" -PassThru | Register-PSFConfig


        if ($PassThru)
        {
            (Get-PSFConfigValue -FullName TelemetryHelper.TelemetryStore)[$CallingModule]
        }
    }
}
