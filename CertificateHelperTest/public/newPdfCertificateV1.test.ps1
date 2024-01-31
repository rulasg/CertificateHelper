
$LOCAL = $PSScriptRoot
$PDF_TEMPLATE = $LOCAL | Join-Path -ChildPath 'Pdftemplate.pdf'
$studentHandle ="StudentHandle"
$id = "123456789"

$PDF_OUTPUT_NAME = $studentHandle + "_" + $id + ".pdf"

function CertificateHelperTest_NewPdfCertificateV1_SUCCESS{

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
    
    # Generate JSON
    $result = New-JsonCertificateV1 @param

    # Genearte PDF
    $result = New-PdfCertificateV1 -Path $result

    # Assert PDF
    Assert-AreEqual -Expected $pdfOutput -Presented $result
    Assert-ItemExist -Path $result
}

function CertificateHelperTest_NewPdfCertificateMultiFile{

    $param = @{
        StampName = "solidify_training_v1"
        PdfTemplate = $PDF_TEMPLATE
        StudentCompany = "studentCompany"
        TrainerName = "trainerName"
        TrainerHandle = "trainerHandle"
        TrainerCompany = "trainerCompany"
        CourseName = "courseName"
        CourseDate = "courseDate"
        PdfOutput = ""
        StudentHandle = ""
        StudentName = ""
        Id = ""
    }
    $param.StudentHandle = "studentHandle1"
    $param.StudentName = "student Name 1"
    $param.Id = "11234567890"
    $param.PdfOutput = $param.studentHandle + "_" + $param.id + ".pdf"
    $pdf1 = $param.PdfOutput
    $json1 = New-JsonCertificateV1 @param

    $param.StudentHandle = "studentHandle2"
    $param.StudentName = "student Name 2"
    $param.Id = "21234567890"
    $param.PdfOutput = $param.studentHandle + "_" + $param.id + ".pdf"
    $pdf2 = $param.PdfOutput
    $json2 = New-JsonCertificateV1 @param

    $param.StudentHandle = "studentHandle3"
    $param.StudentName = "student Name 3"
    $param.Id = "3123456789"
    $param.PdfOutput = $param.studentHandle + "_" + $param.id + ".pdf"
    $pdf3 = $param.PdfOutput
    $json3 = New-JsonCertificateV1 @param


    $result = Get-ChildItem *.json | New-PdfCertificateV1

    Assert-Contains -Expected $pdf1 -Presented $result
    Assert-Contains -Expected $pdf2 -Presented $result
    Assert-Contains -Expected $pdf3 -Presented $result

}