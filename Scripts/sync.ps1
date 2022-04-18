. "$Env:directory\Scripts\ConvertWorkbooksToArm.ps1"
. "$Env:directory\Scripts\AzureDevOpsUtils.ps1"

foreach($workbookJson in $(Get-ChildItem -Path "$Env:directory/GitHub/Workbooks" -Recurse -Include '*.json' -Exclude '*properties.json'))
{
    $armTemplate = ConvertWorkbooksToArm $workbookJson.FullName
    $filename = "$($workbookJson.BaseName)_ARM.json"
    PushFileToRepo -path "Workbooks/$filename" -content $armTemplate -exists $False
}

