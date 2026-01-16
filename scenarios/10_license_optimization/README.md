# 10-license-optimization

## Problem
Organizations often assign licenses that are no longer actively used.  
Without visibility, unused licenses increase cost and complicate governance.

## Why It Matters
Unused or underused licenses lead to:
- Unnecessary subscription spend  
- Inaccurate capacity planning  
- Poor identity and access governance  
- Audit and compliance gaps  

Regular review supports cost optimization and security hygiene.

## What This Script Does
- Connects to Microsoft Graph  
- Retrieves all licensed users  
- Checks last sign-in activity  
- Flags users with licenses who are inactive  
- Exports a governance-ready CSV report  

## How To Run

```powershell
pwsh ./10_license_optimization.ps1
```

You will be prompted to authenticate with permissions such as:
- User.Read.All  
- Directory.Read.All  
- AuditLog.Read.All  

## Output
Creates a CSV report named similar to:

```text
License_Optimization-YYYYMMDD.csv
```

The report includes:
- Display name and UPN  
- Account enabled status  
- Last sign-in date  
- Inactive status flag  
- License count per user  

## Safety
- This script is **read-only**  
- No changes are made to tenant configuration  
- Safe to run in production environments  
- Designed for cost optimization, governance, and compliance audits  
