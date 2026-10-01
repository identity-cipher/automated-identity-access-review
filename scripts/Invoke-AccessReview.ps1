# =========================================================
# Automated Identity Access Review
# =========================================================
# Analyzes synthetic identity data for potential access risks.
#
# Access Review Rules:
# 1. Terminated account with active access
# 2. Dormant active account
# 3. Privileged account without MFA
# 4. Administrator access outside IT
# =========================================================


# ---------------------------------------------------------
# Configuration
# ---------------------------------------------------------

$InputFile = ".\data\employees.csv"
$OutputDirectory = ".\output"


# ---------------------------------------------------------
# Import Identity Data
# ---------------------------------------------------------

$Users = Import-Csv $InputFile

# Store identified access-review findings
$Findings = @()


# ---------------------------------------------------------
# Analyze Each Identity
# ---------------------------------------------------------

foreach ($User in $Users) {

    # -----------------------------------------------------
    # Rule 1: Terminated employee retaining access
    # -----------------------------------------------------

    if (
        $User.Status -eq "Terminated" -and
        $User.Groups
    ) {

        $Findings += [PSCustomObject]@{
            EmployeeID = $User.EmployeeID
            Name       = $User.Name
            Department = $User.Department
            Finding    = "Terminated Account With Active Access"
            Severity   = "High"
            Evidence   = $User.Groups
            Action     = "Disable account and remove group memberships"
        }
    }


    # -----------------------------------------------------
    # Rule 2: Dormant active account
    # -----------------------------------------------------

    $LastLogin = [datetime]$User.LastLogin
    $DaysInactive = ((Get-Date) - $LastLogin).Days

    if (
        $User.Status -eq "Active" -and
        $DaysInactive -gt 90
    ) {

        $Findings += [PSCustomObject]@{
            EmployeeID = $User.EmployeeID
            Name       = $User.Name
            Department = $User.Department
            Finding    = "Dormant Account"
            Severity   = "Medium"
            Evidence   = "$DaysInactive days since last login"
            Action     = "Review account activity and confirm access requirement"
        }
    }


    # -----------------------------------------------------
    # Rule 3: Privileged account without MFA
    # -----------------------------------------------------

    if (
        $User.Privileged -eq "True" -and
        $User.MFAEnabled -eq "False"
    ) {

        $Findings += [PSCustomObject]@{
            EmployeeID = $User.EmployeeID
            Name       = $User.Name
            Department = $User.Department
            Finding    = "Privileged Account Without MFA"
            Severity   = "Critical"
            Evidence   = "Privileged=True; MFAEnabled=False"
            Action     = "Require MFA and review privileged access"
        }
    }


    # -----------------------------------------------------
    # Rule 4: Administrator access outside IT
    # -----------------------------------------------------

    $GroupList = $User.Groups -split ";"

    if (
        $GroupList -contains "Administrators" -and
        $User.Department -ne "IT"
    ) {

        $Findings += [PSCustomObject]@{
            EmployeeID = $User.EmployeeID
            Name       = $User.Name
            Department = $User.Department
            Finding    = "Potential Excessive Privilege"
            Severity   = "High"
            Evidence   = "Member of Administrators group outside IT"
            Action     = "Review administrator access and validate business need"
        }
    }
}


# ---------------------------------------------------------
# Generate Access Review Report
# ---------------------------------------------------------

$Findings |
    Export-Csv "$OutputDirectory\access-review-report.csv" -NoTypeInformation


# ---------------------------------------------------------
# Generate Remediation Action Report
# ---------------------------------------------------------

$RemediationActions = $Findings |
    Select-Object `
        EmployeeID,
        Name,
        Department,
        Severity,
        Finding,
        @{Name="RecommendedAction"; Expression={$_.Action}}

$RemediationActions |
    Export-Csv "$OutputDirectory\remediation-actions.csv" -NoTypeInformation


# ---------------------------------------------------------
# Calculate Summary Statistics
# ---------------------------------------------------------

$CriticalCount = @(
    $Findings | Where-Object Severity -eq "Critical"
).Count

$HighCount = @(
    $Findings | Where-Object Severity -eq "High"
).Count

$MediumCount = @(
    $Findings | Where-Object Severity -eq "Medium"
).Count

# ---------------------------------------------------------
# Generate Executive Summary
# ---------------------------------------------------------

$Summary = @"
IDENTITY ACCESS REVIEW SUMMARY
==============================

Review Date: $(Get-Date -Format "yyyy-MM-dd")

Users Reviewed: $($Users.Count)
Total Findings: $($Findings.Count)

Severity Breakdown
------------------
Critical: $CriticalCount
High:     $HighCount
Medium:   $MediumCount

Controls Evaluated
------------------
1. Terminated accounts retaining access
2. Dormant active accounts
3. Privileged accounts without MFA
4. Administrator access outside IT

Summary
-------
The automated identity access review analyzed $($Users.Count) synthetic
employee identities and identified $($Findings.Count) access governance
findings.

Critical and high-severity findings should be prioritized for review and
remediation. Recommended remediation actions are available in the
remediation-actions.csv report.

This project uses synthetic identity data for demonstration purposes.
"@

$Summary |
    Out-File "$OutputDirectory\summary.txt"

# ---------------------------------------------------------
# Display Access Review Summary
# ---------------------------------------------------------

Write-Host ""
Write-Host "========================================"
Write-Host "       IDENTITY ACCESS REVIEW"
Write-Host "========================================"
Write-Host ""
Write-Host "Users Reviewed:      $($Users.Count)"
Write-Host "Findings Identified: $($Findings.Count)"
Write-Host ""
Write-Host "Critical: $CriticalCount"
Write-Host "High:     $HighCount"
Write-Host "Medium:   $MediumCount"
Write-Host ""
Write-Host "Reports Generated:"
Write-Host "$OutputDirectory\access-review-report.csv"
Write-Host "$OutputDirectory\remediation-actions.csv"
Write-Host "$OutputDirectory\summary.txt"
Write-Host ""
Write-Host "Review completed successfully."
Write-Host "========================================"