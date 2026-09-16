# Contest Recap — Mobile Ship Guide

Companion to the hub runbook (`CONTEST_RECAP_DEPLOY.md` in **beanstalk-api**),
covering just the mobile app's part: shipping the player-facing **Recap**
screen. Read the hub runbook first — it has the API/BigQuery steps this depends
on.

## What the app adds

- A **"See the Contest Recap"** card on a concluded contest's **Details** tab.
- The **Recap screen** (`lib/pages/contests/recap_page.dart`): Cash's headline
  and market recap, highlight cards, the **benchmark scoreboard** (% who beat
  the market / savings), lessons, and a sign-off — reusing the leaderboard's
  ghost-benchmark colors.
- Each player's **private mini-recap** ("Your recap"): their return, Beat
  Market / Beat Savings chips, and an encouraging line. Lazy-loaded after the
  group recap.

## What it depends on (do the hub runbook first)

The app is a thin client over the API. Before a build is useful:

1. The **API is deployed** with the recap endpoints (`GET /api/contests/:id/recap`
   and `.../recap/me`), and `ANTHROPIC_API_KEY` is set.
2. **Migrations 011 & 012** have run.
3. A contest has a **published** recap — until an admin publishes one, the
   screen shows a friendly "the recap is still growing" state (a `GET .../recap`
   returns 404, which the app treats as "not ready", not an error).

There is **no recap-specific client configuration**. The app finds the API via
the usual `--dart-define=API_BASE_URL`, which defaults to the production Fly
host; nothing new to set.

## Ship steps

```bash
# 1. From beanstalk-mobile, on merged main
flutter pub get

# 2. The real gate — repo CI (GitGuardian) does NOT compile Dart, so run this.
flutter analyze        # must be clean

# 3. Bump the build number (last shipped was 1.0.0+8)
#    pubspec.yaml:  version: 1.0.0+9

# 4. Sanity-check against a real device/simulator if you like
flutter run -d chrome  # or a device
```

Then build and ship from the Mac exactly as before:

```bash
flutter build ipa
# → upload to App Store Connect (Transporter or Xcode Organizer), release to
#   TestFlight. See docs/testflight/ for the "What to Test" notes convention.
```

Add a "What to Test" note for the recap (see `docs/testflight/` for the format):
*"Finish (or open) a concluded contest → tap 'See the Contest Recap' on its
Details tab. You'll see the group recap once an admin has published it, plus
your own private mini-recap."*

## What testers see

- On a **concluded** contest's Details tab: the **See the Contest Recap** card.
- Tapping it opens the Recap screen. If no recap is published yet → the
  "still growing" state (expected). Once published → the full group recap.
- If they were **in** the contest, their **personal** card appears below the
  headline (it generates on first open, so a brief "Cash is writing your
  recap…" placeholder is normal).

## Related

- **Hub runbook:** `CONTEST_RECAP_DEPLOY.md` (beanstalk-api) — the full
  migrations + secrets + smoke-test flow.
- **Web admin:** `RECAP_ADMIN_DEPLOY.md` (beanstalk-web) — how an admin
  generates and publishes a recap.
- **Tester quick-start:** `docs/TESTER_GUIDE.md`.
