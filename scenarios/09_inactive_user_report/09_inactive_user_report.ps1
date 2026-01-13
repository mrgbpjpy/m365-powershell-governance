# 09_inactive_user_report.ps1
# Scenario: 09-inactive-user-report
# Description: Find inactive users.

Write-Host "Connecting to Microsoft Graph..."
# Connect-MgGraph -Scopes "User.Read.All","Directory.Read.All","AuditLog.Read.All"

Write-Host "Running scenario: 09-inactive-user-report"
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
