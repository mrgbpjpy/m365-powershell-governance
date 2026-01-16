# 04_teams_sprawl_report.ps1
# Scenario: 04-teams-sprawl-report
# Description: Find inactive Teams and missing owners.

#Requires -Module Microsoft.Graph.Groups, Microsoft.Graph.Teams, Microsoft.Graph.Reports

<#
.SYNOPSIS
Finds inactive Microsoft Teams and Teams with missing owners.

.DESCRIPTION
This script:
- Retrieves all Teams (backed by M365 Groups)
- Checks owner count
- Checks last activity using M365 usage reports
- Flags inactive Teams and Teams without owners
- Exports a governance-ready CSV report

Required Scopes:
Group.Read.All
Team.ReadBasic.All
Reports.Read.All
#>

param(
    [int]$InactiveDays = 90,
    [string]$ReportPath = ("Teams_Sprawl_Report-{0}.csv" -f (Get-Date -Format 'yyyyMMdd'))
)

Write-Host "Connecting to Microsoft Graph..."
Connect-MgGraph -Scopes "Group.Read.All","Team.ReadBasic.All","Reports.Read.All" | Out-Null
Write-Host "Connected."

# Get Teams usage report
Write-Host "Retrieving Teams usage activity report..."
$usageRaw = Get-MgReportTeamActivityDetail -Period D90
$usageData = $usageRaw | ConvertFrom-Csv

# Create lookup by GroupId
$usageLookup = @{}
foreach ($row in $usageData) {
    if ($row.GroupId) {
        $usageLookup[$row.GroupId] = $row
    }
}

# Get all Teams (Groups with Team provisioned)
Write-Host "Retrieving all Teams..."
$teams = Get-MgGroup -All -Filter "resourceProvisioningOptions/Any(x:x eq 'Team')" -Property "Id,DisplayName,Mail"

$total = $teams.Count
$counter = 0
$report = @()

foreach ($team in $teams) {
    $counter++
    Write-Progress -Activity "Auditing Teams Sprawl" `
        -Status "Processing $counter of $total: $($team.DisplayName)" `
        -PercentComplete (($counter / $total) * 100)

    # Owners
    try {
        $owners = Get-MgGroupOwner -GroupId $team.Id -All
        $ownerCount = $owners.Count
        $ownerStatus = if ($ownerCount -gt 0) { "HasOwner" } else { "NoOwner" }
    }
    catch {
        $ownerCount = 0
        $ownerStatus = "Error"
    }

    # Activity
    $lastActivity = $null
    $inactive = "Unknown"

    if ($usageLookup.ContainsKey($team.Id)) {
        $activityRow = $usageLookup[$team.Id]
        if ($activityRow.LastActivityDate) {
            $lastActivity = [datetime]$activityRow.LastActivityDate
            $daysInactive = (New-TimeSpan -Start $lastActivity -End (Get-Date)).Days
            $inactive = if ($daysInactive -ge $InactiveDays) { "Yes" } else { "No" }
        }
        else {
            $inactive = "Yes"
        }
    }

    $report += [pscustomobject]@{
        TeamName        = $team.DisplayName
        GroupId         = $team.Id
        Mail            = $team.Mail
        OwnerCount      = $ownerCount
        OwnerStatus     = $ownerStatus
        LastActivity    = if ($lastActivity) { $lastActivity.ToString("yyyy-MM-dd") } else { "N/A" }
        Inactive90Days  = $inactive
    }
}

# Export
$report | Sort-Object Inactive90Days, OwnerStatus, TeamName | Export-Csv -Path $ReportPath -NoTypeInformation

# Summary
$totalTeams = $report.Count
$inactiveTeams = ($report | Where-Object Inactive90Days -eq "Yes").Count
$noOwnerTeams = ($report | Where-Object OwnerStatus -eq "NoOwner").Count

Write-Host ""
Write-Host "========== TEAMS SPRAWL SUMMARY =========="
Write-Host "Total Teams       : $totalTeams"
Write-Host "Inactive (>=90d)  : $inactiveTeams"
Write-Host "No Owners         : $noOwnerTeams"
Write-Host "=========================================="

Write-Host "Report saved to $ReportPath"

Disconnect-MgGraph
