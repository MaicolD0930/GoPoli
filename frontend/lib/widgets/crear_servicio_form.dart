import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import '../config/config.dart';
import '../utils/session_manager.dart';

int? _parseUbicacionId(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

double? _parseCoord(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

/// Formulario para crear servicio (reutilizable en pantalla mapa o página dedicada).
class CrearServicioForm extends StatefulWidget {
  const CrearServicioForm({
    super.key,
    required this.onServicioCreado,
    this.destinoQueryNotifier,
    this.onCoordenadasSeleccion,
    this.bloqueoCrearMensaje,
  });

  /// Se llama con [idServicio] cuando el backend responde OK.
  final void Function(int idServicio) onServicioCreado;

  final ValueNotifier<String>? destinoQueryNotifier;

  /// Salida / llegada con coordenadas de la BD. [aviso] si hay punto elegido pero sin lat/long en API.
  final void Function(LatLng? salida, LatLng? llegada, {String? aviso})?
      onCoordenadasSeleccion;

  /// Si no es null, no se puede enviar crear (p. ej. ya tienes servicio activo).
  final String? bloqueoCrearMensaje;

  @override
  State<CrearServicioForm> createState() => _CrearServicioFormState();
}

class _CrearServicioFormState extends State<CrearServicioForm> {
  static const Color verdePrimario = Color(0xFF1B5E20);
  static const Color verdeSecundario = Color(0xFF2E7D32);
  static const Color grisTexto = Color(0xFF757575);

  final descripcionController = TextEditingController();

  List ubicaciones = [];
  List ubicacionesFiltradas = [];
  int? ubicacionSalidaSeleccionada;
  int? ubicacionLlegadaSeleccionada;
  int capacidadSeleccionada = 2;

  DateTime? fechaSeleccionada;
  TimeOfDay? horaSeleccionada;
  bool cargando = false;
  String mensaje = "";

  @override
  void initState() {
    super.initState();
    _cargarUbicaciones();
    widget.destinoQueryNotifier?.addListener(_onDestinoQuery);
  }

  @override
  void dispose() {
    widget.destinoQueryNotifier?.removeListener(_onDestinoQuery);
    descripcionController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CrearServicioForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bloqueoCrearMensaje != widget.bloqueoCrearMensaje) {
      setState(() {});
    }
  }

  void _onDestinoQuery() {
    final q = widget.destinoQueryNotifier!.value.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        ubicacionesFiltradas = List.from(ubicaciones);
      } else {
        ubicacionesFiltradas = ubicaciones
            .where((u) =>
                (u['nombreUbicacion'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains(q))
            .toList();
      }
    });
  }

  LatLng? _latLngParaId(int? id) {
    if (id == null) return null;
    for (final u in ubicaciones) {
      if (_parseUbicacionId(u['idUbicacion']) == id) {
        final lat = _parseCoord(u['latitud']);
        final lng = _parseCoord(u['longitud']);
        if (lat == null || lng == null) return null;
        return LatLng(lat, lng);
      }
    }
    return null;
  }

  void _notificarCoordenadas() {
    final ls = _latLngParaId(ubicacionSalidaSeleccionada);
    final ll = _latLngParaId(ubicacionLlegadaSeleccionada);
    String? aviso;
    if (ubicacionSalidaSeleccionada != null && ls == null) {
      aviso =
          'La salida elegida no tiene coordenadas en el servidor. Reinicia el backend y revisa la consola (UbicacionCoordenadasSeeder).';
    } else if (ubicacionLlegadaSeleccionada != null && ll == null) {
      aviso =
          'La llegada elegida no tiene coordenadas en el servidor. Reinicia el backend y revisa la consola (UbicacionCoordenadasSeeder).';
    }
    widget.onCoordenadasSeleccion?.call(ls, ll, aviso: aviso);
  }

  Future<void> _cargarUbicaciones() async {
    try {
      final res = await http.get(Uri.parse('${Config.apiUrl}/ubicaciones'));
      if (res.statusCode == 200) {
        setState(() {
          ubicaciones = jsonDecode(res.body) as List;
          ubicacionesFiltradas = List.from(ubicaciones);
        });
        _notificarCoordenadas();
      }
    } catch (e) {
      setState(() => mensaje = "Error cargando ubicaciones");
    }
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: verdePrimario),
        ),
        child: child!,
      ),
    );
    if (fecha != null) setState(() => fechaSeleccionada = fecha);
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: verdePrimario),
        ),
        child: child!,
      ),
    );
    if (hora != null) setState(() => horaSeleccionada = hora);
  }

  Future<void> _crearServicio() async {
    if (widget.bloqueoCrearMensaje != null) return;

    if (fechaSeleccionada == null ||
        horaSeleccionada == null ||
        ubicacionSalidaSeleccionada == null ||
        ubicacionLlegadaSeleccionada == null) {
      setState(
        () => mensaje = "Por favor completa todos los campos obligatorios",
      );
      return;
    }

    setState(() {
      cargando = true;
      mensaje = "";
    });

    final horaStr =
        '${horaSeleccionada!.hour.toString().padLeft(2, '0')}:${horaSeleccionada!.minute.toString().padLeft(2, '0')}:00';
    final fechaStr = fechaSeleccionada!.toIso8601String().substring(0, 10);

    try {
      final res = await http.post(
        Uri.parse('${Config.apiUrl}/servicio/crear'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fecha': fechaStr,
          'descripcion': descripcionController.text,
          'idLugarSalida': ubicacionSalidaSeleccionada,
          'idLugarLlegada': ubicacionLlegadaSeleccionada,
          'horaSalida': horaStr,
          'idCreador': SessionManager.idUsuario,
          'idTipoServicio': 1,
          'capacidad': capacidadSeleccionada,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final id = data['idServicio'];
        final idInt = id is num ? id.toInt() : int.tryParse(id.toString());
        if (idInt != null) widget.onServicioCreado(idInt);
      } else {
        if (mounted) setState(() => mensaje = res.body);
      }
    } catch (e) {
      if (mounted) setState(() => mensaje = "Error de conexión");
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  InputDecoration _inputDecoration({String hint = ''}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        borderSide: const BorderSide(color: verdePrimario, width: 2),
      ),
    );
  }

  Widget? _buildSugerenciasDestino() {
    final q = widget.destinoQueryNotifier?.value.trim() ?? '';
    if (q.isEmpty || ubicacionesFiltradas.isEmpty) return null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sugerencias',
          style: TextStyle(fontSize: 12, color: grisTexto),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ubicacionesFiltradas.take(6).map<Widget>((u) {
            final id = _parseUbicacionId(u['idUbicacion']);
            return ActionChip(
              label: Text(
                u['nombreUbicacion'] ?? '',
                style: const TextStyle(fontSize: 13),
              ),
              onPressed: id == null
                  ? null
                  : () {
                      setState(() => ubicacionLlegadaSeleccionada = id);
                      _notificarCoordenadas();
                    },
              backgroundColor: const Color(0xFFE8F5E9),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sugerencias = _buildSugerenciasDestino();
    final bloqueado = widget.bloqueoCrearMensaje != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (bloqueado) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFB74D)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFE65100)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.bloqueoCrearMensaje!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFBF360C),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        const Text(
          'Lugar de Salida *',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: verdePrimario,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: ubicacionSalidaSeleccionada,
          hint: const Text('Desde dónde sales'),
          decoration: _inputDecoration(),
          items: ubicaciones
              .map<DropdownMenuItem<int>?>((u) {
                final id = _parseUbicacionId(u['idUbicacion']);
                if (id == null) return null;
                return DropdownMenuItem<int>(
                  value: id,
                  child: Text(u['nombreUbicacion'] ?? ''),
                );
              })
              .whereType<DropdownMenuItem<int>>()
              .toList(),
          onChanged: (val) {
            setState(() => ubicacionSalidaSeleccionada = val);
            _notificarCoordenadas();
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Lugar de Llegada *',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: verdePrimario,
          ),
        ),
        const SizedBox(height: 8),
        ?sugerencias,
        DropdownButtonFormField<int>(
          value: ubicacionLlegadaSeleccionada,
          hint: const Text('¿A dónde vamos?'),
          decoration: _inputDecoration(),
          items: ubicaciones
              .map<DropdownMenuItem<int>?>((u) {
                final id = _parseUbicacionId(u['idUbicacion']);
                if (id == null) return null;
                return DropdownMenuItem<int>(
                  value: id,
                  child: Text(u['nombreUbicacion'] ?? ''),
                );
              })
              .whereType<DropdownMenuItem<int>>()
              .toList(),
          onChanged: (val) {
            setState(() => ubicacionLlegadaSeleccionada = val);
            _notificarCoordenadas();
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Fecha *',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: verdePrimario,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _seleccionarFecha,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: grisTexto, size: 18),
                const SizedBox(width: 12),
                Text(
                  fechaSeleccionada == null
                      ? 'Selecciona una fecha'
                      : '${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year}',
                  style: TextStyle(
                    color: fechaSeleccionada == null
                        ? const Color(0xFFBDBDBD)
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Hora de Salida *',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: verdePrimario,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _seleccionarHora,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: grisTexto, size: 18),
                const SizedBox(width: 12),
                Text(
                  horaSeleccionada == null
                      ? 'Selecciona una hora'
                      : horaSeleccionada!.format(context),
                  style: TextStyle(
                    color: horaSeleccionada == null
                        ? const Color(0xFFBDBDBD)
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Descripción',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: verdePrimario,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: descripcionController,
          maxLines: 3,
          decoration: _inputDecoration(hint: 'Describe tu servicio...'),
        ),
        const SizedBox(height: 20),
        const Text(
          'Capacidad *',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: verdePrimario,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: capacidadSeleccionada > 2
                  ? () => setState(() => capacidadSeleccionada--)
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: verdePrimario,
              iconSize: 32,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '$capacidadSeleccionada',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: capacidadSeleccionada < 4
                  ? () => setState(() => capacidadSeleccionada++)
                  : null,
              icon: const Icon(Icons.add_circle_outline),
              color: verdePrimario,
              iconSize: 32,
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: (cargando || bloqueado) ? null : _crearServicio,
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
                    'Crear Servicio',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        if (mensaje.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: mensaje.contains('exitosamente')
                  ? verdeSecundario
                  : Colors.red,
              fontSize: 14,
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
