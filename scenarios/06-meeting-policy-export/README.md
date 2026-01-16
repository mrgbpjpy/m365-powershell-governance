# 06-meeting-policy-export

## Problem
Teams meeting policies control recording, chat, video, anonymous access, and sharing.  
Without visibility, organizations risk misconfigured meetings, compliance issues, and inconsistent user experience.

## Why It Matters
Meeting policies directly impact:
- Security (anonymous access, recording, chat controls)
- Compliance (recording and transcription)
- User experience (presenting, video, sharing)

Regular review ensures policies align with security and governance standards.

## What This Script Does
- Connects to Microsoft Graph  
- Retrieves all Teams meeting policies  
- Summarizes key meeting settings  
- Exports a governance-ready CSV report  

## How To Run

```powershell
pwsh ./06_meeting_policy_export.ps1
```

You will be prompted to authenticate with permission:
- Policy.Read.All

## Output
Creates a CSV report named similar to:

```text
Teams_Meeting_Policies-YYYYMMDD.csv
```

The report includes:
- Policy name and description  
- Recording and transcription settings  
- Chat and anonymous access settings  
- Video and sharing configuration  
- Presenter and bandwidth limits  

## Safety
- This script is **read-only**  
- No changes are made to Teams or tenant configuration  
- Safe to run in production environments  
- Designed for audit, governance, and compliance review  
