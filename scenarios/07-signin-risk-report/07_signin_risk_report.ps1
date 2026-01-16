# 07_signin_risk_report.ps1
# Scenario: 07-signin-risk-report
# Description: Report risky sign-ins.

#Requires -Module Microsoft.Graph.Identity.SignIns

<#
.SYNOPSIS
Reports risky sign-ins from Microsoft Entra ID.

.DESCRIPTION
- Retrieves recent sign-in logs
- Filters sign-ins with risk levels or risk states
- Summarizes risky sign-ins by user, location, and risk type
- Exports CSV for governance and security review

Required Scopes:
AuditLog.Read.All
IdentityRiskEvent.Read.All
#>

param(
    [int]$DaysBack = 7,
    [string]$ReportPath = ("Signin_Risk_Report-{0}.csv" -f (Get-Date -Format 'yyyyMMdd'))
)

Write-Host "Connecting to Microsoft Graph..."
Connect-MgGraph -Scopes "AuditLog.Read.All","IdentityRiskEvent.Read.All" | Out-Null
Write-Host "Connected."

$since = (Get-Date).AddDays(-$DaysBack).ToString("o")
Write-Host "Retrieving sign-ins since $since..."

$signins = Get-MgAuditLogSignIn -All -Filter "createdDateTime ge $since"

$results = @()
$total = $signins.Count
$counter = 0

foreach ($s in $signins) {
    $counter++
    Write-Progress -Activity "Auditing Risky Sign-ins" `
        -Status "Processing $counter of $total" `
        -PercentComplete (($counter / $total) * 100)

    # Risk logic
    $isRisky = $false
    if ($s.RiskLevelDuringSignIn -and $s.RiskLevelDuringSignIn -ne "none") { $isRisky = $true }
    if ($s.RiskState -and $s.RiskState -ne "none") { $isRisky = $true }

    if (-not $isRisky) { continue }

    $results += [pscustomobject]@{
        UserPrincipalName = $s.UserPrincipalName
        AppDisplayName    = $s.AppDisplayName
        SignInDate        = $s.CreatedDateTime.ToString("yyyy-MM-dd HH:mm")
        IPAddress         = $s.IPAddress
        Location          = if ($s.Location) { "$($s.Location.City), $($s.Location.CountryOrRegion)" } else { "Unknown" }
        RiskLevel         = $s.RiskLevelDuringSignIn
        RiskState         = $s.RiskState
        RiskDetail        = $s.RiskDetail
        ClientApp         = $s.ClientAppUsed
        ConditionalAccess = $s.ConditionalAccessStatus
    }
}

# Export
$results | Export-Csv -Path $ReportPath -NoTypeInformation

# Summary
$totalRisky = $results.Count
$highRisk   = ($results | Where-Object RiskLevel -eq "high").Count
$mediumRisk = ($results | Where-Object RiskLevel -eq "medium").Count
$lowRisk    = ($results | Where-Object RiskLevel -eq "low").Count

Write-Host ""
Write-Host "========== SIGN-IN RISK SUMMARY =========="
Write-Host "Days Reviewed : $DaysBack"
Write-Host "Total Risky   : $totalRisky"
Write-Host "High Risk     : $highRisk"
Write-Host "Medium Risk   : $mediumRisk"
Write-Host "Low Risk      : $lowRisk"
Write-Host "=========================================="

Write-Host "Report saved to $ReportPath"
Disconnect-MgGraph
