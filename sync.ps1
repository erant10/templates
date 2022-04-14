[CmdletBinding()]
param (
  $testArg
)
Write-Output "Executing sync script $testArg"
Write-Output $Env:AZURE_DEVOPS_TOKEN
