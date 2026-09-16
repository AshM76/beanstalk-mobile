# Android — build & verification notes

**Status: ✅ Verified (2026-09-16).** The release build compiles, carries the
right identity + permissions, and runs on a real Android device without
crashing.

## What was verified

- **Release build** — `flutter build apk --release` succeeds (Gradle + R8 +
  manifest merge). Output: `build/app/outputs/flutter-apk/app-release.apk`.
- **Merged release manifest** (dumped from the APK) contains:
  - `uses-permission: android.permission.INTERNET` — required for release; Flutter
    only auto-adds it to debug/profile manifests, so without our fix a release
    build would have **no network** and every API call would fail silently.
  - `package: com.ashaanvi.beanstalk`, `application-label: 'Beanstalk'`
  - minSdk 24, targetSdk 36, compileSdk 36
- **Real-device run** — Firebase Test Lab Robo test **passed** on a physical
  **Pixel 5, API 30** (matrix `matrix-89pxxdl6ecjza`). App launched and ran
  stably; no crash, ANR, or permission failure.
- **Login / API round-trip** — confirmed via the web build (CORS preflight +
  POST to `beanstalk-api.fly.dev` returned 200 with a JWT).

## Config that made it work

- `android/app/src/main/AndroidManifest.xml` — added `<uses-permission
  android:name="android.permission.INTERNET"/>`; label `Beanstalk`.
- `android/app/build.gradle.kts` — `applicationId = "com.ashaanvi.beanstalk"`.
  `namespace` stays `com.example.beanstalk` (matches the MainActivity package;
  independent of applicationId — fine to differ).

## Signing

The release APK is signed with the **debug key** (Flutter template default).
Fine for testing and Firebase Test Lab. A real **upload keystore** is required
only for Google Play distribution.

## Toolchain setup (fresh machine, no Android Studio, no sudo)

```bash
# Java 17 (formula, not cask — avoids the admin password)
brew install openjdk@17
# Android command-line tools (sdkmanager / avdmanager)
brew install --cask android-commandlinetools

export JAVA_HOME=/usr/local/opt/openjdk@17
export ANDROID_SDK_ROOT=/usr/local/share/android-commandlinetools
export ANDROID_HOME="$ANDROID_SDK_ROOT"
export PATH="$JAVA_HOME/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$PATH"

# SDK packages (35 for the emulator image, 36 because Flutter 3.41 needs it)
yes | sdkmanager --sdk_root="$ANDROID_SDK_ROOT" \
  "platform-tools" "emulator" \
  "platforms;android-35" "build-tools;35.0.0" \
  "platforms;android-36" "build-tools;36.0.0" \
  "system-images;android-35;google_apis;x86_64"
yes | sdkmanager --sdk_root="$ANDROID_SDK_ROOT" --licenses

flutter config --android-sdk "$ANDROID_SDK_ROOT"
flutter doctor          # expect: [✓] Android toolchain (SDK 36.0.0)
```

## Running

- **Emulator** (heavy — bogs this machine down; use sparingly):
  ```bash
  echo "no" | avdmanager create avd -n beanstalk_pixel \
    -k "system-images;android-35;google_apis;x86_64" -d pixel_7
  "$ANDROID_SDK_ROOT/emulator/emulator" -avd beanstalk_pixel -no-snapshot-save &
  flutter run -d emulator-5554
  ```
- **Chrome** (light, preferred for UI iteration — see CLAUDE.md): `flutter run -d chrome`
- **Physical device** — enable USB debugging, plug in, `flutter run -d <id>`
  (lightest way to verify real Android behavior).
- **Real-device without a phone** — Firebase Test Lab: upload the release APK
  via the Firebase console (needs the project on the Blaze plan).
