import 'package:flutter/material.dart';

import '../core/api_exception.dart';
import '../core/field_validation_exception.dart';
import '../services/usuario_service.dart';
import '../theme/app_colors.dart';
import '../utils/vehicle_validators.dart';

class RegistroConductorPage extends StatefulWidget {
  const RegistroConductorPage({super.key});

  @override
  State<RegistroConductorPage> createState() => _RegistroConductorPageState();
}

class _RegistroConductorPageState extends State<RegistroConductorPage> {
  final _formKey = GlobalKey<FormState>();
  final _marcaCtrl = TextEditingController();
  final _modeloCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _placaCtrl = TextEditingController();

  final _usuarioService = const UsuarioService();
  bool _enviando = false;

  final _errores = <String, String>{};

  @override
  void dispose() {
    _marcaCtrl.dispose();
    _modeloCtrl.dispose();
    _colorCtrl.dispose();
    _placaCtrl.dispose();
    super.dispose();
  }

  void _validarCampo(String campo, String? Function(String?) validator) {
    final err = validator(_getCtrl(campo).text);
    setState(() {
      if (err == null) {
        _errores.remove(campo);
      } else {
        _errores[campo] = err;
      }
    });
  }

  TextEditingController _getCtrl(String campo) {
    switch (campo) {
      case 'marca':
        return _marcaCtrl;
      case 'modelo':
        return _modeloCtrl;
      case 'color':
        return _colorCtrl;
      default:
        return _placaCtrl;
    }
  }

  bool _validarTodo() {
    final campos = {
      'marca': VehicleValidators.marca(_marcaCtrl.text),
      'modelo': VehicleValidators.modelo(_modeloCtrl.text),
      'color': VehicleValidators.color(_colorCtrl.text),
      'placa': VehicleValidators.placa(_placaCtrl.text),
    };
    setState(() {
      _errores.clear();
      campos.forEach((k, v) {
        if (v != null) _errores[k] = v;
      });
    });
    return _errores.isEmpty;
  }

  Future<void> _enviar() async {
    if (!_validarTodo()) return;

    setState(() => _enviando = true);
    try {
      await _usuarioService.registerAsDriver(
        marca: _marcaCtrl.text,
        modelo: _modeloCtrl.text,
        color: _colorCtrl.text,
        placa: _placaCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Ahora eres conductor en GoPoli!'),
          backgroundColor: AppColors.verdePrimario,
        ),
      );
      Navigator.pop(context, true);
    } on FieldValidationException catch (e) {
      setState(() => _errores.addAll(e.fieldErrors));
    } on ApiException catch (e) {
      _mostrarError(e.message);
    } catch (_) {
      _mostrarError('No se pudo completar el registro');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  Widget _campo({
    required String label,
    required String campo,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextCapitalization capitalization = TextCapitalization.words,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.verdePrimario,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          textCapitalization: capitalization,
          onChanged: (_) {
            if (_errores.containsKey(campo)) _validarCampo(campo, validator);
          },
          onEditingComplete: () => _validarCampo(campo, validator),
          onTapOutside: (_) => _validarCampo(campo, validator),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            errorText: _errores[campo],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de vehículo'),
        backgroundColor: AppColors.verdePrimario,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Completa los datos de tu vehículo para ser conductor en GoPoli.',
              style: TextStyle(color: AppColors.grisTexto, height: 1.4),
            ),
            const SizedBox(height: 24),
            _campo(
              label: 'Marca *',
              campo: 'marca',
              controller: _marcaCtrl,
              validator: VehicleValidators.marca,
            ),
            _campo(
              label: 'Modelo *',
              campo: 'modelo',
              controller: _modeloCtrl,
              validator: VehicleValidators.modelo,
            ),
            _campo(
              label: 'Color *',
              campo: 'color',
              controller: _colorCtrl,
              validator: VehicleValidators.color,
            ),
            _campo(
              label: 'Placa *',
              campo: 'placa',
              controller: _placaCtrl,
              validator: VehicleValidators.placa,
              capitalization: TextCapitalization.characters,
            ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _enviando ? null : _enviar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.verdePrimario,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _enviando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Registrarme como conductor',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
