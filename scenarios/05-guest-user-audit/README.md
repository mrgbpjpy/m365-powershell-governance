# 05-guest-user-audit

## Problem
Guest users often remain in Microsoft 365 long after collaboration ends.  
These accounts can become security risks if they are inactive, unmanaged, or lack MFA.

## Why It Matters
Unmanaged guest accounts can lead to:
- Data leakage to former partners or vendors  
- Compliance and audit failures  
- Increased risk of account compromise  
- Poor identity lifecycle management  

Regular guest audits support Zero Trust and strong governance.

## What This Script Does
- Connects to Microsoft Graph  
- Retrieves all Guest users  
- Checks last sign-in activity  
- Identifies inactive guests  
- Reviews registered MFA methods  
- Flags guests without strong MFA  
- Exports a governance-ready CSV report  

## How To Run

```powershell
pwsh ./05_guest_user_audit.ps1
```

You will be prompted to authenticate with permissions:
- User.Read.All  
- UserAuthenticationMethod.Read.All  
- AuditLog.Read.All  

## Output
Creates a CSV report named similar to:

```text
Guest_User_Audit-YYYYMMDD.csv
```

The report includes:
- Display name and UPN  
- Guest type  
- Last sign-in date  
- Inactivity status  
- MFA registration status  
- Registered methods  

## Safety
- This script is **read-only**  
- No changes are made to tenant configuration  
- Safe for production use  
- Designed for security, governance, and compliance audits  
