# 08-data-access-audit

## Problem
Organizations often lack visibility into who is accessing files across SharePoint and OneDrive.  
Without regular review, unauthorized or unusual access can go unnoticed.

## Why It Matters
File access visibility supports:
- Security monitoring and incident response  
- Data loss prevention and compliance  
- Governance of collaboration spaces  
- Operational oversight  

Regular audits reduce risk and improve accountability.

## What This Script Does
- Connects to Microsoft Graph  
- Retrieves recent audit log events related to file access  
- Focuses on SharePoint and OneDrive activity  
- Captures user, resource, time, and IP details  
- Exports a governance-ready CSV report  

## How To Run

```powershell
pwsh ./08_data_access_audit.ps1
```

You will be prompted to authenticate with permissions such as:
- AuditLog.Read.All  
- User.Read.All  

## Output
Creates a CSV report named similar to:

```text
Data_Access_Audit-YYYYMMDD.csv
```

The report includes:
- Activity date and time  
- User principal name and ID  
- File or resource accessed  
- Resource type  
- IP address  
- Result of the action  

## Safety
- This script is **read-only**  
- No changes are made to tenant configuration  
- Safe to run in production environments  
- Designed for security, governance, and compliance audits  
