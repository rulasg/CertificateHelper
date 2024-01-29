

function CertificateHelperTest_GetUserName_Success{

    $handle = "joess"
    $name = "Joe Smith"

    $mockFile = $PSScriptRoot | Join-Path -ChildPath 'testdata' -AdditionalChildPath 'getuserSuccess.json'
    Set-InvokeCommandAlias -Alias "gh api users/$handle" -Tag 'CertificateHelperMock' -Command "Get-Content -Path $(($mockFile | Get-Item).FullName)"

    $result = Get-UserName -UserHandle $handle

    Assert-AreEqual -Expected $name -Presented $result
}