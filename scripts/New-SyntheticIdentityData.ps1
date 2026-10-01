# =========================================================
# Synthetic Identity Dataset Generator
# =========================================================
# Generates fictional employee identities for the
# Automated Identity Access Review project.
# =========================================================

$OutputFile = ".\data\employees.csv"

$FirstNames = @(
    "Alex","Jordan","Taylor","Morgan","Casey",
    "Jamie","Avery","Riley","Cameron","Sydney",
    "Drew","Parker","Quinn","Reese","Skyler",
    "Robin","Emerson","Hayden","Dakota","Logan"
)

$LastNames = @(
    "Anderson","Bennett","Carter","Davis","Ellis",
    "Foster","Garcia","Harris","Jackson","Kelly",
    "Lewis","Mitchell","Nelson","Owens","Perry",
    "Reed","Simmons","Turner","Walker","Young"
)

$Departments = @(
    "IT",
    "Finance",
    "HR",
    "Legal",
    "Marketing",
    "Sales",
    "Research",
    "Operations"
)

$DepartmentRoles = @{
    "IT"         = @("IT Analyst","Systems Analyst","Support Specialist")
    "Finance"    = @("Financial Analyst","Accountant","Finance Specialist")
    "HR"         = @("HR Specialist","Recruiter","HR Analyst")
    "Legal"      = @("Legal Analyst","Paralegal","Legal Specialist")
    "Marketing"  = @("Marketing Analyst","Marketing Coordinator","Content Specialist")
    "Sales"      = @("Sales Representative","Account Executive","Sales Analyst")
    "Research"   = @("Research Analyst","Research Associate","Data Analyst")
    "Operations" = @("Operations Analyst","Operations Specialist","Coordinator")
}

$Users = @()

for ($i = 1; $i -le 100; $i++) {

    $Department = Get-Random $Departments
    $JobTitle = Get-Random $DepartmentRoles[$Department]

    $FirstName = Get-Random $FirstNames
    $LastName = Get-Random $LastNames

    # Most identities should represent normal active employees.
    $Status = "Active"
    $Privileged = "False"
    $MFAEnabled = "True"

    # Generate recent activity by default.
    $DaysAgo = Get-Random -Minimum 1 -Maximum 61
    $LastLogin = (Get-Date).AddDays(-$DaysAgo).ToString("yyyy-MM-dd")

    # Standard department access
    $Groups = "$Department;VPN"

    # -----------------------------------------------------
    # Plant specific governance issues
    # -----------------------------------------------------

    # Terminated users retaining access
    if ($i -in 12, 27, 48, 73, 91) {
        $Status = "Terminated"
    }

    # Dormant active accounts
    if ($i -in 8, 34, 56, 82) {
        $LastLogin = (Get-Date).AddDays(-(Get-Random -Minimum 100 -Maximum 181)).ToString("yyyy-MM-dd")
    }

    # Privileged users without MFA
    if ($i -in 19, 64) {
        $Privileged = "True"
        $MFAEnabled = "False"
        $Groups += ";Administrators"
    }

    # Non-IT users with administrator access
    if ($i -in 25, 67, 88) {

        # Ensure these test identities are outside IT.
        if ($Department -eq "IT") {
            $Department = "Finance"
            $JobTitle = "Financial Analyst"
            $Groups = "Finance;VPN"
        }

        $Privileged = "True"
        $Groups += ";Administrators"
    }

    $Users += [PSCustomObject]@{
        EmployeeID = 2000 + $i
        Name       = "$FirstName $LastName"
        Department = $Department
        JobTitle   = $JobTitle
        Status     = $Status
        LastLogin  = $LastLogin
        Groups     = $Groups
        Privileged = $Privileged
        MFAEnabled = $MFAEnabled
    }
}

$Users |
    Export-Csv $OutputFile -NoTypeInformation

Write-Host ""
Write-Host "Synthetic identity dataset generated successfully."
Write-Host "Identities Generated: $($Users.Count)"
Write-Host "Output: $OutputFile"