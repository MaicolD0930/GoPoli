import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'login_page.dart';
import 'registro_page.dart';

/// Pantalla tras eliminar cuenta (HU-06).
class BienvenidaPage extends StatelessWidget {
  const BienvenidaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'GoPoli',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: AppColors.verdePrimario,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Gracias por usar GoPoli',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.verdeSecundario,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tu cuenta fue eliminada. Puedes volver a registrarte cuando quieras.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.grisTexto, height: 1.4),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verdePrimario,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Iniciar sesión'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const RegistroPage()),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.verdePrimario,
                    side: const BorderSide(color: AppColors.verdePrimario),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Crear cuenta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
