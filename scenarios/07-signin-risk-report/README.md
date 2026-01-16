# 07-signin-risk-report

## Problem
Organizations often lack clear visibility into risky sign-ins across Microsoft 365.  
Without regular review, risky authentication attempts can go unnoticed, increasing the chance of account compromise.

## Why It Matters
Risky sign-ins directly impact:
- Security posture and Zero Trust strategy  
- Detection of compromised accounts  
- Conditional Access effectiveness  
- Incident response and investigations  

Regular reporting supports security operations, governance, and compliance.

## What This Script Does
- Connects to Microsoft Graph  
- Retrieves recent sign-in activity  
- Identifies sign-ins with elevated risk levels or risk states  
- Summarizes user, app, location, and risk details  
- Exports a governance-ready CSV report  

## How To Run

```powershell
pwsh ./07_signin_risk_report.ps1
```

You will be prompted to authenticate with permissions such as:
- AuditLog.Read.All  
- IdentityRiskEvent.Read.All  

## Output
Creates a CSV report named similar to:

```text
Signin_Risk_Report-YYYYMMDD.csv
```

The report includes:
- User principal name  
- Application used  
- Date and time of sign-in  
- IP address and location  
- Risk level and risk state  
- Conditional Access result  

## Safety
- This script is **read-only**  
- No changes are made to tenant configuration  
- Safe to run in production environments  
- Designed for security monitoring, governance, and compliance review  
