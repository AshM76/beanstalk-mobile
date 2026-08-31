# Beanstalk Beta Feedback Tracker

## App URL: https://beanstalk-vtrading.web.app

---

## Bug Reports
| # | Screen | Description | Severity | Status |
|---|--------|-------------|----------|--------|
| 1 | iOS home screen | App icon reads as a generic "leaf," not a beanstalk. Root cause: the source art `assets/icon/icon.png` is a minimal white sprout on green (thin stem + round seed-head + two side ovals). At home-screen tile size the stem disappears and only the two ovals register, so it looks like a leaf. iOS is generating correctly from this image — the artwork is the problem, not the build. Fix: replace `assets/icon/icon.png` with a clearer beanstalk silhouette (more stalk, climbing leaves, stronger contrast), then regenerate with `flutter pub run flutter_launcher_icons` and rebuild. | Low | Open |

## Feature Requests
| # | Requested By | Description | Priority | Status |
|---|-------------|-------------|----------|--------|
| 1 | Ash (amehta76) | In-app account recovery: "Forgot password" flow on the login screen. Login is by email (no separate username), so "forgot username" = use your signup email — called out in the UI copy. **Implemented:** backend `POST /api/auth/password/forgot` + `/reset` (6-digit code, bcrypt-hashed, 15-min TTL, attempt cap, cost-10 rehash) in `beanstalk-api` (PR pending); Flutter "Forgot password?" link + 2-step `ForgotPasswordPage` here. Best-effort email; in demo (no SMTP) the code is returned/shown as `dev_code`. **Follow-up:** add `BEANSTALK_ACCOUNT_PASS` (Gmail app password) Fly secret to enable real email delivery. | High | In Progress (PRs open) |

## Tester Notes
| Tester | Device | Overall Rating | Key Feedback |
|--------|--------|----------------|--------------|
| | | /10 | |

---

## Severity Guide
- **High:** App crashes, can't complete core flow, data loss
- **Medium:** Feature broken but workaround exists
- **Low:** Visual glitch, minor UX issue, typo
