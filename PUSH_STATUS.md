# Push Notifications — status & next steps

**State: iOS push token NOT registering on device. Root cause not yet found.**
Everything on the backend/config side is verified correct; the iOS app fails to
obtain/register an FCM token and (as of build 12) reports nothing back, meaning
push init errors out on-device before it can report.

Branch: `feat/push-notifications` (mobile) — merged to `main` on beanstalk-api.
Current build: **1.0.0+12** (contains a temporary diagnostic).

## What's done & verified ✅
- **Backend** (`beanstalk-api`, on `main`, deployed to Fly):
  - `deviceToken.service.js` per-user token registry (in-memory).
  - `POST /api/notifications/register-token`, `/unregister-token`, `/test`
    (auth); admin-guarded contest senders; lazy/guarded Firebase init.
  - Verified live: registering a fake token then `/test` returns `failed:1`
    (backend + FCM send path work).
  - `FIREBASE_*` secrets set on Fly; deploy preserves data (volume snapshot).
- **Android**: firebase_core/messaging + flutter_local_notifications;
  google-services plugin + `google-services.json`; POST_NOTIFICATIONS;
  core-library desugaring. **Debug APK builds clean.** (On-device test never
  completed — emulator too heavy for this Mac.)
- **iOS**: `GoogleService-Info.plist` in Runner target; Push Notifications
  capability + `Runner.entitlements` (aps-environment); `remote-notification`
  background mode. Signed IPA verified: **production** aps-environment, plist
  bundled, IS_GCM_ENABLED=true.
- **APNs key** `3ZU8P9DBAX` (Team `NDRF4GQ9KH`) confirmed uploaded to the
  correct Firebase project (beanstalk-vtrading) Cloud Messaging.
- **Bug fixed**: `FirebaseApp.configure()` added to `AppDelegate.swift` — device
  logs showed `[FirebaseCore] No app has been configured yet` when
  FirebaseMessaging swizzled APNs at launch (build 11 removed that error).

## The open problem ❌
iOS `getToken()` never yields a token. As of build 12 the app registered
**nothing** for the test user (`GET /api/notifications/debug-tokens` → empty),
so `PushService.start()` / Firebase init is likely throwing on-device before the
diagnostic can POST.

## Why it's hard to see
- Release builds don't surface Flutter `debugPrint`/`[Push]` logs on-device.
- Native Firebase os_log lines get deduplicated on relaunch.
- **Developer Mode will not appear** on the test iPhone (iOS 26.6.2) even wired +
  after a dev-install attempt — so a debug `flutter run` (which would show live
  logs) can't be used.

## Next step (planned) → bulletproof diagnostic
Make the app report its status **unconditionally**, independent of login/JWT:
1. Backend: add an **unauthenticated** `POST /api/notifications/debug-report`
   `{ deviceId, stage, apns, fcm, error }` that stores the last report; add a
   read endpoint. (No auth so it works even if login/init is the failure.)
2. App: wrap `PushService.start()` in try/catch and POST a debug-report at each
   stage (firebase-init, permission, apns-token, fcm-token, error) via a plain
   `http.post` (not `ApiService.registerPushToken`, which needs a JWT).
3. One clean TestFlight install → read the report → the failing stage names the
   fix.

## Temporary things to REMOVE once push is verified
- Backend: `debug-tokens` endpoint (`notifications.route.js` + controller).
- App: the `DIAG …` marker logic in `push_service.dart` `_registerToken()`.
- (And whatever debug-report scaffolding gets added next.)

## Handy test recipe
```bash
B=https://beanstalk-api.fly.dev
TOK=$(curl -s -X POST $B/api/auth/login -H 'Content-Type: application/json' \
  -d '{"email":"sarah@demo.com","password":"Demo123!"}' | python3 -c 'import sys,json;print(json.load(sys.stdin)["token"])')
curl -s $B/api/notifications/debug-tokens -H "Authorization: Bearer $TOK"   # see what registered
curl -s -X POST $B/api/notifications/test -H "Authorization: Bearer $TOK" \
  -H 'Content-Type: application/json' -d '{}'                                # fire a push
```
Android push is testable on the emulator (`google_apis` image receives FCM);
iOS push needs a real device via TestFlight.
