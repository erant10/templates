[CmdletBinding()]
param (
  $testArg
)
Write-Output "Executing sync script $testArg"
Write-Output "token " + $Env:devopsToken
