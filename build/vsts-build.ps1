<#
This script publishes the module to the gallery.
It expects as input an ApiKey authorized to publish the module.

Insert any build steps you may need to take before publishing it here.
#>
param (
	$ApiKey,
	
	$WorkingDirectory,
	
	$Repository = 'PSGallery',
	
	[switch]
	$IncludeGitHubRelease,
	
	[switch]
	$LocalRepo,
	
	[switch]
	$SkipPublish,
	
	[switch]
	$AutoVersion
)

#region Handle Working Directory Defaults
if (-not $WorkingDirectory)
{
	if ($env:RELEASE_PRIMARYARTIFACTSOURCEALIAS)
	{
		$WorkingDirectory = Join-Path -Path $env:SYSTEM_DEFAULTWORKINGDIRECTORY -ChildPath $env:RELEASE_PRIMARYARTIFACTSOURCEALIAS
	}
	else { $WorkingDirectory = $env:SYSTEM_DEFAULTWORKINGDIRECTORY }
}
if (-not $WorkingDirectory) { $WorkingDirectory = Split-Path $PSScriptRoot }
#endregion Handle Working Directory Defaults

# Prepare publish folder
Write-Host "Creating and populating publishing directory"
$publishDir = New-Item -Path $WorkingDirectory -Name publish -ItemType Directory -Force
Copy-Item -Path "$($WorkingDirectory)\TelemetryHelper" -Destination $publishDir.FullName -Recurse -Force
$theModule = Import-PowerShellDataFile -Path "$($publishDir.FullName)\TelemetryHelper\TelemetryHelper.psd1"

# Generate Help
$helpBase = Join-Path -Path $WorkingDirectory -ChildPath help
foreach ($language in (Get-ChildItem -Directory -Path $helpBase))
{
	New-ExternalHelp -Path $language.FullName -OutputPath "$($publishDir.FullName)\TelemetryHelper\$($language.BaseName)" -Force
}

#region Updating the Module Version
if ($AutoVersion)
{
	Write-Host  "Updating module version numbers."
	try { $remoteVersion = (Find-Module 'TelemetryHelper' -Repository $Repository -ErrorAction Stop -AllowPrerelease:$(-not [string]::IsNullOrWhiteSpace($theModule.PrivateData.PSData.Prerelease))).Version }
	catch
	{
		throw "Failed to access $($Repository) : $_"
	}
	if (-not $remoteVersion)
	{
		throw "Couldn't find TelemetryHelper on repository $($Repository) : $_"
	}

	$parameter = @{
		Path = "$($publishDir.FullName)\TelemetryHelper\TelemetryHelper.psd1"
	}

	[Version]$remoteModuleVersion = $remoteVersion -replace '-\w+'
	[string]$prerelease = $remoteVersion -replace '[\d\.]+-'
	if ($prerelease)
	{
		$null = $prerelease -match '\d+'
		$number = [int]$Matches.0 + 1
		$parameter['Prerelease'] = $prerelease -replace '\d', $number
	}
	else
	{
		$newBuildNumber = $remoteModuleVersion.Build + 1
		[version]$localVersion = $theModule.ModuleVersion
		$parameter['ModuleVersion'] = "$($localVersion.Major).$($localVersion.Minor).$($newBuildNumber)"
	}
	Update-ModuleManifest @parameter
}
#endregion Updating the Module Version

#region Publish
if ($SkipPublish) { return }
if ($LocalRepo)
{
	# Dependencies must go first
	Write-Host  "Creating Nuget Package for module: PSFramework"
	New-PSMDModuleNugetPackage -ModulePath (Get-Module -Name PSFramework).ModuleBase -PackagePath .
	Write-Host  "Creating Nuget Package for module: TelemetryHelper"
	New-PSMDModuleNugetPackage -ModulePath "$($publishDir.FullName)\TelemetryHelper" -PackagePath .
}
else
{
	# Publish to Gallery
	Write-Host  "Publishing the TelemetryHelper module to $($Repository)"
	Publish-Module -Path "$($publishDir.FullName)\TelemetryHelper" -NuGetApiKey $ApiKey -Force -Repository $Repository
}

if ($IncludeGitHubRelease)
{
	Write-Host  "Creating Nuget Package for module: TelemetryHelper"
	New-PSMDModuleNugetPackage -ModulePath "$($publishDir.FullName)\TelemetryHelper" -PackagePath .
}
#endregion Publish