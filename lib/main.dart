import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:beanstalk_mobile/src/routes/routes.dart';
import 'package:beanstalk_mobile/src/blocs/provider.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';
import 'package:beanstalk_mobile/src/ui/app_skin.dart';

// Push notifications — replace app ID via .env / config before build
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = UserPreference();
  await prefs.initPrefs();
  tz.initializeTimeZones();

  // ── OneSignal push notifications ──────────────────────────────
  // Set BEANSTALK_ONESIGNAL_APP_ID in your environment config.
  // Never hardcode this value here.
  const oneSignalAppId = String.fromEnvironment(
    'BEANSTALK_ONESIGNAL_APP_ID',
    defaultValue: '',
  );
  if (oneSignalAppId.isNotEmpty) {
    OneSignal.Debug.setLogLevel(OSLogLevel.warning);
    OneSignal.initialize(oneSignalAppId);
    OneSignal.Notifications.requestPermission(true);
  }

  runApp(const BeanstalkApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class BeanstalkApp extends StatelessWidget {
  const BeanstalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = UserPreference();
    return Provider(
      child: MaterialApp(
        title: 'Beanstalk',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: prefs.token.toString().isNotEmpty ? 'navigation' : 'signin',
        routes: applicationRoutes(),
        navigatorKey: navigatorKey,
        builder: (context, child) {
          final mediaQueryData = MediaQuery.of(context);
          final constrained = mediaQueryData.textScaler.clamp(
            minScaleFactor: AppFontScales.upperScale,
            maxScaleFactor: AppFontScales.lowerScale,
          );
          return MediaQuery(
            data: mediaQueryData.copyWith(textScaler: constrained),
            child: child!,
          );
        },
      ),
    );
  }
}
