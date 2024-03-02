
$LOCAL = $PSScriptRoot
$PDF_TEMPLATE = $LOCAL | Join-Path -ChildPath 'Pdftemplate.pdf'
$studentHandle ="StudentHandle"
$id = "123456789"

$MOCK_TAG = 'CertificateHelperMock'

function CertificateHelperTest_NewCertificateV1_SUCCESS{

    $handle = "joess"
    $name = "Joe Smith"

    $mockFile = $PSScriptRoot | Join-Path -ChildPath 'testdata' -AdditionalChildPath 'getuserSuccess.json'
    Set-InvokeCommandAlias -Alias "gh api users/$handle" -Tag 'CertificateHelperMock' -Command "Get-Content -Path $(($mockFile | Get-Item).FullName)"

    $param = @{
        StampName = "solidify_training_v1"
        PdfTemplate = $PDF_TEMPLATE

        TrainerName = "trainerName"
        TrainerHandle = "trainerHandle"
        TrainerCompany = "trainerCompany"
        CourseName = "courseName"
        CourseDate = "courseDate"
    }
        
    # Generate certificate
    $result = New-CertificateV1 -StudentHandle $handle -StudentCompany "studentCompany" @param

    $jsonFile = $result | Where-Object {$_ -like "*.json"}
    $pdfFile = $result | Where-Object {$_ -like "*.pdf"}

    # Assert PDF
    $json =  Get-Content -path $jsonFile | ConvertFrom-Json
    Assert-AreEqual -Expecte $handle -Presented $json.StudentHandle
    Assert-AreEqual -Expected $name -Presented $json.StudentName

    Assert-ItemExist -Path $pdfFile
}

function CertificateHelperTest_NewCertificateV1_Error_NotAllInfo_MissingNameInProfile{

    Reset-InvokeCommandAlias -Tag $MOCK_TAG

    $handle = "joess2"

    $mockFile = $PSScriptRoot | Join-Path -ChildPath 'testdata' -AdditionalChildPath 'getuserSuccess_joess2.json'
    Set-InvokeCommandAlias -Alias "gh api users/$handle" -Tag $MOCK_TAG -Command "Get-Content -Path $(($mockFile | Get-Item).FullName)"

    $param = @{
        StampName = "solidify_training_v1"
        PdfTemplate = $PDF_TEMPLATE

        TrainerName = "trainerName"
        TrainerHandle = "trainerHandle"
        TrainerCompany = "trainerCompany"
        CourseName = "courseName"
        CourseDate = "courseDate"
    }
        
    # Generate certificate
    $result = $handle | ConvertTo-StudentHandle | New-CertificateV1 -StudentCompany "studentCompany" @param @ErrorParameters

    Assert-IsNull -Object $result
    Assert-Contains -Presented $errorvar.Exception.Message -Expected 'Student name missing and not found in GitHub profile'
}

function CertificateHelperTest_NewCertificateV1_SUCCESS_StamperV2_MissingHandle{

    Reset-InvokeCommandAlias -Tag $MOCK_TAG

    $handle = ""
    $name = "Joe Smith 2"

    $mockFile = $PSScriptRoot | Join-Path -ChildPath 'testdata' -AdditionalChildPath 'getuserSuccess_joess2.json'
    Set-InvokeCommandAlias -Alias "gh api users/$handle" -Tag $MOCK_TAG -Command "Get-Content -Path $(($mockFile | Get-Item).FullName)"

    $param = @{
        StampName = "solidify_training_v2"
        PdfTemplate = $PDF_TEMPLATE

        TrainerName = "trainerName"
        TrainerHandle = "trainerHandle"
        TrainerCompany = "trainerCompany"
        CourseName = "courseName"
        CourseDate = "courseDate"
    }
        
    # Generate certificate
    $result = New-CertificateV1 -StudentName $name -StudentCompany "studentCompany" @param

    $jsonFile = $result | Where-Object {$_ -like "*.json"}
    $pdfFile = $result | Where-Object {$_ -like "*.pdf"}

    # Assert PDF
    $json =  Get-Content -path $jsonFile | ConvertFrom-Json
    Assert-AreEqual -Expecte $handle -Presented $json.StudentHandle
    Assert-AreEqual -Expected $name -Presented $json.StudentName

    Assert-ItemExist -Path $pdfFile
}

function CertificateHelperTest_NewCertificateV1_SUCCESS_MultiFile{
$USER_JSON = @'
    '{"name": "{username}"}'
'@
    $jsonUser1 = $USER_JSON -replace "{username}","Joe Smith 1"
    $jsonUser2 = $USER_JSON -replace "{username}","Joe Smith 2"
    $jsonUser3 = $USER_JSON -replace "{username}","Joe Smith 3"
    Set-InvokeCommandAlias -Alias "gh api users/user1" -Tag 'CertificateHelperMock' -Command "echo  $jsonUser1"
    Set-InvokeCommandAlias -Alias "gh api users/user2" -Tag 'CertificateHelperMock' -Command "echo  $jsonUser2"
    Set-InvokeCommandAlias -Alias "gh api users/user3" -Tag 'CertificateHelperMock' -Command "echo  $jsonUser3"

    $param = @{
        StampName = "solidify_training_v1"
        PdfTemplate = $PDF_TEMPLATE

        TrainerName = "trainerName"
        TrainerHandle = "trainerHandle"
        TrainerCompany = "trainerCompany"
        CourseName = "courseName"
        CourseDate = "courseDate"
    }

        # Generate certificate
        $result = ("user1","user2","user3") | ConvertTo-StudentHandle | New-CertificateV1 -StudentCompany "studentCompany" @param

        $jsonFile = $result | Where-Object {$_ -like "*.json"}
        $pdfFile = $result | Where-Object {$_ -like "*.pdf"}

        Assert-Count -Expected 3 -Presented $jsonFile
        Assert-Count -Expected 3 -Presented $pdfFile

        Assert-Count -Expected 2 -Presented ($result | where {$_ -like "user1_*"})
        Assert-Count -Expected 2 -Presented ($result | where {$_ -like "user2_*"})
        Assert-Count -Expected 2 -Presented ($result | where {$_ -like "user3_*"})

        $jsonUser1 = Get-Content -Path ($result | where {$_ -like "user1_*.json"}) | ConvertFrom-Json
        Assert-AreEqual -Expected "studentCompany" -Presented $jsonUser1.StudentCompany
        $jsonUser3 = Get-Content -Path ($result | where {$_ -like "user3_*.json"}) | ConvertFrom-Json
        Assert-AreEqual -Expected "studentCompany" -Presented $jsonUser3.StudentCompany
}