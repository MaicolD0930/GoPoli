import 'package:flutter/material.dart';

/// Paleta compartida (login, registro, perfil).
abstract final class AppColors {
  static const Color verdePrimario = Color(0xFF1B5E20);
  static const Color verdeSecundario = Color(0xFF2E7D32);
  static const Color amarillo = Color(0xFFFFC107);
  static const Color grisTexto = Color(0xFF757575);
  static const Color bordeCampo = Color(0xFFE0E0E0);

  /// Variante para badges de conductor (dentro de la familia verde).
  static const Color conductor = Color(0xFF388E3C);
  static const Color error = Color(0xFFC62828);
  static const Color warning = Color(0xFFE65100);
  static const Color warningSurface = Color(0xFFFFF3E0);
  static const Color surfaceMuted = Color(0xFFF5F5F5);
  static const Color surfaceGreen = Color(0xFFE8F5E9);
  static const Color hint = Color(0xFFBDBDBD);
  static const Color divider = Color(0xFFEEEEEE);
}
