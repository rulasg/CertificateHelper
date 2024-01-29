function Sync-FromModule{
    [CmdletBinding()]
    param (
        [Parameter(Position=0,ValueFromPipeline)][string]$ModulePath
    )
    $local = $PSScriptRoot

    $sourceModulePath = $ModulePath
    $destinationModulePath = $local

    $source = $sourceModulePath | Get-ModulePaths
    $destination = $destinationModulePath | Get-ModulePaths

    Update-File $source $destination "workflow" "deploy_module_on_release.yml"
    Update-File $source $destination "workflow" "powershell.yml"
    Update-File $source $destination "workflow" "test_with_TestingHelper.yml"
    Update-File $source $destination "tools"    "deploy.Helper.ps1"
    Update-File $source $destination "tools"    "sync.Helper.ps1"
    Update-File $source $destination "root"     "deploy.ps1"
    Update-File $source $destination "root"     "sync.ps1"
    Update-File $source $destination "root"     "release.ps1"
    Update-File $source $destination "root"     "test.ps1"

}

function Get-ModulePaths{
    [CmdletBinding()]
    param (
        [Parameter(Position=0,ValueFromPipeline)][string]$ModulePath
    )
    return @{
        root = $ModulePath
        tools = $ModulePath | Join-Path -ChildPath "tools"
        workflow = $ModulePath | Join-Path -ChildPath ".github" -AdditionalChildPath "workflows"
    }
}

function Update-File{
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][hashtable]$Source,
        [Parameter(Position=1)][hashtable]$Destination,
        [Parameter(Position=2)][string]$Folder,
        [Parameter(Position=3)][string]$File
    )

    $sourceFile = $($source.$Folder) | Join-Path -ChildPath $File
    $destinationFile = $($destination.$Folder) | Join-Path -ChildPath $File

    Copy-Item -Path $sourceFile -Destination $destinationFile -Force
}

Write-Host -Message "run Sync-FromModule -ModulePath <path to module> to update modules strucutre files with the onces on the local module"