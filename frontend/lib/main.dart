import 'package:flutter/material.dart';

import 'pages/login_page.dart';
import 'pages/main_shell.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'utils/session_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GoPoli',
      theme: AppTheme.light,
      home: const _SplashGate(),
    );
  }
}

/// Restaura JWT y redirige a home o login.
class _SplashGate extends StatefulWidget {
  const _SplashGate();

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final haySesion = await SessionManager.cargarSesion();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => haySesion ? const MainShell() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppColors.verdePrimario),
      ),
    );
  }
}
