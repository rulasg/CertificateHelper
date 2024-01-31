
Set-InvokeCommandAlias -Alias GetUser -Command 'gh api users/{userhandle}' -Tag 'CertificateHelperModule'

function Get-UserName{
    [CmdletBinding()]
    param (
        [Parameter(Position=0,ValueFromPipeline)][string]$UserHandle
    )

    process{
        
        $parameters = @{
            userhandle = $UserHandle
        }

        $result = Invoke-MyCommandJson -Command GetUser -Parameters $parameters

        if($result){
            $result.name
        } else {
            $null
        }
    }
} Export-ModuleMember -Function Get-UserName

function Get-UserInfo{
    [CmdletBinding()]
    param (
        [Parameter(Position=0,ValueFromPipeline)][string]$UserHandle
    )

    process{
        
        $parameters = @{
            userhandle = $UserHandle
        }

        $result = Invoke-MyCommandJson -Command GetUser -Parameters $parameters

        if($result){
            $ret = [PSCustomObject]@{
                Name = $result.name
                Handle = $result.login
                Company = $result.company
                email = $result.email
            }

        } else {
            $ret = $null
        }

        return $ret
    }
} Export-ModuleMember -Function Get-UserInfo