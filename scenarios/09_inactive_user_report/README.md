# 09-inactive-user-report

## Problem
Organizations often accumulate user accounts that are no longer actively used.  
Without visibility, inactive accounts increase security risk and administrative overhead.

## Why It Matters
Inactive accounts can lead to:
- Increased attack surface  
- Unnecessary license costs  
- Compliance and audit findings  
- Poor identity lifecycle management  

Regular inactive-user reviews support security hygiene and operational efficiency.

## What This Script Does
- Connects to Microsoft Graph  
- Retrieves all users and their last sign-in activity  
- Calculates inactivity based on configurable days  
- Flags inactive users  
- Exports a governance-ready CSV report  

## How To Run

```powershell
pwsh ./09_inactive_user_report.ps1
```

You will be prompted to authenticate with permissions such as:
- User.Read.All  
- AuditLog.Read.All  

## Output
Creates a CSV report named similar to:

```text
Inactive_User_Report-YYYYMMDD.csv
```

The report includes:
- Display name and UPN  
- Account enabled status  
- User type  
- Last sign-in date  
- Inactive status flag  

## Safety
- This script is **read-only**  
- No changes are made to tenant configuration  
- Safe to run in production environments  
- Designed for governance, cleanup planning, and compliance audits  
