function New-CertificateV1{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [ValidateSet('Default','solidify_training_v1')][string]$StampName,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$PdfTemplate,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$TrainerName,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$TrainerHandle,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$TrainerCompany,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$CourseName,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$CourseDate,

        [Parameter(Mandatory,ValueFromPipeline)][string]$StudentHandle,
        [Parameter(Mandatory,ValueFromPipeline)][string]$StudentCompany

    )
    
    begin{

        $cert = @{
            StampName = $StampName
            PdfTemplate = $PdfTemplate
        }

        $training = @{
            TrainerName = $TrainerName
            TrainerHandle = $TrainerHandle
            TrainerCompany = $TrainerCompany
            CourseName = $CourseName
            CourseDate = $CourseDate
        }
    }

    process {
        
        $StudentName = $StudentHandle | Get-UserName

        $sudent = @{
            StudentHandle = $StudentHandle
            StudentName = $StudentName
            StudentCompany = $StudentCompany
        }

        $id = [guid]::NewGuid().ToString()
        $certName = $StudentHandle + "_" + $id
        $userCert = @{
            id = $id
            PdfOutput = $certName + ".pdf"
        }

        $json = New-JsonCertificateV1 @cert @training @sudent @userCert
        Write-Output $json

        $pdf = $json | New-PdfCertificateV1
        Write-Output $pdf

    }
} Export-ModuleMember -Function New-CertificateV1

function New-PdfCertificateV1{
    [CmdletBinding()]
    param(
        # JSON file
        # Specifies a path to one or more locations. Wildcards are permitted.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName="ParameterSetName",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="Path to one or more locations.")]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]]
        $Path
    )
    begin{

    }

    process {
        $files = Get-ChildItem -Path $Path -Recurse -File

        foreach($file in $files){
            $jsonData = Get-Content -Path $file | ConvertFrom-Json

            $pdfOutput = $jsonData | Invoke-PdfInjector

            Write-Output $pdfOutput
        }
    }
} Export-ModuleMember -Function New-PdfCertificateV1

function New-JsonCertificateV1{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [ValidateSet('Default','solidify_training_v1')][string]$StampName,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$PdfTemplate,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$PdfOutput,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$StudentName,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$StudentHandle,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$StudentCompany,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$TrainerName,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$TrainerHandle,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$TrainerCompany,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$CourseName,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$CourseDate,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Id
    )

    $cert = @{
        StampName = $StampName
        PdfTemplate = $PdfTemplate
        PdfOutput = $PdfOutput
        StudentName = $StudentName
        StudentHandle = $StudentHandle
        StudentCompany = $StudentCompany
        TrainerName = $TrainerName
        TrainerHandle = $TrainerHandle
        TrainerCompany = $TrainerCompany
        CourseName = $CourseName
        CourseDate = $CourseDate
        Id = $Id
        Date = Get-Date
    }

    $outPath = $PdfOutput | Split-Path -Parent
    $outName = $PdfOutput | Split-Path -LeafBase
    $outJson = $outName + ".json"

    $outPathJson = [string]::IsNullOrWhiteSpace($outPath) ? $outJson : $($outPath | Join-Path -ChildPath $outJson)

    $json = $cert | ConvertTo-Json -Depth 10

    $json | Out-File -FilePath $outPathJson -Force

    return $outPathJson

} Export-ModuleMember -Function New-JsonCertificateV1