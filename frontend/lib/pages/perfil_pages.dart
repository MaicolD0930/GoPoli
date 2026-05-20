import 'package:flutter/material.dart';

import '../core/api_exception.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';
import '../theme/app_colors.dart';
import '../utils/session_manager.dart';
import '../widgets/profile_avatar.dart';
import 'bienvenida_page.dart';
import 'editar_perfil_page.dart';
import 'login_page.dart';

/// DEV-10 / HU-04 — Ver perfil (+ acciones HU-05 y HU-06).
class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _usuarioService = const UsuarioService();
  Usuario? _usuario;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final u = await _usuarioService.obtenerPerfil();
      if (!mounted) return;
      setState(() {
        _usuario = u;
        _cargando = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo cargar el perfil';
        _cargando = false;
      });
    }
  }

  Future<void> _irAEditar() async {
    if (_usuario == null) return;
    final actualizado = await Navigator.push<Usuario>(
      context,
      MaterialPageRoute(
        builder: (_) => EditarPerfilPage(usuarioInicial: _usuario!),
      ),
    );
    if (actualizado != null) {
      setState(() => _usuario = actualizado);
    } else {
      await _cargarPerfil();
    }
  }

  Future<void> _cerrarSesion() async {
    await SessionManager.cerrarSesion();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  Future<void> _inhabilitarCuenta() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Inhabilitar cuenta'),
        content: const Text(
          'Tu cuenta quedará desactivada y no podrás iniciar sesión. '
          '¿Deseas continuar?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Inhabilitar', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    try {
      await _usuarioService.inhabilitarCuenta();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    } on ApiException catch (e) {
      _mostrarSnack(e.message);
    } catch (_) {
      _mostrarSnack('Error al inhabilitar la cuenta');
    }
  }

  Future<void> _eliminarCuenta() async {
    final paso1 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text(
          'Esta acción es permanente. Se borrarán tus datos y no podrás recuperarlos.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continuar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (paso1 != true || !mounted) return;

    final paso2 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Estás seguro?'),
        content: const Text(
          'Confirma que deseas eliminar tu cuenta de forma definitiva.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (paso2 != true || !mounted) return;

    try {
      await _usuarioService.eliminarCuenta();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const BienvenidaPage()),
        (_) => false,
      );
    } on ApiException catch (e) {
      _mostrarSnack(e.message);
    } catch (_) {
      _mostrarSnack('Error al eliminar la cuenta');
    }
  }

  void _mostrarSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = _usuario;
    final nombre = u?.nombre ?? SessionManager.nombre ?? 'Usuario';
    final correo = u?.correo ?? SessionManager.correo ?? '';
    final foto = u?.fotoPerfil ?? SessionManager.fotoPerfil;
    final nota = u?.nota ?? SessionManager.nota;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.embedded
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              foregroundColor: Colors.black,
              title: const Text(
                'Mi perfil',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              actions: [
                if (!_cargando && _error == null)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _irAEditar,
                    tooltip: 'Editar perfil',
                  ),
              ],
            ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.verdePrimario),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _cargarPerfil,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarPerfil,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        if (widget.embedded)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, right: 8),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.edit, color: AppColors.verdePrimario),
                                onPressed: _irAEditar,
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        ProfileAvatar(fotoBase64: foto, radius: 50),
                        const SizedBox(height: 12),
                        Text(
                          nombre,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          correo.isEmpty ? 'Sin correo' : correo,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.verdeSecundario,
                          ),
                        ),
                        if (u?.tel != null && u!.tel!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            u.tel!,
                            style: const TextStyle(color: AppColors.grisTexto),
                          ),
                        ],
                        const SizedBox(height: 12),
                        RatingBadge(nota: nota),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Rol: ${SessionManager.etiquetaTipoUsuario()}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grisTexto,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _boton(
                          label: 'Editar perfil',
                          color: AppColors.verdePrimario,
                          onPressed: _irAEditar,
                        ),
                        const SizedBox(height: 12),
                        _boton(
                          label: 'Cerrar sesión',
                          color: AppColors.amarillo,
                          onPressed: _cerrarSesion,
                        ),
                        const SizedBox(height: 12),
                        _boton(
                          label: 'Inhabilitar cuenta',
                          color: Colors.orange,
                          onPressed: _inhabilitarCuenta,
                        ),
                        const SizedBox(height: 12),
                        _boton(
                          label: 'Eliminar cuenta',
                          color: Colors.red.shade700,
                          onPressed: _eliminarCuenta,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _boton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
