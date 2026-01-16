# 03_conditional_access_audit.ps1
# Scenario: 03-conditional-access-audit
# Description: Summarize Conditional Access policies.

#Requires -Module Microsoft.Graph.Identity.SignIns, Microsoft.Graph.Identity.DirectoryManagement

<#
.SYNOPSIS
Summarizes all Entra ID (Azure AD) Conditional Access policies.

.DESCRIPTION
Exports Conditional Access policies and highlights:
- Policy state
- MFA enforcement
- User and group targeting
- App targeting
- Core conditions used

This is a design and enforcement visibility script — not a user compliance script.

Required Scopes:
Policy.Read.All
Directory.Read.All
#>

param(
    [string]$ReportPath = ("ConditionalAccess_Audit-{0}.csv" -f (Get-Date -Format 'yyyyMMdd'))
)

Write-Host "Connecting to Microsoft Graph..."
Connect-MgGraph -Scopes "Policy.Read.All","Directory.Read.All" | Out-Null
Write-Host "Connected successfully."

Write-Host "Retrieving Conditional Access policies..."
$policies = Get-MgIdentityConditionalAccessPolicy -All

$report = @()
$total = $policies.Count
$counter = 0

foreach ($policy in $policies) {
    $counter++
    Write-Progress -Activity "Auditing Conditional Access Policies" `
        -Status "Processing $counter of $total: $($policy.DisplayName)" `
        -PercentComplete (($counter / $total) * 100)

    $users = $policy.Conditions.Users
    $apps  = $policy.Conditions.Applications
    $grant = $policy.GrantControls

    # Detect MFA enforcement
    $enforcesMfa = $false
    if ($grant.BuiltInControls -contains "mfa") {
        $enforcesMfa = $true
    }

    # User targeting summary
    $userTarget = @()
    if ($users.IncludeUsers)   { $userTarget += "IncludeUsers:$($users.IncludeUsers -join ';')" }
    if ($users.ExcludeUsers)   { $userTarget += "ExcludeUsers:$($users.ExcludeUsers -join ';')" }
    if ($users.IncludeGroups)  { $userTarget += "IncludeGroups:$($users.IncludeGroups -join ';')" }
    if ($users.ExcludeGroups)  { $userTarget += "ExcludeGroups:$($users.ExcludeGroups -join ';')" }
    if ($users.IncludeRoles)   { $userTarget += "IncludeRoles:$($users.IncludeRoles -join ';')" }
    if ($users.ExcludeRoles)   { $userTarget += "ExcludeRoles:$($users.ExcludeRoles -join ';')" }
    if ($users.IncludeGuestsOrExternalUsers) { $userTarget += "Guests:Included" }

    # App targeting summary
    $appTarget = @()
    if ($apps.IncludeApplications) { $appTarget += "IncludeApps:$($apps.IncludeApplications -join ';')" }
    if ($apps.ExcludeApplications) { $appTarget += "ExcludeApps:$($apps.ExcludeApplications -join ';')" }
    if ($apps.IncludeUserActions)  { $appTarget += "UserActions:$($apps.IncludeUserActions -join ';')" }

    # Conditions used summary
    $conditions = $policy.Conditions
    $conditionList = @()
    if ($conditions.Locations.IncludeLocations) { $conditionList += "Locations" }
    if ($conditions.Platforms.IncludePlatforms) { $conditionList += "Platforms" }
    if ($conditions.ClientAppTypes)             { $conditionList += "ClientApps" }
    if ($conditions.SignInRiskLevels)           { $conditionList += "SignInRisk" }
    if ($conditions.UserRiskLevels)             { $conditionList += "UserRisk" }
    if ($conditions.Devices)                    { $conditionList += "Devices" }

    # Session controls summary
    $sessionSummary = if ($policy.SessionControls) {
        ($policy.SessionControls.PSObject.Properties.Name -join ", ")
    } else {
        "None"
    }

    $report += [pscustomobject]@{
        PolicyName     = $policy.DisplayName
        State          = $policy.State
        EnforcesMFA    = if ($enforcesMfa) { "Yes" } else { "No" }
        GrantControls  = if ($grant.BuiltInControls) { ($grant.BuiltInControls -join ", ") } else { "None" }
        UserTargeting  = if ($userTarget.Count) { $userTarget -join " | " } else { "All Users" }
        AppTargeting   = if ($appTarget.Count) { $appTarget -join " | " } else { "All Apps" }
        ConditionsUsed = if ($conditionList.Count) { $conditionList -join ", " } else { "None" }
        SessionControls= $sessionSummary
    }
}

$report | Export-Csv -Path $ReportPath -NoTypeInformation

# ===== Summary =====
$totalPolicies = $report.Count
$enabled  = ($report | Where-Object State -eq "enabled").Count
$disabled = ($report | Where-Object State -eq "disabled").Count
$mfaCount = ($report | Where-Object EnforcesMFA -eq "Yes").Count

Write-Host ""
Write-Host "====== CONDITIONAL ACCESS SUMMARY ======"
Write-Host "Total Policies : $totalPolicies"
Write-Host "Enabled        : $enabled"
Write-Host "Disabled       : $disabled"
Write-Host "MFA Policies   : $mfaCount"
Write-Host "======================================="

Write-Host "Audit complete. Report saved to $ReportPath"

Disconnect-MgGraph
