
# 02-mfa-audit

## Problem
Security teams need visibility into which users have registered strong authentication methods (e.g., Microsoft Authenticator, Phone, FIDO2) to support MFA readiness. This script audits **registration status** (not enforcement) across Microsoft Entra ID and exports a report.

## Why It Matters
Knowing who has registered strong auth methods helps:
- Reduce MFA enrollment gaps
- Prepare for Conditional Access enforcement
- Identify risky or unmanaged identities
- Support audits and compliance reporting

## What This Script Does
- **Authenticates** to Microsoft Graph with least-privileged read scopes
- **Retrieves** all users (optionally excluding guests)
- **Queries** each user’s registered authentication methods
- **Detects** strong methods:
  - Microsoft Authenticator
  - Phone
  - FIDO2
  - Software OATH
  - Windows Hello for Business
  - Temporary Access Pass (reported, not counted as strong factor)
- **Labels** users as:
  - `HasStrongMethod`
  - `NoStrongMethod`
- **Captures** last sign-in (when available)
- **Exports** a timestamped CSV report

> ⚠️ Note: This script reports **registration status**, not whether MFA is enforced at sign-in. Enforcement is controlled by Conditional Access or legacy per-user MFA.

## Prerequisites
Install Microsoft Graph PowerShell SDK:

```powershell
Install-Module -Name Microsoft.Graph -Scope CurrentUser
```

Required permissions/scopes:
- `User.Read.All`
- `UserAuthenticationMethod.Read.All`
- `AuditLog.Read.All` (for SignInActivity)

## How To Run

### Default (exclude guests)
```powershell
pwsh ./02-mfa-audit.ps1
```

### Include guest users
```powershell
pwsh ./02-mfa-audit.ps1 -IncludeGuests
```

### Custom output path
```powershell
pwsh ./02-mfa-audit.ps1 -ReportPath "MFA_Report.csv"
```

## Output
Creates a CSV like:

| DisplayName | UserPrincipalName | UserType | RegistrationStatus | RegisteredMethods | LastSignIn |
|-------------|-------------------|----------|---------------------|-------------------|------------|
| John Doe | john@contoso.com | Member | HasStrongMethod | MicrosoftAuthenticator, FIDO2 | 2026-01-10 09:14 |
| Jane Smith | jane@contoso.com | Member | NoStrongMethod | None | N/A |

## Safety
- Read-only operations
- No changes made to tenant
- Safe for production auditing

## Interview Talking Points
- Distinguishes **registration vs enforcement**
- Uses Microsoft Graph SDK (future-proof vs legacy MSOnline)
- Supports large tenants with progress reporting
- Designed for governance and security posture reviews
