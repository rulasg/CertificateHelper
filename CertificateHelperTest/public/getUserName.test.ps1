

function CertificateHelperTest_GetUserName_Success{

    $handle = "joess"
    $name = "Joe Smith"

    $mockFile = $PSScriptRoot | Join-Path -ChildPath 'testdata' -AdditionalChildPath 'getuserSuccess.json'
    Set-InvokeCommandAlias -Alias "gh api users/$handle" -Tag 'CertificateHelperMock' -Command "Get-Content -Path $(($mockFile | Get-Item).FullName)"

    $result = Get-UserName -UserHandle $handle

    Assert-AreEqual -Expected $name -Presented $result
}

function CertificateHelperTest_GetUserInfo_Success{

    $handle = "josess"
    $name = "Joe Smith"

    $mockFile = $PSScriptRoot | Join-Path -ChildPath 'testdata' -AdditionalChildPath 'getuserSuccess.json'
    Set-InvokeCommandAlias -Alias "gh api users/$handle" -Tag 'CertificateHelperMock' -Command "Get-Content -Path $(($mockFile | Get-Item).FullName)"

    $result = Get-UserInfo -UserHandle $handle

    Assert-AreEqual -Expected $name -Presented $result.Name
    Assert-AreEqual -Expected $handle -Presented $result.Handle
    Assert-AreEqual -Expected "Contoso" -Presented $result.Company
    Assert-AreEqual -Expected "josess@github.com" -Presented $result.email

}