# 09_inactive_user_report.ps1
# Scenario: 09-inactive-user-report
# Description: Find inactive users.

#Requires -Module Microsoft.Graph.Users, Microsoft.Graph.Identity.SignIns

<#
.SYNOPSIS
Finds inactive users in Microsoft 365.

.DESCRIPTION
- Retrieves all users
- Checks last sign-in activity
- Flags users inactive for a defined period
- Exports CSV for governance and cleanup planning

Required Scopes:
User.Read.All
AuditLog.Read.All
#>

param(
    [int]$InactiveDays = 90,
    [string]$ReportPath = ("Inactive_User_Report-{0}.csv" -f (Get-Date -Format 'yyyyMMdd'))
)

Write-Host "Connecting to Microsoft Graph..."
Connect-MgGraph -Scopes "User.Read.All","AuditLog.Read.All" | Out-Null
Write-Host "Connected."

Write-Host "Retrieving users..."
$props = "Id,DisplayName,UserPrincipalName,AccountEnabled,UserType,SignInActivity"
$users = Get-MgUser -All -Property $props

$total = $users.Count
$counter = 0
$results = @()

foreach ($user in $users) {
    $counter++
    Write-Progress -Activity "Auditing Inactive Users" `
        -Status "Processing $counter of $total: $($user.UserPrincipalName)" `
        -PercentComplete (($counter / $total) * 100)

    $lastSignIn = $user.SignInActivity.LastSignInDateTime
    if ($lastSignIn) {
        $daysInactive = (New-TimeSpan -Start $lastSignIn -End (Get-Date)).Days
        $inactive = if ($daysInactive -ge $InactiveDays) { "Yes" } else { "No" }
    } else {
        $inactive = "Yes"
    }

    $results += [pscustomobject]@{
        DisplayName       = $user.DisplayName
        UserPrincipalName = $user.UserPrincipalName
        AccountEnabled    = $user.AccountEnabled
        UserType          = $user.UserType
        LastSignIn        = if ($lastSignIn) { $lastSignIn.ToString("yyyy-MM-dd") } else { "N/A" }
        Inactive90Days    = $inactive
    }
}

$results | Sort-Object Inactive90Days, UserPrincipalName |
    Export-Csv -Path $ReportPath -NoTypeInformation

# Summary
$totalUsers = $results.Count
$inactiveUsers = ($results | Where-Object Inactive90Days -eq "Yes").Count

Write-Host ""
Write-Host "========== INACTIVE USER SUMMARY =========="
Write-Host "Total Users     : $totalUsers"
Write-Host "Inactive Users  : $inactiveUsers"
Write-Host "==========================================="

Write-Host "Report saved to $ReportPath"
Disconnect-MgGraph
