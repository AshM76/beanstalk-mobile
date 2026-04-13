import 'package:flutter/material.dart';
import 'auth/auth_state.dart';
import 'pages/login_page.dart';
import 'pages/shell_page.dart';

void main() {
  runApp(const BeanstalkAdminApp());
}

class BeanstalkAdminApp extends StatefulWidget {
  const BeanstalkAdminApp({super.key});

  @override
  State<BeanstalkAdminApp> createState() => _BeanstalkAdminAppState();
}

class _BeanstalkAdminAppState extends State<BeanstalkAdminApp> {
  final _auth = AuthState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beanstalk Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
        ),
      ),
      home: AnimatedBuilder(
        animation: _auth,
        builder: (_, __) => _auth.isLoggedIn
            ? ShellPage(auth: _auth)
            : LoginPage(auth: _auth),
      ),
    );
  }
}
