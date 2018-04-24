Import-Module -Name Pester
Import-Module -Name .\EWS
Import-Module -Name .\tests\Assertions.psm1
$out = Invoke-Pester -Script .\tests\ -OutputFormat NUnitXml -OutputFile .\tests\results.xml -PassThru
try {
    [System.Net.WebClient]::
        new().
        UploadFile(
            "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", 
            (Resolve-Path .\tests\results.xml)
        )
} catch {
    throw "Failed to upload tests - $_"
}

if ($failed = $out.FailedCount) {
    throw "Failed tests: $failed"
}