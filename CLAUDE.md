# Beanstalk Mobile — notes for Claude

Flutter app for the Beanstalk financial-literacy platform. The backend is a
separate repo (`AshM76/beanstalk-api`), deployed to Fly at
`beanstalk-api.fly.dev`.

## Running the app to verify changes

- **Prefer the browser:** `flutter run -d chrome`. Resize the window or use
  Chrome DevTools device mode (⌥⌘I → device toolbar) to emulate a phone.
- **Avoid the iOS Simulator** — it bogs this machine down; don't reach for it
  just to eyeball UI.
- Run **`flutter analyze`** before pushing UI changes. Repo CI only runs
  GitGuardian, which does **not** compile Dart, so analyze is the real gate.

## Configuration

- API base URL defaults to the production Fly host at build time. For local
  dev against a local backend, pass
  `--dart-define=API_BASE_URL=http://localhost:8080`.

## Auth / demo accounts

- Login is by **email** (there is no separate username). Password reset lives
  in `lib/pages/auth/forgot_password_page.dart` (backend endpoints in
  `beanstalk-api`).
- Seeded demo accounts all use password `Demo123!` (e.g. `sarah@demo.com`,
  `admin@beanstalk.app`).
