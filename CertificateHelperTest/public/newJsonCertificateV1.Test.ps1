
$LOCAL = $PSScriptRoot
$PDF_TEMPLATE = $LOCAL | Join-Path -ChildPath 'Pdftemplate.pdf'
$studentHandle ="StudentHandle"
$id = "123456789"

$PDF_OUTPUT_NAME = $studentHandle + "_" + $id + ".pdf"

function CertificateHelperTest_NewJsonCertificateV1_Success{

    $pdfOutput = $PDF_OUTPUT_NAME

    $param = @{
        StampName = "Default"
        PdfTemplate = $PDF_TEMPLATE
        PdfOutput = $pdfOutput
        StudentName = "studentName"
        StudentHandle = "studentHandle"
        StudentCompany = "studentCompany"
        TrainerName = "trainerName"
        TrainerHandle = "trainerHandle"
        TrainerCompany = "trainerCompany"
        CourseName = "courseName"
        CourseDate = "courseDate"
        Id = $id
    }
    
    # Act generate JSON
    $result = New-JsonCertificateV1 @param

    # Assert JSON
    $resultData = Get-Content -Path $result | ConvertFrom-Json

    Assert-AreEqual -Expected $param.StampName      -Presented $resultData.StampName
    Assert-AreEqual -Expected $param.PdfTemplate    -Presented $resultData.PdfTemplate
    Assert-AreEqual -Expected $param.PdfOutput      -Presented $resultData.PdfOutput
    Assert-AreEqual -Expected $param.StudentName    -Presented $resultData.StudentName
    Assert-AreEqual -Expected $param.StudentHandle  -Presented $resultData.StudentHandle
    Assert-AreEqual -Expected $param.StudentCompany -Presented $resultData.StudentCompany
    Assert-AreEqual -Expected $param.TrainerName    -Presented $resultData.TrainerName
    Assert-AreEqual -Expected $param.TrainerHandle  -Presented $resultData.TrainerHandle
    Assert-AreEqual -Expected $param.TrainerCompany -Presented $resultData.TrainerCompany
    Assert-AreEqual -Expected $param.CourseName     -Presented $resultData.CourseName
    Assert-AreEqual -Expected $param.CourseDate     -Presented $resultData.CourseDate
    Assert-AreEqual -Expected $param.Id             -Presented $resultData.Id
}
