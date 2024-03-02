function New-CertificateV1{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [ValidateSet('Default','solidify_training_v1','solidify_training_v2')][string]$StampName,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$PdfTemplate,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$TrainerName,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$TrainerHandle,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$TrainerCompany,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$CourseName,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$CourseDate,

        [Parameter(ValueFromPipeline)][string]$StudentHandle,
        [Parameter()][string]$StudentName,
        [Parameter()][string]$StudentCompany

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

        # Resolve the student name
        if([string]::IsNullOrWhiteSpace($StudentName)){
            $StudentName = $StudentHandle | Get-UserName
            
            if([string]::IsNullOrWhiteSpace($StudentName)){
                Write-Error -Message "Student name missing and not found in GitHub profile"
                return
            }
        }

        
        $student = @{
            StudentHandle = $StudentHandle
            StudentName = $StudentName
            StudentCompany = $StudentCompany
        }
        
        $id = [guid]::NewGuid().ToString()
        $nameid = [string]::IsNullOrWhiteSpace($StudentHandle) ? $($StudentName -replace " ","_") : $StudentHandle
        $certName = $nameid + "_" + $id
        $userCert = @{
            id = $id
            PdfOutput = $certName + ".pdf"
        }

        if ($PSCmdlet.ShouldProcess($StudentName, "New-JsonCertificateV1 | New-PdfCertificateV1")) {
            
            $json = New-JsonCertificateV1 @cert @training @student @userCert
            Write-Output $json
            
            $pdf = $json | New-PdfCertificateV1
            Write-Output $pdf
        }

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
        [ValidateSet('Default','solidify_training_v1','solidify_training_v2')][string]$StampName,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$PdfTemplate,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$PdfOutput,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$TrainerName,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$TrainerHandle,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$TrainerCompany,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$CourseName,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$CourseDate,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Id,
        
        [Parameter(ValueFromPipelineByPropertyName)][string]$StudentHandle,
        [Parameter(ValueFromPipelineByPropertyName)][string]$StudentName,
        [Parameter(ValueFromPipelineByPropertyName)][string]$StudentCompany
    )

    process {
        
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
    }
} Export-ModuleMember -Function New-JsonCertificateV1