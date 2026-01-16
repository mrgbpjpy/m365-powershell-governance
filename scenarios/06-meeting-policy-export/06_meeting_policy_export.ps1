# 06_meeting_policy_export.ps1
# Scenario: 06-meeting-policy-export
# Description: Export Teams meeting policies.

#Requires -Module Microsoft.Graph.Teams

<#
.SYNOPSIS
Exports Microsoft Teams meeting policies.

.DESCRIPTION
- Retrieves all Teams meeting policies
- Summarizes key settings
- Exports CSV for governance review

Required Scopes:
Policy.Read.All
#>

param(
    [string]$ReportPath = ("Teams_Meeting_Policies-{0}.csv" -f (Get-Date -Format 'yyyyMMdd'))
)

Write-Host "Connecting to Microsoft Graph..."
Connect-MgGraph -Scopes "Policy.Read.All" | Out-Null
Write-Host "Connected."

Write-Host "Retrieving Teams meeting policies..."
$policies = Get-MgPolicyOnlineMeetingPolicy -All

$results = @()

foreach ($policy in $policies) {
    $results += [pscustomobject]@{
        PolicyName              = $policy.Identity
        Description             = $policy.Description
        AllowCloudRecording     = $policy.AllowCloudRecording
        AllowTranscription      = $policy.AllowTranscription
        AllowMeetingChat        = $policy.AllowMeetingChat
        AllowAnonymousJoin      = $policy.AllowAnonymousJoin
        AllowIPVideo            = $policy.AllowIPVideo
        AllowMeetNow            = $policy.AllowMeetNow
        MediaBitRateKb          = $policy.MediaBitRateKb
        ScreenSharingMode       = $policy.ScreenSharingMode
        WhoCanPresent           = $policy.WhoCanPresent
    }
}

$results | Export-Csv -Path $ReportPath -NoTypeInformation

Write-Host "Export complete. File saved to $ReportPath"

Disconnect-MgGraph
