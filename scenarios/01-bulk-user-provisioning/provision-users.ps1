# 01_bulk_user_provisioning.ps1
# Scenario: 01-bulk-user-provisioning
# Description: Provision users from CSV, assign licenses, add to groups.

Write-Host "Connecting to Microsoft Graph..."
# Connect-MgGraph -Scopes "User.Read.All","Directory.Read.All","AuditLog.Read.All"

Write-Host "Running scenario: 01-bulk-user-provisioning"
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
