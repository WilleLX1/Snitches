param (
    [Parameter(Mandatory=$true)]
    [string]$Command
)

try {
    $output = Invoke-Expression -Command $Command
    Write-Output $output
}
catch {
    Write-Error $_.Exception.Message
}
