import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/config.dart';
import '../utils/session_manager.dart';
import '../pages/home_page.dart';

class GrupoPage extends StatefulWidget {
  final int idServicio;

  const GrupoPage({super.key, required this.idServicio});

  @override
  State<GrupoPage> createState() => _GrupoPageState();
}

class _GrupoPageState extends State<GrupoPage> {
  static const Color verdePrimario = Color(0xFF1B5E20);
  static const Color verdeSecundario = Color(0xFF2E7D32);
  static const Color grisTexto = Color(0xFF757575);

  List miembros = [];
  bool cargando = true;
  int estadoServicio = 1;

  @override
  void initState() {
    super.initState();
    _cargarMiembros();
    _cargarEstadoServicio();
  }

  Future<void> _cargarMiembros() async {
    try {
      final res = await http.get(
        Uri.parse('${Config.apiUrl}/servicio/${widget.idServicio}/miembros'),
      );
      if (res.statusCode == 200) {
        setState(() {
          miembros = jsonDecode(res.body);
          cargando = false;
        });
      }
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  Future<void> _cargarEstadoServicio() async {
    try {
      final res = await http.get(
        Uri.parse('${Config.apiUrl}/servicio/${widget.idServicio}'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() => estadoServicio = data['idEstadoServicio']);
      }
    } catch (e) {
      // Error cargando estado
    }
  }

  Future<void> _cancelarGrupo() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar grupo'),
        content: const Text(
          '¿Estás seguro que deseas cancelar el grupo? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sí, cancelar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final res = await http.put(
        Uri.parse('${Config.apiUrl}/servicio/cancelar/${widget.idServicio}'),
      );
      if (res.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cancelar el grupo')),
      );
    }
  }

  Future<void> _iniciarViaje() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Iniciar viaje'),
        content: const Text('¿Estás seguro que deseas iniciar el viaje?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sí, iniciar',
              style: TextStyle(color: Color(0xFF1B5E20)),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final res = await http.put(
        Uri.parse('${Config.apiUrl}/servicio/iniciar/${widget.idServicio}'),
      );
      if (res.statusCode == 200) {
        setState(() => estadoServicio = 4);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('¡Viaje iniciado!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al iniciar el viaje')),
      );
    }
  }

  Future<void> _finalizarViaje() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar viaje'),
        content: const Text('¿Estás seguro que deseas finalizar el viaje?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sí, finalizar',
              style: TextStyle(color: Color(0xFF1B5E20)),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final res = await http.put(
        Uri.parse('${Config.apiUrl}/servicio/finalizar/${widget.idServicio}'),
      );
      if (res.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al finalizar el viaje')),
      );
    }
  }

  Future<void> _salirGrupo() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salir del grupo'),
        content: const Text('¿Estás seguro que deseas salir del grupo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, salir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final res = await http.delete(
        Uri.parse(
          '${Config.apiUrl}/servicio/salir/${widget.idServicio}/${SessionManager.idUsuario}',
        ),
      );
      if (res.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(res.body)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al salir del grupo')));
    }
  }

  bool get esCreador => miembros.any(
    (m) => m['idUsuario'] == SessionManager.idUsuario && m['rol'] == 'Creador',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Mi Grupo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: verdePrimario,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Lista de miembros
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: miembros.length,
                    itemBuilder: (context, index) {
                      final miembro = miembros[index];
                      final esCreadorMiembro = miembro['rol'] == 'Creador';
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: esCreadorMiembro
                              ? verdePrimario
                              : Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            color: esCreadorMiembro ? Colors.white : grisTexto,
                          ),
                        ),
                        title: Text(
                          miembro['nombreUsuario'] ?? 'Usuario',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          esCreadorMiembro ? 'Creador' : 'Miembro',
                          style: TextStyle(
                            color: esCreadorMiembro ? verdePrimario : grisTexto,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Botones creador
                if (esCreador)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: estadoServicio == 1
                                ? _iniciarViaje
                                : _finalizarViaje,
                            icon: Icon(
                              estadoServicio == 1
                                  ? Icons.directions_car
                                  : Icons.flag,
                            ),
                            label: Text(
                              estadoServicio == 1
                                  ? 'Iniciar Viaje'
                                  : 'Finalizar Viaje',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: verdePrimario,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: _cancelarGrupo,
                            icon: const Icon(
                              Icons.cancel_outlined,
                              color: Colors.red,
                            ),
                            label: const Text(
                              'Cancelar Grupo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Botón salir solo para miembros con viaje Activo
                if (!esCreador && estadoServicio == 1)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _salirGrupo,
                        icon: const Icon(Icons.exit_to_app, color: Colors.red),
                        label: const Text(
                          'Salir del Grupo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
