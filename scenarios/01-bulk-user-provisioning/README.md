# 01-bulk-user-provisioning

## Problem
Automate the provisioning of multiple users from a CSV file into Microsoft 365, assigning specific licenses (`M365_E5`), and adding them to a default group (`Employees`) using the Microsoft Graph API.

## Why It Matters
This script ensures consistency, improves security through standardized group membership and licensing, and significantly enhances operational efficiency for user onboarding in Microsoft 365 environments.

## What This Script Does
* **Authenticates** and connects to the Microsoft Graph API.
* **Reads** user details (`DisplayName`, `Email`) from `users-sample.csv`.
* **Creates** new M365 user accounts.
* **Assigns** the specified default license (`M365_E5`).
* **Adds** created users to the target group (`Employees`).
* **Handles** errors during the provisioning process (`try...catch`).
* **Generates** a detailed execution report (`output-sample.csv`).
* **Supports** a `DryRun` mode to simulate actions without making changes.

## Prerequisites
Before running, ensure you have the **Microsoft Graph PowerShell SDK** installed and have sufficient permissions in your M365 tenant:

```powershell
# Install the necessary module
Install-Module -Name Microsoft.Graph -Scope CurrentUser

# Required Azure AD App Permissions:
# User.ReadWrite.All
# Group.ReadWrite.All
# Directory.ReadWrite.All
```

## How To Run
The script can be run in two modes:

### 1) Dry Run (Default)
This simulates the user creation process and generates the report without making any changes to your M365 tenant.

```powershell
pwsh ./provision-users.ps1
# or explicitly
pwsh ./provision-users.ps1 -DryRun:$true
```

### 2) Live Execution
This mode executes the actual creation, licensing, and group additions.

```powershell
pwsh ./provision-users.ps1 -DryRun:$false
```

### Example with Custom CSV Path
You can specify a different input file using the `-CsvPath` parameter:

```powershell
pwsh ./provision-users.ps1 -CsvPath "new-users.csv" -DryRun:$false
```

## Input File Format
The input CSV (`users-sample.csv`) must include `Email` and `DisplayName` columns:

| Email | DisplayName |
|---|---|
| john.doe@contoso.com | John Doe |
| jane.doe@contoso.com | Jane Doe |

## Output
Creates `output-sample.csv` detailing every action, status (Success, Failed, Dry Run), and date of execution.

## Safety
The script defaults to a read-only/dry-run mode to prevent accidental changes. Live execution requires explicit use of the `-DryRun:$false` switch and will prompt for authentication permissions.

The script also defines a temporary password which is forced to be changed upon the user's first sign-in for security purposes.

---

To use this, save this file as `README.md` in the `01-bulk-user-provisioning` folder of your repository.
