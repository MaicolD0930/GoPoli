import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/config.dart';
import '../utils/session_manager.dart';

class CrearServicioPage extends StatefulWidget {
  const CrearServicioPage({super.key});

  @override
  State<CrearServicioPage> createState() => _CrearServicioPageState();
}

class _CrearServicioPageState extends State<CrearServicioPage> {
  static const Color verdePrimario = Color(0xFF1B5E20);
  static const Color verdeSecundario = Color(0xFF2E7D32);
  static const Color grisTexto = Color(0xFF757575);

  final descripcionController = TextEditingController();

  List ubicaciones = [];
  int? ubicacionSalidaSeleccionada;
  int? ubicacionLlegadaSeleccionada;

  DateTime? fechaSeleccionada;
  TimeOfDay? horaSeleccionada;
  bool cargando = false;
  String mensaje = "";

  @override
  void initState() {
    super.initState();
    _cargarUbicaciones();
  }

  Future<void> _cargarUbicaciones() async {
    try {
      print("Llamando a ubicaciones..."); // línea nueva
      final res = await http.get(Uri.parse('${Config.apiUrl}/ubicaciones'));
      print("Respuesta ubicaciones: ${res.body}");

      if (res.statusCode == 200) {
        setState(() {
          ubicaciones = jsonDecode(res.body);
        });
      }
    } catch (e) {
      print("Error: $e"); // línea nueva
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
        }),
      );

      if (res.statusCode == 200) {
        setState(() => mensaje = "¡Servicio creado exitosamente!");
      } else {
        setState(() => mensaje = res.body);
      }
    } catch (e) {
      setState(() => mensaje = "Error de conexión");
    } finally {
      setState(() => cargando = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Crear Servicio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: verdePrimario,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lugar Salida
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
              hint: const Text('Selecciona el lugar de salida'),
              decoration: _inputDecoration(),
              items: ubicaciones.map<DropdownMenuItem<int>>((u) {
                return DropdownMenuItem<int>(
                  value: u['idUbicacion'],
                  child: Text(u['nombreUbicacion'] ?? ''),
                );
              }).toList(),
              onChanged: (val) =>
                  setState(() => ubicacionSalidaSeleccionada = val),
            ),

            const SizedBox(height: 20),

            // Lugar Llegada
            const Text(
              'Lugar de Llegada *',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: verdePrimario,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: ubicacionLlegadaSeleccionada,
              hint: const Text('Selecciona el lugar de llegada'),
              decoration: _inputDecoration(),
              items: ubicaciones.map<DropdownMenuItem<int>>((u) {
                return DropdownMenuItem<int>(
                  value: u['idUbicacion'],
                  child: Text(u['nombreUbicacion'] ?? ''),
                );
              }).toList(),
              onChanged: (val) =>
                  setState(() => ubicacionLlegadaSeleccionada = val),
            ),

            const SizedBox(height: 20),

            // Fecha
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: grisTexto,
                      size: 18,
                    ),
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

            // Hora
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
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

            // Descripción
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

            const SizedBox(height: 32),

            // Botón crear
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: cargando ? null : _crearServicio,
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

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
