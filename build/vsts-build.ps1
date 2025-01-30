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
Copy-Item -Path "$($WorkingDirectory)/TelemetryHelper" -Destination $publishDir.FullName -Recurse -Force

#region Gather text data to compile
$text = @()
$processed = @()

# Gather Stuff to run before
foreach ($filePath in (& "$($PSScriptRoot)/../TelemetryHelper/internal/scripts/preimport.ps1"))
{
	if ([string]::IsNullOrWhiteSpace($filePath)) { continue }
	
	$item = Get-Item $filePath
	if ($item.PSIsContainer) { continue }
	if ($item.FullName -in $processed) { continue }
	$text += [System.IO.File]::ReadAllText($item.FullName)
	$processed += $item.FullName
}

# Gather commands
Get-ChildItem -Path "$($publishDir.FullName)/TelemetryHelper/internal/functions/" -Recurse -File -Filter "*.ps1" | ForEach-Object {
	$text += [System.IO.File]::ReadAllText($_.FullName)
}
Get-ChildItem -Path "$($publishDir.FullName)/TelemetryHelper/functions/" -Recurse -File -Filter "*.ps1" | ForEach-Object {
	$text += [System.IO.File]::ReadAllText($_.FullName)
}

# Gather stuff to run afterwards
foreach ($filePath in (& "$($PSScriptRoot)/../TelemetryHelper/internal/scripts/postimport.ps1"))
{
	if ([string]::IsNullOrWhiteSpace($filePath)) { continue }
	
	$item = Get-Item $filePath
	if ($item.PSIsContainer) { continue }
	if ($item.FullName -in $processed) { continue }
	$text += [System.IO.File]::ReadAllText($item.FullName)
	$processed += $item.FullName
}
#endregion Gather text data to compile

#region Update the psm1 file
$fileData = Get-Content -Path "$($publishDir.FullName)/TelemetryHelper/TelemetryHelper.psm1" -Raw
$fileData = $fileData.Replace('"<was not compiled>"', '"<was compiled>"')
$fileData = $fileData.Replace('"<compile code into here>"', ($text -join "`n`n"))
[System.IO.File]::WriteAllText("$($publishDir.FullName)/TelemetryHelper/TelemetryHelper.psm1", $fileData, [System.Text.Encoding]::UTF8)
#endregion Update the psm1 file

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
		Path = "$($publishDir.FullName)/TelemetryHelper/TelemetryHelper.psd1"
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
	Write-Host "Creating Nuget Package for module: TelemetryHelper"
	New-PSMDModuleNugetPackage -ModulePath "$($publishDir.FullName)/TelemetryHelper" -PackagePath .
}
else
{
	# Publish to Gallery
	Write-Host "Publishing the TelemetryHelper module to $($Repository)"
	Publish-Module -Path "$($publishDir.FullName)/TelemetryHelper" -NuGetApiKey $ApiKey -Force -Repository $Repository
}
#endregion Publish