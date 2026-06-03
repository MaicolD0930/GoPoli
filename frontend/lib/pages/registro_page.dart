import 'package:flutter/material.dart';

import '../core/api_exception.dart';
import '../models/carrera.dart';
import '../services/auth_service.dart';
import '../services/catalogo_service.dart';
import '../theme/app_colors.dart';
import '../utils/validaciones.dart';
import '../widgets/auth_text_field.dart';
import 'login_page.dart';

/// DEV-7 / HU-01 — Registro de usuario.
class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

/// Alias para compatibilidad con rutas existentes.
typedef CrearUsuarioPage = RegistroPage;

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _nombreController = TextEditingController();
  final _telController = TextEditingController();

  final _authService = const AuthService();
  final _catalogoService = const CatalogoService();

  List<Carrera> _carreras = [];
  int? _carreraSeleccionada;
  bool _cargandoCarreras = true;
  bool _registrando = false;
  bool _verContrasena = false;
  bool _verConfirmacion = false;
  String? _errorCarreras;
  String? _mensajeGlobal;

  @override
  void initState() {
    super.initState();
    _cargarCarreras();
  }

  @override
  void dispose() {
    _correoController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    _nombreController.dispose();
    _telController.dispose();
    super.dispose();
  }

  Future<void> _cargarCarreras() async {
    setState(() {
      _cargandoCarreras = true;
      _errorCarreras = null;
    });
    try {
      final lista = await _catalogoService.obtenerCarreras();
      if (!mounted) return;
      setState(() {
        _carreras = lista;
        _cargandoCarreras = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorCarreras = e.message;
        _cargandoCarreras = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorCarreras = 'No se pudieron cargar las carreras';
        _cargandoCarreras = false;
      });
    }
  }

  void _mostrarSnack(String mensaje, {bool error = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor:
            error ? Colors.red.shade700 : AppColors.verdeSecundario,
      ),
    );
  }

  Future<void> _registrar() async {
    setState(() => _mensajeGlobal = null);

    if (_carreraSeleccionada == null) {
      setState(() => _mensajeGlobal = 'Selecciona tu carrera');
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _registrando = true);

    try {
      await _authService.registrar(
        correo: _correoController.text,
        contrasena: _passController.text,
        nombre: _nombreController.text,
        telefono: _telController.text,
        idCarrera: _carreraSeleccionada!,
      );

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.verdeSecundario),
              SizedBox(width: 10),
              Text('Cuenta creada'),
            ],
          ),
          content: const Text(
            'Tu cuenta fue registrada correctamente. Ya puedes iniciar sesión.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Iniciar sesión'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _mensajeGlobal = e.message);
      _mostrarSnack(e.message);
    } catch (_) {
      if (!mounted) return;
      const msg = 'Error de conexión con el servidor';
      setState(() => _mensajeGlobal = msg);
      _mostrarSnack(msg);
    } finally {
      if (mounted) setState(() => _registrando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Crear cuenta',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.verdePrimario,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'GoPoli',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppColors.verdePrimario,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Registro de usuario',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.verdeSecundario,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Completa tus datos con correo institucional @elpoli.edu.co',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grisTexto,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                AuthTextField(
                  controller: _correoController,
                  label: 'Correo electrónico',
                  hint: 'nombre@elpoli.edu.co',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  textInputAction: TextInputAction.next,
                  enabled: !_registrando,
                  validator: (v) => Validaciones.mensajeCorreo(v ?? ''),
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _passController,
                  label: 'Contraseña',
                  hint: 'Mínimo 8 caracteres',
                  obscureText: !_verContrasena,
                  prefixIcon: Icons.lock_outline,
                  textInputAction: TextInputAction.next,
                  enabled: !_registrando,
                  validator: (v) => Validaciones.mensajeContrasena(v ?? ''),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _verContrasena ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.grisTexto,
                    ),
                    onPressed: () =>
                        setState(() => _verContrasena = !_verContrasena),
                  ),
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _confirmPassController,
                  label: 'Confirmar contraseña',
                  obscureText: !_verConfirmacion,
                  prefixIcon: Icons.lock_outline,
                  textInputAction: TextInputAction.next,
                  enabled: !_registrando,
                  validator: (v) => Validaciones.mensajeConfirmacion(
                    _passController.text,
                    v ?? '',
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _verConfirmacion
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.grisTexto,
                    ),
                    onPressed: () => setState(
                      () => _verConfirmacion = !_verConfirmacion,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _nombreController,
                  label: 'Nombre completo',
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  enabled: !_registrando,
                  validator: (v) => Validaciones.mensajeNombre(v ?? ''),
                ),
                const SizedBox(height: 16),
                _buildCarreraDropdown(),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _telController,
                  label: 'Teléfono',
                  hint: '3001234567',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  textInputAction: TextInputAction.done,
                  enabled: !_registrando,
                  validator: (v) => Validaciones.mensajeTelefono(v ?? ''),
                  onFieldSubmitted: (_) => _registrar(),
                ),
                if (_mensajeGlobal != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _mensajeGlobal!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _registrando ? null : _registrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verdePrimario,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: _registrando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Crear cuenta',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿Ya tienes cuenta? ',
                      style: TextStyle(color: AppColors.grisTexto, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: _registrando
                          ? null
                          : () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                              ),
                      child: const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          color: AppColors.amarillo,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarreraDropdown() {
    if (_cargandoCarreras) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(color: AppColors.verdePrimario),
        ),
      );
    }

    if (_errorCarreras != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _errorCarreras!,
            style: const TextStyle(color: Colors.red, fontSize: 13),
          ),
          TextButton(onPressed: _cargarCarreras, child: const Text('Reintentar')),
        ],
      );
    }

    return DropdownButtonFormField<int>(
      // ignore: deprecated_member_use — valor controlado al seleccionar carrera
      value: _carreraSeleccionada,
      decoration: const InputDecoration(
        labelText: 'Carrera',
        prefixIcon: Icon(Icons.school, color: AppColors.grisTexto),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: AppColors.bordeCampo),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: AppColors.bordeCampo),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: AppColors.verdePrimario, width: 2),
        ),
      ),
      hint: const Text('Selecciona tu carrera'),
      items: _carreras
          .map(
            (c) => DropdownMenuItem<int>(
              value: c.idCarrera,
              child: Text(c.nombreCarrera),
            ),
          )
          .toList(),
      onChanged: _registrando
          ? null
          : (value) => setState(() => _carreraSeleccionada = value),
      validator: (value) =>
          value == null ? 'Selecciona tu carrera' : null,
    );
  }
}
