# 08_data_access_audit.ps1
# Scenario: 08-data-access-audit
# Description: Audit file access events.

#Requires -Module Microsoft.Graph.AuditLogs, Microsoft.Graph.Users

<#
.SYNOPSIS
Audits recent file access activity in Microsoft 365.

.DESCRIPTION
- Retrieves audit log events related to file access
- Focuses on SharePoint and OneDrive activity
- Reports who accessed what, when, and from where
- Exports CSV for security and governance review

Required Scopes:
AuditLog.Read.All
User.Read.All
#>

param(
    [int]$DaysBack = 7,
    [string]$ReportPath = ("Data_Access_Audit-{0}.csv" -f (Get-Date -Format 'yyyyMMdd'))
)

Write-Host "Connecting to Microsoft Graph..."
Connect-MgGraph -Scopes "AuditLog.Read.All","User.Read.All" | Out-Null
Write-Host "Connected."

$since = (Get-Date).AddDays(-$DaysBack).ToString("o")
Write-Host "Retrieving file access events since $since..."

# Pull audit logs related to file activity
$logs = Get-MgAuditLogDirectoryAudit -All -Filter "activityDateTime ge $since"

$results = @()
$total = $logs.Count
$counter = 0

foreach ($log in $logs) {
    $counter++
    Write-Progress -Activity "Auditing File Access" `
        -Status "Processing $counter of $total" `
        -PercentComplete (($counter / $total) * 100)

    # Only file-related actions
    if ($log.ActivityDisplayName -notmatch "File|SharePoint|OneDrive|Document") { continue }

    $user = $log.InitiatedBy.User

    $results += [pscustomobject]@{
        ActivityTime   = $log.ActivityDateTime.ToString("yyyy-MM-dd HH:mm")
        UserUPN        = $user.UserPrincipalName
        UserId         = $user.Id
        Activity       = $log.ActivityDisplayName
        Resource       = ($log.TargetResources | Select-Object -First 1).DisplayName
        ResourceType   = ($log.TargetResources | Select-Object -First 1).Type
        IPAddress      = $log.AdditionalDetails | Where-Object { $_.Key -eq "IPAddress" } | Select-Object -ExpandProperty Value
        Result         = $log.Result
    }
}

# Export
$results | Export-Csv -Path $ReportPath -NoTypeInformation

# Summary
$totalEvents = $results.Count
$uniqueUsers = ($results | Select-Object -ExpandProperty UserUPN -Unique).Count

Write-Host ""
Write-Host "========== DATA ACCESS AUDIT SUMMARY =========="
Write-Host "Days Reviewed : $DaysBack"
Write-Host "Total Events  : $totalEvents"
Write-Host "Unique Users  : $uniqueUsers"
Write-Host "==============================================="

Write-Host "Report saved to $ReportPath"
Disconnect-MgGraph
