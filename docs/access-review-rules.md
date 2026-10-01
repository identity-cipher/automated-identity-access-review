# Identity Access Review Rules

## Rule 1: Terminated Account With Active Access
Condition:
- Employee status is Terminated
- Employee still has group memberships

Severity: High

Recommended Action:
Disable the account and remove remaining group memberships.

---

## Rule 2: Dormant Active Account
Condition:
- Employee status is Active
- Last login occurred more than 90 days ago

Severity: Medium

Recommended Action:
Review account activity and confirm whether access is still required.

---

## Rule 3: Privileged Account Without MFA
Condition:
- Privileged access is True
- MFA is False

Severity: Critical

Recommended Action:
Require MFA and review privileged access.

---

## Rule 4: Potential Excessive Privilege
Condition:
- User belongs to the Administrators group
- User's department is not IT

Severity: High

Recommended Action:
Review administrator access and validate the business requirement.