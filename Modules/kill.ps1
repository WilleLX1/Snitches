param (
    [string]$windowTitle
)

# Get all PowerShell processes
$psProcesses = Get-Process -Name powershell -ErrorAction SilentlyContinue

# Filter processes with window titles containing the specified argument
$comBoomProcesses = $psProcesses | Where-Object { $_.MainWindowTitle -like $windowTitle }

# Terminate the identified processes
$comBoomProcesses | ForEach-Object { Stop-Process -Id $_.Id -Force }

# Return the number of terminated processes
if ($comBoomProcesses.Count -eq 0) {
    Write-Output "No processes found with window title containing '$windowTitle'"
}
else {
    $comBoomProcesses.Count
}
