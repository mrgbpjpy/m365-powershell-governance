# 01-bulk-user-provisioning

## Problem
Provision users from CSV, assign licenses, add to groups.

## Why It Matters
Security, governance, and operational efficiency in Microsoft 365.

## What This Script Does
- Connects to Microsoft Graph
- Collects relevant data
- Exports a CSV report

## How To Run
```powershell
pwsh ./01_bulk_user_provisioning.ps1
```

## Output
Creates `output-sample.csv`

## Safety
Read-only or dry-run mode.
