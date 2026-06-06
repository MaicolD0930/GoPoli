import 'package:flutter/material.dart';

import '../core/api_exception.dart';
import '../models/historial_viaje.dart';
import '../services/usuario_service.dart';
import '../theme/app_colors.dart';

class HistorialViajesPage extends StatefulWidget {
  const HistorialViajesPage({super.key});

  @override
  State<HistorialViajesPage> createState() => _HistorialViajesPageState();
}

class _HistorialViajesPageState extends State<HistorialViajesPage> {
  final _service = const UsuarioService();
  List<HistorialViaje> _viajes = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final lista = await _service.obtenerHistorialViajes();
      if (!mounted) return;
      setState(() {
        _viajes = lista;
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
        _error = 'No se pudo cargar el historial';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de viajes'),
        backgroundColor: AppColors.verdePrimario,
        foregroundColor: Colors.white,
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
                          onPressed: _cargar,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : _viajes.isEmpty
                  ? const Center(
                      child: Text(
                        'Aún no tienes viajes finalizados.',
                        style: TextStyle(color: AppColors.grisTexto),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _cargar,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _viajes.length,
                        itemBuilder: (context, index) {
                          final v = _viajes[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      _badge(
                                        v.tripTypeLabel ?? 'Viaje',
                                        AppColors.verdePrimario,
                                      ),
                                      const SizedBox(width: 8),
                                      _badge(
                                        v.miRolParticipacionLabel ?? 'Pasajero',
                                        AppColors.conductor,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '${v.nombreSalida ?? 'Salida'} → ${v.nombreLlegada ?? 'Llegada'}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${v.fecha ?? ''} ${v.horaSalida ?? ''}',
                                    style: const TextStyle(
                                      color: AppColors.grisTexto,
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (v.descripcion != null &&
                                      v.descripcion!.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      v.descripcion!,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Participantes',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ...v.participantes.map(
                                    (p) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(p.nombreUsuario),
                                          ),
                                          _badge(
                                            p.rolParticipacionLabel,
                                            p.rolParticipacionLabel ==
                                                    'Conductor'
                                                ? AppColors.verdeSecundario
                                                : Colors.grey.shade600,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
