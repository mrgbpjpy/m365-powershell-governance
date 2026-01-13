#Requires -Module Microsoft.Graph.Identity.SignIns, Microsoft.Graph.Users, Microsoft.Graph.Identity.DirectoryManagement

param(
    [string]$ReportPath = ("MFA_Registration_Audit-{0}.csv" -f (Get-Date -Format 'yyyyMMdd')),
    [switch]$IncludeGuests
)

Write-Host "Connecting to Microsoft Graph..."
# Requires: User.Read.All, UserAuthenticationMethod.Read.All, AuditLog.Read.All (optional for SignInActivity)
Connect-MgGraph -Scopes "User.Read.All","UserAuthenticationMethod.Read.All","AuditLog.Read.All" | Out-Null
Write-Host "Connected successfully."

# Retrieve users (include SignInActivity for last sign-in)
Write-Host "Retrieving user list..."
$props = "Id,DisplayName,UserPrincipalName,UserType,SignInActivity"
$users = Get-MgUser -All -Property $props

if (-not $IncludeGuests) {
    $users = $users | Where-Object { $_.UserType -ne "Guest" }
}

$mfaReport = @()
$totalUsers = $users.Count
$counter = 0

Write-Host "Starting MFA registration audit for $totalUsers users..."

foreach ($user in $users) {
    $counter++
    Write-Progress -Activity "Auditing MFA Registration" -Status "Processing $counter of $totalUsers: $($user.UserPrincipalName)" -PercentComplete (($counter / $totalUsers) * 100)

    try {
        # Get authentication methods registered for the user
        $authMethods = Get-MgUserAuthenticationMethod -UserId $user.Id

        # Track strong authentication methods
        $hasStrongMethod = $false
        $methodsList = @()

        foreach ($method in $authMethods) {
            $type = $method.'@odata.type'
            switch -Regex ($type) {
                'microsoftAuthenticatorAuthenticationMethod' { $hasStrongMethod = $true; $methodsList += 'MicrosoftAuthenticator' }
                'phoneAuthenticationMethod'                 { $hasStrongMethod = $true; $methodsList += 'Phone' }
                'fido2AuthenticationMethod'                 { $hasStrongMethod = $true; $methodsList += 'FIDO2' }
                'softwareOathAuthenticationMethod'          { $hasStrongMethod = $true; $methodsList += 'SoftwareOATH' }
                'windowsHelloForBusinessAuthenticationMethod' { $hasStrongMethod = $true; $methodsList += 'WindowsHello' }
                'temporaryAccessPassAuthenticationMethod'   { $methodsList += 'TAP' }
                default                                      { }
            }
        }

        # IMPORTANT: This script reports REGISTRATION status, not enforcement
        $registrationStatus = if ($hasStrongMethod) { "HasStrongMethod" } else { "NoStrongMethod" }
        $lastSignIn = $user.SignInActivity.LastSignInDateTime

        $mfaReport += [pscustomobject]@{
            DisplayName       = $user.DisplayName
            UserPrincipalName = $user.UserPrincipalName
            UserType          = $user.UserType
            RegistrationStatus= $registrationStatus
            RegisteredMethods = if ($methodsList.Count) { ($methodsList | Sort-Object -Unique) -join ", " } else { "None" }
            LastSignIn        = if ($lastSignIn) { $lastSignIn.ToString("yyyy-MM-dd HH:mm") } else { "N/A" }
        }
    }
    catch {
        Write-Error "Error processing user $($user.UserPrincipalName): $($_.Exception.Message)"
        $mfaReport += [pscustomobject]@{
            DisplayName       = $user.DisplayName
            UserPrincipalName = $user.UserPrincipalName
            UserType          = $user.UserType
            RegistrationStatus= "Error"
            RegisteredMethods = "N/A"
            LastSignIn        = "N/A"
        }
    }
}

# Export the results to a CSV file
$mfaReport | Sort-Object RegistrationStatus, UserPrincipalName | Export-Csv -Path $ReportPath -NoTypeInformation
Write-Host "Audit complete. Report saved to $ReportPath"

Disconnect-MgGraph
