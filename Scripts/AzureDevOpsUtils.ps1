$AzureDevOpsPAT = $Env:devopsToken
$OrganizationName = "sentinel-eco-devs"
$header = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpsPAT)")) }
$collectionUri = "https://dev.azure.com/$OrganizationName"
$branchName = "main"
$projectId = "fd0310c0-5d21-494b-abcd-1e7bb312c773"
$repositoryName = "Templates"

function GetBranchObjectId {
    $body = @{filterContains = $branchName}
    $result = AttemptInvokeRestMethod "Get" "$collectionUri/$projectId/_apis/git/repositories/$repositoryName/refs?api-version=6.0" $body $null 3
    $objectId = $result.value.objectId
    return $objectId
}

function PushFileToRepo($path, $content, $exists) {
    $objectId = GetBranchObjectId
    $status = if ($exists) {"edit"} else {"add"}
    $contentType = "application/json"

    $body = @{
        refUpdates = @(@{
            name = "refs/heads/$branchName"
            oldObjectId = $objectId
        })
        commits = @(@{
            "comment" = "test commit"
            "changes" = @(@{
                "changeType" = $status
                "item" = @{path = $path}
                "newContent" = @{
                    "content" = $content
                    "contentType" = "rawtext"}
            })
        })
    } | ConvertTo-Json -Depth 5

    AttemptInvokeRestMethod "Post" "$collectionUri/$projectId/_apis/git/repositories/$repositoryName/pushes?api-version=6.0" $body $contentType 3 
}

function AttemptInvokeRestMethod($method, $url, $body, $contentTypes, $maxRetries) {
    $Stoploop = $false
    $retryCount = 0
    do {
        try {
            $result = Invoke-RestMethod -Uri $url -Method $method -Headers $header -Body $body -ContentType $contentTypes
            $Stoploop = $true
        }
        catch {
            if ($retryCount -gt $maxRetries) {
                Write-Host "[Error] API call failed after $retryCount retries: $_"
                $Stoploop = $true
            }
            else {
                Write-Host "[Warning] API call failed: $_.`n Conducting retry #$retryCount."
                Start-Sleep -Seconds 5
                $retryCount = $retryCount + 1
            }
        }
    }
    While ($Stoploop -eq $false)
    return $result
}