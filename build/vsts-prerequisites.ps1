Install-PackageProvider -Name NuGet -Force

$modules = @("Pester", "PSFramework", "PSScriptAnalyzer", "PowerShellGet")

foreach ($module in $modules) {
    Write-Host "Installing $module" -ForegroundColor Cyan
    Install-Module $module -Force -SkipPublisherCheck -AllowClobber
    Import-Module $module -Force -PassThru
}

$binaryPath = Join-Path -Path (Get-Module PSFramework).ModuleBase -ChildPath Bin\PSFramework.dll -Resolve -ErrorAction Stop
$path = Join-Path -Path $PSScriptRoot -ChildPath '..\library\TelemetryHelper' -Resolve -ErrorAction Stop
$projPath = Join-Path -Path $PSScriptRoot -ChildPath '..\library\TelemetryHelper\TelemetryHelper\TelemetryHelper.csproj'  -Resolve -ErrorAction Stop

$content = [xml](Get-Content -Path $projPath)
($content.Project.ItemGroup.Reference | Where-Object Include -eq PSFramework).HintPath = $binaryPath -replace '\\','/'
$content.Save($projPath)

dotnet build $path /p:Configuration=Release
