import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/api_exception.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';
import '../theme/app_colors.dart';
import '../utils/validaciones.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/profile_avatar.dart';

/// DEV-9 / HU-03 — Editar perfil.
class EditarPerfilPage extends StatefulWidget {
  const EditarPerfilPage({super.key, required this.usuarioInicial});

  final Usuario usuarioInicial;

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telController = TextEditingController();
  final _correoController = TextEditingController();
  final _usuarioService = const UsuarioService();
  final _picker = ImagePicker();

  String? _fotoBase64;
  bool _guardando = false;
  bool _subiendoFoto = false;

  @override
  void initState() {
    super.initState();
    final u = widget.usuarioInicial;
    _nombreController.text = u.nombre;
    _telController.text = u.tel ?? '';
    _correoController.text = u.correo;
    _fotoBase64 = u.fotoPerfil;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  Future<void> _elegirFoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 75,
    );
    if (file == null) return;

    setState(() => _subiendoFoto = true);
    try {
      final bytes = await file.readAsBytes();
      final b64 = base64Encode(bytes);
      final actualizado = await _usuarioService.subirFotoPerfil(b64);
      if (!mounted) return;
      setState(() => _fotoBase64 = actualizado.fotoPerfil);
      _mostrarSnack('Foto actualizada', error: false);
    } on ApiException catch (e) {
      _mostrarSnack(e.message);
    } catch (_) {
      _mostrarSnack('No se pudo subir la foto');
    } finally {
      if (mounted) setState(() => _subiendoFoto = false);
    }
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _guardando = true);
    try {
      final u = await _usuarioService.actualizarPerfil(
        nombre: _nombreController.text,
        telefono: _telController.text,
        correo: _correoController.text,
      );
      if (!mounted) return;
      Navigator.pop(context, u);
    } on ApiException catch (e) {
      _mostrarSnack(e.message);
    } catch (_) {
      _mostrarSnack('Error al guardar');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _mostrarSnack(String msg, {bool error = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red.shade700 : AppColors.verdeSecundario,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Editar perfil'),
        backgroundColor: AppColors.verdePrimario,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Stack(
                children: [
                  ProfileAvatar(
                    fotoBase64: _fotoBase64,
                    radius: 56,
                    onTap: _subiendoFoto ? null : _elegirFoto,
                  ),
                  if (_subiendoFoto)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: _subiendoFoto ? null : _elegirFoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Cambiar foto'),
              ),
            ),
            const SizedBox(height: 24),
            AuthTextField(
              controller: _nombreController,
              label: 'Nombre completo',
              prefixIcon: Icons.person_outline,
              enabled: !_guardando,
              validator: (v) => Validaciones.mensajeNombre(v ?? ''),
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _correoController,
              label: 'Correo',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              enabled: !_guardando,
              validator: (v) => Validaciones.mensajeCorreo(v ?? ''),
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _telController,
              label: 'Teléfono',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              enabled: !_guardando,
              validator: (v) => Validaciones.mensajeTelefono(v ?? ''),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.verdePrimario,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _guardando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text('Guardar cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
