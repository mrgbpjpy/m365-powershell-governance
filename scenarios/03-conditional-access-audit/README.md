# 03-conditional-access-audit

## Problem
Organizations often enable Conditional Access without maintaining clear visibility into what policies exist, what they enforce, and who they affect. Over time, this leads to security gaps, redundant policies, and risky exclusions.

## Why It Matters
Conditional Access is one of the most critical security controls in Microsoft 365.  
Without regular review, organizations risk:
- Incomplete MFA coverage  
- Overly broad exclusions  
- Conflicting or unused policies  
- Weak governance visibility  

This audit supports security posture management, compliance reviews, and operational governance.

## What This Script Does
- Connects to Microsoft Graph  
- Retrieves all Conditional Access policies  
- Identifies whether policies enforce MFA  
- Summarizes user, group, and role targeting  
- Summarizes application targeting  
- Highlights key conditions used (locations, platforms, risk, devices, etc.)  
- Exports a governance-ready CSV report  

## How To Run

```powershell
pwsh ./03_conditional_access_audit.ps1
```

You will be prompted to authenticate to Microsoft Graph with the following permissions:
- Policy.Read.All  
- Directory.Read.All  

## Output
Creates a CSV report named similar to:

```text
ConditionalAccess_Audit-YYYYMMDD.csv
```

The report includes:
- Policy name and state  
- MFA enforcement status  
- Grant controls  
- User and group targeting  
- Application targeting  
- Conditions and session controls used  

## Safety
- This script is **read-only**  
- No changes are made to tenant configuration  
- Safe to run in production environments  
- Designed for audit, governance, and compliance reviews  
