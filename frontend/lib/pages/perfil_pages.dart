import 'package:flutter/material.dart';
import '../utils/session_manager.dart';
import 'login_page.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  static const Color verdeSecundario = Color(0xFF2E7D32);
  static const Color amarillo = Color(0xFFFFC107);
  static const Color grisTexto = Color(0xFF757575);
  static const Color grisClaro = Color(0xFFF5F5F5);

  void _cerrarSesion() {
    SessionManager.cerrarSesion();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nombre = SessionManager.nombre ?? 'Usuario';
    final correo = SessionManager.correo ?? '';
    final rolTexto = SessionManager.etiquetaTipoUsuario();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.embedded
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              centerTitle: true,
              title: const Text(
                'Mi perfil',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  SizedBox(height: widget.embedded ? 8 : 16),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFE0B2),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const ClipOval(
                      child: Icon(
                        Icons.person,
                        size: 70,
                        color: Color(0xFFBCAAA4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    correo.isEmpty ? 'Sin correo' : correo,
                    style: const TextStyle(
                      fontSize: 14,
                      color: verdeSecundario,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: grisClaro,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Rol: $rolTexto',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: grisTexto,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _cerrarSesion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: amarillo,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cerrar sesión',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
