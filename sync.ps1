$AzureDevOpsPAT = $Env:devopsToken
$OrganizationName = "sentinel-eco-devs"

$AzureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpsPAT)")) }

$UriOrga = "https://dev.azure.com/$($OrganizationName)/" 
$uriAccount = $UriOrga + "_apis/projects?api-version=5.1"

Invoke-RestMethod -Uri $uriAccount -Method get -Headers $AzureDevOpsAuthenicationHeader 
