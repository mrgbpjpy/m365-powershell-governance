# Accept parameters:
# - CsvPath: path to CSV file with user data
# - DryRun: if set, no real changes are made (simulation mode)
param(
    [string]$CsvPath = "users-sample.csv",
    [switch]$DryRun = $true
)

# ---------------- Configuration ----------------
# License SKU part number to assign to users
$DefaultLicenseSkuPartNumber = 'M365_E5'

# Microsoft 365 / Entra ID group to add users to
$DefaultGroupName = 'Employees'

# Usage location is required for license assignment
# Must be ISO 3166-1 alpha-2 format (e.g., US, CA, GB)
$UsageLocation = 'US'
# ------------------------------------------------

Write-Host "Connecting to Microsoft Graph..."

# Connect to Microsoft Graph with required permissions
# These scopes allow creating users, managing groups, and assigning licenses
Connect-MgGraph -Scopes `
    "User.ReadWrite.All", `
    "Group.ReadWrite.All", `
    "Directory.ReadWrite.All" | Out-Null

Write-Host "Connected."

# ---------------- Lookup Target Group ----------------
# Get the Entra ID group where new users will be added
$Group = Get-MgGroup -Filter "DisplayName eq '$DefaultGroupName'"

# Stop script if group is not found
if (-not $Group) {
    Write-Error "Group '$DefaultGroupName' not found. Exiting."
    exit
}

# ---------------- Lookup License SKU ----------------
# Find the license SKU object using its part number
$LicenseSku = Get-MgSubscribedSku -All |
    Where-Object SkuPartNumber -eq $DefaultLicenseSkuPartNumber

# Stop script if license SKU is not found
if (-not $LicenseSku) {
    Write-Error "License SKU '$DefaultLicenseSkuPartNumber' not found in your tenant subscriptions. Exiting."
    exit
}

# Store the SKU ID needed for license assignment
$LicenseSkuId = $LicenseSku.SkuId

# ---------------- Load Users ----------------
# Import users from the CSV file
# Expected columns: Email, DisplayName (or fields you map)
$users = Import-Csv $CsvPath

# Array to store provisioning results for reporting
$out = @()

# ---------------- Process Each User ----------------
foreach ($u in $users) {

    # Use email as the User Principal Name (UPN)
    $upn = $u.Email

    # Description of action based on DryRun or real execution
    $actionDescription = if ($DryRun) {
        "DRY-RUN: create, license, add to group for $upn"
    } else {
        "Provisioning user $upn"
    }

    Write-Host "`n--- $actionDescription ---"

    if (-not $DryRun) {
        try {
            # -------- Step 1: Create User --------
            $newUserParams = @{
                DisplayName       = $u.DisplayName
                UserPrincipalName = $upn
                MailNickname      = ($upn -split '@')[0]
                AccountEnabled    = $true
                UsageLocation     = $UsageLocation   # Required for licensing
                PasswordProfile   = @{
                    Password = "TemporaryPassword123!"
                    ForceChangePasswordNextSignIn = $true
                }
            }

            # Create the user in Entra ID
            $createdUser = New-MgUser @newUserParams
            Write-Host "✅ User created: $($createdUser.DisplayName)"

            # -------- Step 2: Assign License --------
            $licenseParams = @{
                UserId        = $createdUser.Id
                AddLicenses   = @{ SkuId = $LicenseSkuId }
                RemoveLicenses = @()
            }

            # Assign the license to the user
            Set-MgUserLicense @licenseParams
            Write-Host "✅ License assigned: $DefaultLicenseSkuPartNumber"

            # -------- Step 3: Add User to Group --------
            $groupMemberParams = @{
                GroupId = $Group.Id
                UserId  = $createdUser.Id
            }

            # Add user to the target group
            New-MgGroupMember @groupMemberParams
            Write-Host "✅ User added to group: $DefaultGroupName"

            # Mark status as success
            $status = "Success"
        }
        catch {
            # Catch any error during create, license, or group add
            Write-Error "❌ Failed to provision user $upn: $($_.Exception.Message)"
            $status = "Failed"
        }
    }
    else {
        # Dry-run mode: simulate actions without making changes
        Write-Host "⚠️ Dry run simulation complete for $upn."
        $status = "Dry Run"
    }

    # -------- Reporting --------
    # Add result to output report array
    $out += [pscustomobject]@{
        User   = $upn
        Action = $actionDescription
        Status = $status
        Date   = (Get-Date -Format "yyyy-MM-dd")
    }
}

# ---------------- Export Report ----------------
# Export provisioning results to CSV
$out | Export-Csv "output-sample.csv" -NoTypeInformation
Write-Host "`nProvisioning report generated in output-sample.csv."

# ---------------- Cleanup ----------------
# Disconnect from Microsoft Graph session
Disconnect-MgGraph
