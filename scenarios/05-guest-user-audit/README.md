# 05-guest-user-audit

## Problem
Audit guest users and MFA/inactivity.

## Why It Matters
Security, governance, and operational efficiency in Microsoft 365.

## What This Script Does
- Connects to Microsoft Graph
- Collects relevant data
- Exports a CSV report

## How To Run
```powershell
pwsh ./05_guest_user_audit.ps1
```

## Output
Creates `output-sample.csv`

## Safety
Read-only or dry-run mode.
