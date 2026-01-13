# 07_signin_risk_report.ps1
# Scenario: 07-signin-risk-report
# Description: Report risky sign-ins.

Write-Host "Connecting to Microsoft Graph..."
# Connect-MgGraph -Scopes "User.Read.All","Directory.Read.All","AuditLog.Read.All"

Write-Host "Running scenario: 07-signin-risk-report"
$results = @()

# Sample simulated data
$results += [pscustomobject]@{
    Item = "SampleObject1"
    Status = "OK"
    CheckedOn = "2026-01-13"
}
$results += [pscustomobject]@{
    Item = "SampleObject2"
    Status = "Review"
    CheckedOn = "2026-01-13"
}

$results | Export-Csv "output-sample.csv" -NoTypeInformation
Write-Host "Report exported to output-sample.csv"
