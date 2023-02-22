param (
    [string]
    $Repository = 'PSGallery'
)

$modules = @("Pester", "PSScriptAnalyzer", 'PlatyPs', 'PSModuleDevelopment', 'PSFramework')

# Automatically add missing dependencies
$data = Import-PowerShellDataFile -Path "$PSScriptRoot\..\TelemetryHelper\TelemetryHelper.psd1"
foreach ($dependency in $data.RequiredModules) {
    if ($dependency -is [string]) {
        if ($modules -contains $dependency) { continue }
        $modules += $dependency
    }
    else {
        if ($modules -contains $dependency.ModuleName) { continue }
        $modules += $dependency.ModuleName
    }
}

foreach ($module in $modules) {
    Write-Host "Installing $module" -ForegroundColor Cyan
    Install-Module $module -Force -SkipPublisherCheck -Repository $Repository
    Import-Module $module -Force -PassThru
}

Write-Host -ForegroundColor Cyan 'Updating PSFramework Reference for build'
[xml]$zeStuff = Get-Content -Path "$PSScriptRoot\..\library\TelemetryHelper\TelemetryHelper\TelemetryHelper.csproj"
$zeStuff.SelectSingleNode('/Project/ItemGroup/Reference[@Include="PSFramework"]/HintPath').InnerText = Join-Path (Get-Module PSFramework).ModuleBase -ChildPath bin\PSFramework.dll
$zeStuff.Save("$PSScriptRoot\..\library\TelemetryHelper\TelemetryHelper\TelemetryHelper.csproj")
dotnet build "$PSScriptRoot\..\library\TelemetryHelper\TelemetryHelper\TelemetryHelper.csproj"
dotnet publish "$PSScriptRoot\..\library\TelemetryHelper\TelemetryHelper\TelemetryHelper.csproj" -o "$PSScriptRoot\..\TelemetryHelper\bin\netstandard2.0"