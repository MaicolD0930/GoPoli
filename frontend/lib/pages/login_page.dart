import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/config.dart';
import '../core/api_exception.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../utils/session_manager.dart';
import 'main_shell.dart';
import 'registro_conductor_page.dart';
import 'registro_page.dart';

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
  bool despertandoServidor = false;

  final _authService = const AuthService();

  @override
  void initState() {
    super.initState();
    _despertarServidor();
  }

  Future<void> _despertarServidor() async {
    setState(() => despertandoServidor = true);
    try {
      await http
          .get(Uri.parse('${Config.apiUrl}/ubicaciones'))
          .timeout(Config.apiTimeout);
    } catch (_) {
      // El login reintentará; Render free puede tardar en despertar.
    } finally {
      if (mounted) setState(() => despertandoServidor = false);
    }
  }

  Future<void> login() async {
    setState(() {
      cargando = true;
      mensaje = "";
    });

    try {
      await _authService.login(
        correo: correoController.text,
        contrasena: passController.text,
      );

      if (!context.mounted) return;
      await _navegarTrasLogin();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => mensaje = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => mensaje = 'Error de conexión con el servidor');
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  Future<void> _navegarTrasLogin() async {
    if (SessionManager.esConductor ||
        await SessionManager.rolConductorYaElegido()) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
      return;
    }

    if (!mounted) return;
    final quiereConductor = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Quieres ser conductor?'),
        content: const Text(
          'Puedes ofrecer viajes compartidos registrando tu vehículo, '
          'o continuar solo como pasajero.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Solo pasajero'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Sí, registrar vehículo',
              style: TextStyle(color: AppColors.verdePrimario),
            ),
          ),
        ],
      ),
    );

    await SessionManager.marcarRolConductorElegido();

    if (!mounted) return;
    if (quiereConductor == true) {
      await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const RegistroConductorPage()),
      );
      if (!mounted) return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
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
                  color: AppColors.verdePrimario,
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
                  color: AppColors.verdeSecundario,
                ),
              ),

              const SizedBox(height: 8),

              // Subtítulo
              const Text(
                'Introduce tu correo electrónico y contraseña para iniciar sesión',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.grisTexto, height: 1.4),
              ),

              const SizedBox(height: 36),

              // Campo correo
              TextField(
                controller: correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'email@elpoli.edu.co',
                  hintStyle: const TextStyle(color: AppColors.hint),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.bordeCampo),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.bordeCampo),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.verdePrimario,
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
                  hintStyle: const TextStyle(color: AppColors.hint),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      verContrasena ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.grisTexto,
                    ),
                    onPressed: () =>
                        setState(() => verContrasena = !verContrasena),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.bordeCampo),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.bordeCampo),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.verdePrimario,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              if (despertandoServidor)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Conectando con el servidor (puede tardar ~1 min)...',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.grisTexto, fontSize: 13),
                  ),
                ),

              // Botón continuar
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: cargando ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verdePrimario,
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
                        ? AppColors.verdeSecundario
                        : AppColors.error,
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
                    style: TextStyle(color: AppColors.grisTexto, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegistroPage(),
                      ),
                    ),
                    child: const Text(
                      'Crear una nueva cuenta',
                      style: TextStyle(
                        color: AppColors.amarillo,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Términos
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grisTexto,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Al hacer clic en continuar, aceptas nuestros ',
                    ),
                    TextSpan(
                      text: 'Términos de Servicio',
                      style: const TextStyle(
                        color: AppColors.amarillo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' y nuestra '),
                    TextSpan(
                      text: 'Política de Privacidad',
                      style: const TextStyle(
                        color: AppColors.amarillo,
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
