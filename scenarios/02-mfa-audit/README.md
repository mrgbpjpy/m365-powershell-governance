# 02-mfa-audit

## Problem
Audit users without MFA and export report.

## Why It Matters
Security, governance, and operational efficiency in Microsoft 365.

## What This Script Does
- Connects to Microsoft Graph
- Collects relevant data
- Exports a CSV report

## How To Run
```powershell
pwsh ./02_mfa_audit.ps1
```

## Output
Creates `output-sample.csv`

## Safety
Read-only or dry-run mode.
