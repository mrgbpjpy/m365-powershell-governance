# 10_license_optimization.ps1
# Scenario: 10-license-optimization
# Description: Detect unused licenses.

#Requires -Module Microsoft.Graph.Users, Microsoft.Graph.Identity.DirectoryManagement

<#
.SYNOPSIS
Detects users assigned licenses but showing inactivity.

.DESCRIPTION
- Retrieves all licensed users
- Checks last sign-in activity
- Flags users with licenses but inactive
- Exports CSV for license optimization

Required Scopes:
User.Read.All
Directory.Read.All
AuditLog.Read.All
#>

param(
    [int]$InactiveDays = 90,
    [string]$ReportPath = ("License_Optimization-{0}.csv" -f (Get-Date -Format 'yyyyMMdd'))
)

Write-Host "Connecting to Microsoft Graph..."
Connect-MgGraph -Scopes "User.Read.All","Directory.Read.All","AuditLog.Read.All" | Out-Null
Write-Host "Connected."

Write-Host "Retrieving licensed users..."
$props = "Id,DisplayName,UserPrincipalName,AccountEnabled,AssignedLicenses,SignInActivity"
$users = Get-MgUser -All -Property $props | Where-Object { $_.AssignedLicenses.Count -gt 0 }

$total = $users.Count
$counter = 0
$results = @()

foreach ($user in $users) {
    $counter++
    Write-Progress -Activity "Auditing License Usage" `
        -Status "Processing $counter of $total: $($user.UserPrincipalName)" `
        -PercentComplete (($counter / $total) * 100)

    $lastSignIn = $user.SignInActivity.LastSignInDateTime
    if ($lastSignIn) {
        $daysInactive = (New-TimeSpan -Start $lastSignIn -End (Get-Date)).Days
        $inactive = if ($daysInactive -ge $InactiveDays) { "Yes" } else { "No" }
    } else {
        $inactive = "Yes"
    }

    if ($inactive -eq "Yes") {
        $results += [pscustomobject]@{
            DisplayName       = $user.DisplayName
            UserPrincipalName = $user.UserPrincipalName
            AccountEnabled    = $user.AccountEnabled
            LastSignIn        = if ($lastSignIn) { $lastSignIn.ToString("yyyy-MM-dd") } else { "N/A" }
            Inactive90Days    = $inactive
            LicenseCount      = $user.AssignedLicenses.Count
        }
    }
}

$results | Sort-Object LicenseCount -Descending |
    Export-Csv -Path $ReportPath -NoTypeInformation

# Summary
$totalFlagged = $results.Count
$totalLicenses = ($results | Measure-Object LicenseCount -Sum).Sum

Write-Host ""
Write-Host "====== LICENSE OPTIMIZATION SUMMARY ======"
Write-Host "Inactive Licensed Users : $totalFlagged"
Write-Host "Licenses to Review      : $totalLicenses"
Write-Host "=========================================="

Write-Host "Report saved to $ReportPath"
Disconnect-MgGraph
