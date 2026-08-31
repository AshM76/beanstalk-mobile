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
| 1 | Ash (amehta76) | In-app account recovery: "Forgot password" and "Forgot username/email" links + flow on the login screen. Today there is no reset path in the app, and the backend exposes only `/api/auth/login` and `/api/auth/register` (no reset endpoint), which is what caused a real self-lockout requiring a manual bcrypt-hash edit on the Fly volume. Needs: (a) backend reset endpoint(s) — e.g. request-code-by-email + verify + set-new-password, hashing at bcrypt cost 10 to match signup; (b) login-screen UI entry points; (c) email delivery for the reset code/link. | High | Backlog |

## Tester Notes
| Tester | Device | Overall Rating | Key Feedback |
|--------|--------|----------------|--------------|
| | | /10 | |

---

## Severity Guide
- **High:** App crashes, can't complete core flow, data loss
- **Medium:** Feature broken but workaround exists
- **Low:** Visual glitch, minor UX issue, typo
