try
{
  #https://docs.microsoft.com/en-us/dotnet/api/system.net.securityprotocoltype?view=netcore-2.0#System_Net_SecurityProtocolType_SystemDefault
  if ($PSVersionTable.PSVersion.Major -lt 6 -and [Net.ServicePointManager]::SecurityProtocol -notmatch 'Tls12')
  {
    Write-Verbose -Message 'Adding support for TLS 1.2'
    [Net.ServicePointManager]::SecurityProtocol += [Net.SecurityProtocolType]::Tls12
  }
}
catch
{ }

Get-PackageProvider -Name Nuget -ForceBootstrap

$modules = @("Pester", "PSFramework", "PSScriptAnalyzer", "PowerShellGet")

foreach ($module in $modules) {
    Write-Host "Installing $module" -ForegroundColor Cyan
    Install-Module $module -Force -SkipPublisherCheck -AllowClobber
    Import-Module $module -Force -PassThru
}

$binaryPath = Join-Path -Path (Get-Module PSFramework).ModuleBase -ChildPath Bin\PSFramework.dll -Resolve -ErrorAction Stop
$projPath = Join-Path -Path $PSScriptRoot -ChildPath '..\library\TelemetryHelper\TelemetryHelper\TelemetryHelper.csproj'  -Resolve -ErrorAction Stop

$content = [xml](Get-Content -Path $projPath)
($content.Project.ItemGroup.Reference | Where-Object Include -eq PSFramework).HintPath = $binaryPath -replace '\\','/'
$content.Save($projPath)

# Core
dotnet publish $projPath -f netcoreapp2.2 -o (Join-Path -Path $PSScriptRoot '..\TelemetryHelper\bin\core')

# Full
dotnet publish $projPath -f net462 -o (Join-Path -Path $PSScriptRoot '..\TelemetryHelper\bin\full')