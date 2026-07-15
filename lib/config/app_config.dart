// lib/config/app_config.dart
//
// Single source of truth for build-time configuration.
//
// The API base URL is baked in at compile time from
//   --dart-define=API_BASE_URL=<url>
// and falls back to the production Fly.io deployment when the define is
// omitted (e.g. a plain `flutter build ipa` for TestFlight). For local
// development the demo launcher (start-demo.sh) passes
//   --dart-define=API_BASE_URL=http://localhost:8080
//
// Because String.fromEnvironment is const/compile-time, this value is fixed
// per build — there is no runtime toggle. Anything that needs the base URL
// should read AppConfig.apiBaseUrl rather than hardcoding a host.
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://beanstalk-api.fly.dev',
  );
}
