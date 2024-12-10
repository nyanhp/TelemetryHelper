try {
    Add-Type -Path "$script:moduleRoot/bin/netstandard2.0/TelemetryHelper.dll" -ErrorAction Stop
} catch {
    Write-Error -Message "Unable to import telemetry library."
}