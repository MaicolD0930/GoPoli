import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/config.dart';
import '../utils/session_manager.dart';
import '../pages/crear_servicio_page.dart';
import '../pages/grupo_page.dart';
import '../pages/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color verdePrimario = Color(0xFF1B5E20);
  static const Color verdeSecundario = Color(0xFF2E7D32);
  static const Color grisTexto = Color(0xFF757575);

  List servicios = [];
  bool cargando = true;
  int? idServicioActivo;
  int? idServicioEnCurso;

  @override
  void initState() {
    super.initState();
    _cargarTodo();
  }

  Future<void> _cargarTodo() async {
    await _cargarServicios();
    await _verificarServicioActivo();
    await _verificarServicioEnCurso();
  }

  Future<void> _cargarServicios() async {
    try {
      final res = await http.get(
        Uri.parse('${Config.apiUrl}/servicios/activos'),
      );
      if (res.statusCode == 200) {
        setState(() {
          servicios = jsonDecode(res.body);
          cargando = false;
        });
      }
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  Future<void> _verificarServicioActivo() async {
    try {
      var res = await http.get(
        Uri.parse(
          '${Config.apiUrl}/servicio/usuario/activo/${SessionManager.idUsuario}',
        ),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() => idServicioActivo = data['idServicio']);
        return;
      }

      res = await http.get(
        Uri.parse(
          '${Config.apiUrl}/servicio/usuario/miembro/${SessionManager.idUsuario}',
        ),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() => idServicioActivo = data['idServicio']);
      }
    } catch (e) {
      // No tiene grupo activo
    }
  }

  Future<void> _verificarServicioEnCurso() async {
    try {
      final res = await http.get(
        Uri.parse(
          '${Config.apiUrl}/servicio/usuario/encurso/${SessionManager.idUsuario}',
        ),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() => idServicioEnCurso = data['idServicio']);
      }
    } catch (e) {
      // No tiene viaje en curso
    }
  }

  Future<void> _unirse(int idServicio) async {
    try {
      final res = await http.post(
        Uri.parse('${Config.apiUrl}/servicio/unirse'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idServicio': idServicio,
          'idUsuario': SessionManager.idUsuario,
        }),
      );

      if (res.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => GrupoPage(idServicio: idServicio)),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(res.body)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error de conexión')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'GoPoli',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: verdePrimario,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              SessionManager.cerrarSesion();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner viaje en curso
          if (idServicioEnCurso != null)
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GrupoPage(idServicio: idServicioEnCurso!),
                  ),
                );
                _cargarTodo();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: const Color(0xFF2E7D32),
                child: Row(
                  children: const [
                    Icon(Icons.directions_car, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tienes un viaje en curso — Toca para ver',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ),
            ),

          // Lista de servicios
          Expanded(
            child: cargando
                ? const Center(child: CircularProgressIndicator())
                : servicios.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.group_off,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay servicios activos',
                          style: TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '¡Crea el primero!',
                          style: TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _cargarServicios,
                    color: verdePrimario,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: servicios.length,
                      itemBuilder: (context, index) {
                        final s = servicios[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: Color(0xFF757575),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${s['fecha']} - ${s['horaSalida']}',
                                      style: const TextStyle(
                                        color: Color(0xFF757575),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (s['descripcion'] != null &&
                                    s['descripcion'].toString().isNotEmpty)
                                  Text(
                                    s['descripcion'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _unirse(s['idServicio']),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: verdePrimario,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text('Unirse'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),

      floatingActionButton: idServicioEnCurso != null
          ? null
          : idServicioActivo != null
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GrupoPage(idServicio: idServicioActivo!),
                  ),
                );
                _cargarTodo();
              },
              backgroundColor: verdeSecundario,
              icon: const Icon(Icons.group, color: Colors.white),
              label: const Text(
                'Ver mi Grupo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CrearServicioPage()),
                );
                _cargarTodo();
              },
              backgroundColor: verdePrimario,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Crear Servicio',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }
}
