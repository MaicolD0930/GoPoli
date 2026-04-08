import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/config.dart';
import '../pages/crear_usuario.dart';
import '../utils/session_manager.dart';
import '../pages/main_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final correoController = TextEditingController();
  final passController = TextEditingController();

  String mensaje = "";
  bool cargando = false;
  bool verContrasena = false;

  // Colores del diseño
  static const Color verdePrimario = Color(0xFF1B5E20);
  static const Color verdeSecundario = Color(0xFF2E7D32);
  static const Color amarillo = Color(0xFFFFC107);
  static const Color grisTexto = Color(0xFF757575);

  Future<void> login() async {
    setState(() {
      cargando = true;
      mensaje = "";
    });

    final navigator = Navigator.of(context);

    try {
      final correo = correoController.text.trim();
      final contrasena = passController.text;
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': correo,
          'contrasena': contrasena,
        }),
      );
      //Validacion Login
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        SessionManager.iniciarSesion(
          data['idUsuario'],
          data['nombre'],
          data['correo'],
          data['idTipoUsuario'],
        );

        if (!context.mounted) return;
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      } else {
        if (!mounted) return;
        setState(() {
          final body = response.body.trim();
          mensaje = body.isNotEmpty ? body : "Correo o contraseña incorrectos";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        mensaje = "Error de conexión con ${Config.apiUrl}";
      });
    } finally {
      if (mounted) {
        setState(() => cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // Logo GoPoli
              const Text(
                'GoPoli',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: verdePrimario,
                  letterSpacing: -1,
                ),
              ),

              const SizedBox(height: 24),

              // Título
              const Text(
                'Inicio de sesión',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: verdeSecundario,
                ),
              ),

              const SizedBox(height: 8),

              // Subtítulo
              const Text(
                'Introduce tu correo electrónico y contraseña para iniciar sesión',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: grisTexto, height: 1.4),
              ),

              const SizedBox(height: 36),

              // Campo correo
              TextField(
                controller: correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'email@elpoli.edu.co',
                  hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: verdePrimario,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Campo contraseña
              TextField(
                controller: passController,
                obscureText: !verContrasena,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      verContrasena ? Icons.visibility_off : Icons.visibility,
                      color: grisTexto,
                    ),
                    onPressed: () =>
                        setState(() => verContrasena = !verContrasena),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: verdePrimario,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botón continuar
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: cargando ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: verdePrimario,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: cargando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Continuar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Mensaje de error/éxito
              if (mensaje.isNotEmpty)
                Text(
                  mensaje,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: mensaje.startsWith('Bienvenido')
                        ? verdeSecundario
                        : Colors.red,
                    fontSize: 14,
                  ),
                ),

              const SizedBox(height: 8),

              // Link registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿No tienes una cuenta? ',
                    style: TextStyle(color: grisTexto, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CrearUsuarioPage(),
                      ),
                    ),
                    child: const Text(
                      'Crear una nueva cuenta',
                      style: TextStyle(
                        color: amarillo,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Separador
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'O',
                      style: TextStyle(color: grisTexto, fontSize: 13),
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                ],
              ),

              const SizedBox(height: 20),

              // Botón Google
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Google Sign In - implementar después
                  },
                  icon: Image.network(
                    'https://www.google.com/favicon.ico',
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.g_mobiledata,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  label: const Text(
                    'Continuar con Google',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: verdePrimario,
                    foregroundColor: Colors.white,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Términos
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    color: grisTexto,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Al hacer clic en continuar, aceptas nuestros ',
                    ),
                    TextSpan(
                      text: 'Términos de Servicio',
                      style: const TextStyle(
                        color: amarillo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' y nuestra '),
                    TextSpan(
                      text: 'Política de Privacidad',
                      style: const TextStyle(
                        color: amarillo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
