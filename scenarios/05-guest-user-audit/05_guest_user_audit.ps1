# 05_guest_user_audit.ps1
# Scenario: 05-guest-user-audit
# Description: Audit guest users and MFA/inactivity.

#Requires -Module Microsoft.Graph.Users, Microsoft.Graph.Identity.SignIns, Microsoft.Graph.Identity.DirectoryManagement

<#
.SYNOPSIS
Audits guest users for inactivity and MFA registration.

.DESCRIPTION
- Retrieves all guest users
- Checks last sign-in activity
- Flags inactive guests
- Reviews authentication methods
- Identifies guests without strong MFA
- Exports CSV for governance review

Required Scopes:
User.Read.All
UserAuthenticationMethod.Read.All
AuditLog.Read.All
#>

param(
    [int]$InactiveDays = 90,
    [string]$ReportPath = ("Guest_User_Audit-{0}.csv" -f (Get-Date -Format 'yyyyMMdd'))
)

Write-Host "Connecting to Microsoft Graph..."
Connect-MgGraph -Scopes "User.Read.All","UserAuthenticationMethod.Read.All","AuditLog.Read.All" | Out-Null
Write-Host "Connected."

Write-Host "Running scenario: 05-guest-user-audit"
$results = @()

# Get guest users
Write-Host "Retrieving guest users..."
$props = "Id,DisplayName,UserPrincipalName,UserType,SignInActivity"
$guests = Get-MgUser -All -Property $props | Where-Object { $_.UserType -eq "Guest" }

$total = $guests.Count
$counter = 0

foreach ($user in $guests) {
    $counter++
    Write-Progress -Activity "Auditing Guest Users" `
        -Status "Processing $counter of $total: $($user.UserPrincipalName)" `
        -PercentComplete (($counter / $total) * 100)

    # Inactivity check
    $lastSignIn = $user.SignInActivity.LastSignInDateTime
    if ($lastSignIn) {
        $daysInactive = (New-TimeSpan -Start $lastSignIn -End (Get-Date)).Days
        $inactive = if ($daysInactive -ge $InactiveDays) { "Yes" } else { "No" }
    } else {
        $inactive = "Yes"
    }

    # MFA registration check
    try {
        $methods = Get-MgUserAuthenticationMethod -UserId $user.Id
        $hasStrong = $false
        $methodList = @()

        foreach ($m in $methods) {
            $type = $m.'@odata.type'
            switch -Regex ($type) {
                'microsoftAuthenticatorAuthenticationMethod'   { $hasStrong = $true; $methodList += 'MicrosoftAuthenticator' }
                'phoneAuthenticationMethod'                   { $hasStrong = $true; $methodList += 'Phone' }
                'fido2AuthenticationMethod'                   { $hasStrong = $true; $methodList += 'FIDO2' }
                'softwareOathAuthenticationMethod'            { $hasStrong = $true; $methodList += 'SoftwareOATH' }
                'windowsHelloForBusinessAuthenticationMethod' { $hasStrong = $true; $methodList += 'WindowsHello' }
                'temporaryAccessPassAuthenticationMethod'     { $methodList += 'TemporaryAccessPass' }
                default { }
            }
        }

        $mfaStatus = if ($hasStrong) { "HasStrongMFA" } else { "NoStrongMFA" }
    }
    catch {
        $mfaStatus = "Error"
        $methodList = @("N/A")
    }

    $results += [pscustomobject]@{
        DisplayName       = $user.DisplayName
        UserPrincipalName = $user.UserPrincipalName
        LastSignIn        = if ($lastSignIn) { $lastSignIn.ToString("yyyy-MM-dd") } else { "N/A" }
        Inactive90Days    = $inactive
        MFAStatus         = $mfaStatus
        RegisteredMethods = ($methodList | Sort-Object -Unique) -join ", "
    }
}

# Export report
$results | Sort-Object Inactive90Days, MFAStatus, UserPrincipalName |
    Export-Csv -Path $ReportPath -NoTypeInformation

# Summary
$totalGuests = $results.Count
$inactiveGuests = ($results | Where-Object Inactive90Days -eq "Yes").Count
$noMfaGuests = ($results | Where-Object MFAStatus -eq "NoStrongMFA").Count

Write-Host ""
Write-Host "========== GUEST USER AUDIT SUMMARY =========="
Write-Host "Total Guests     : $totalGuests"
Write-Host "Inactive Guests  : $inactiveGuests"
Write-Host "No Strong MFA    : $noMfaGuests"
Write-Host "=============================================="

Write-Host "Report exported to $ReportPath"
Disconnect-MgGraph
