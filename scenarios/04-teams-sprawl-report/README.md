# 04-teams-sprawl-report

## Problem
As Microsoft Teams usage grows, organizations often accumulate inactive Teams, orphaned Teams without owners, and unused collaboration spaces. This creates security risk, compliance gaps, and operational clutter.

## Why It Matters
Unmanaged Teams sprawl can lead to:
- Data exposure in abandoned Teams
- No accountability when owners leave
- Compliance and retention risks
- Increased support and administrative overhead

Regular sprawl audits support strong governance, lifecycle management, and security hygiene.

## What This Script Does
- Connects to Microsoft Graph  
- Retrieves all Teams and related M365 Groups  
- Identifies inactive Teams based on activity data  
- Detects Teams with missing or no owners  
- Exports a governance-ready CSV report  

## How To Run

```powershell
pwsh ./04_teams_sprawl_report.ps1
```

You will be prompted to authenticate to Microsoft Graph with permissions similar to:
- Group.Read.All  
- Team.ReadBasic.All  
- Reports.Read.All  

## Output
Creates a CSV report named similar to:

```text
Teams_Sprawl_Report-YYYYMMDD.csv
```

The report includes:
- Team name and group ID  
- Last activity date  
- Inactive status  
- Owner count and owner status  
- Flags for missing owners  

## Safety
- This script is **read-only**  
- No changes are made to Teams or Groups  
- Safe to run in production environments  
- Designed for governance, audit, and cleanup planning  
