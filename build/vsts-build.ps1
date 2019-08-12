<#
This script publishes the module to the gallery.
It expects as input an ApiKey authorized to publish the module.

Insert any build steps you may need to take before publishing it here.
#>
param
(
	$WorkingDirectory = $env:SYSTEM_DEFAULTWORKINGDIRECTORY
)

# Prepare publish folder
Write-PSFMessage -Level Important -Message "Creating and populating publishing directory $WorkingDirectory"
$publishDir = New-Item -Path $WorkingDirectory -Name publish -ItemType Directory
Copy-Item -Path "$($WorkingDirectory)\TelemetryHelper" -Destination $publishDir.FullName -Recurse -Force

#region Gather text data to compile
$text = @()
$processed = @()

# Gather Stuff to run before
Write-PSFMessage -Level Important -Message "Processing filebefore"
foreach ($line in (Get-Content "$($PSScriptRoot)\filesBefore.txt" | Where-Object { $_ -notlike "#*" }))
{
	if ([string]::IsNullOrWhiteSpace($line)) { continue }
	
	$basePath = Join-Path "$($publishDir.FullName)\TelemetryHelper" $line
	foreach ($entry in (Resolve-PSFPath -Path $basePath))
	{
		$item = Get-Item $entry
		if ($item.PSIsContainer) { continue }
		if ($item.FullName -in $processed) { continue }
		$text += [System.IO.File]::ReadAllText($item.FullName)
		$processed += $item.FullName
	}
}

# Gather commands
Write-PSFMessage -Level Important -Message "Finding functions"
Get-ChildItem -Path "$($publishDir.FullName)\TelemetryHelper\internal\functions\" -Recurse -File -Filter "*.ps1" | ForEach-Object {
	$text += [System.IO.File]::ReadAllText($_.FullName)
}
Get-ChildItem -Path "$($publishDir.FullName)\TelemetryHelper\functions\" -Recurse -File -Filter "*.ps1" | ForEach-Object {
	$text += [System.IO.File]::ReadAllText($_.FullName)
}

# Gather stuff to run afterwards
Write-PSFMessage -Level Important -Message "Processing fileAfter"
foreach ($line in (Get-Content "$($PSScriptRoot)\filesAfter.txt" | Where-Object { $_ -notlike "#*" }))
{
	if ([string]::IsNullOrWhiteSpace($line)) { continue }
	
	$basePath = Join-Path "$($publishDir.FullName)\TelemetryHelper" $line
	foreach ($entry in (Resolve-PSFPath -Path $basePath))
	{
		$item = Get-Item $entry
		if ($item.PSIsContainer) { continue }
		if ($item.FullName -in $processed) { continue }
		$text += [System.IO.File]::ReadAllText($item.FullName)
		$processed += $item.FullName
	}
}
#endregion Gather text data to compile

#region Update the psm1 file
Write-PSFMessage -Level Important -Message "Update PSM1"
$fileData = Get-Content -Path "$($publishDir.FullName)\TelemetryHelper\TelemetryHelper.psm1" -Raw
$fileData = $fileData.Replace('"<was not compiled>"', '"<was compiled>"')
$fileData = $fileData.Replace('"<compile code into here>"', ($text -join "`n`n"))
[System.IO.File]::WriteAllText("$($publishDir.FullName)\TelemetryHelper\TelemetryHelper.psm1", $fileData, [System.Text.Encoding]::UTF8)
#endregion Update the psm1 file

# Publish to Gallery
$ApiKey = $env:ApiKey

if ([string]::IsNullOrWhiteSpace($ApiKey))
{
	throw "Why is there no API Key, boy?"
}

Write-PSFMessage -Level Important -Message "Publishing, $($publishDir.FullName)\TelemetryHelper, API: $(-join $ApiKey[0,1])...$(-join $ApiKey[-2,-1])"
Publish-Module -Path "$($publishDir.FullName)\TelemetryHelper" -NuGetApiKey $ApiKey -Force -Confirm:$false -Verbose
