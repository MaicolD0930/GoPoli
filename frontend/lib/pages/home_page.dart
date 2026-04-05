import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/config.dart';
import '../utils/session_manager.dart';
import '../pages/crear_servicio_page.dart';
import '../pages/grupo_page.dart';
import '../pages/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.embedded = false,
    this.onIrACrearServicio,
    this.onIrAlInicio,
    this.onIrAMapaViaje,
    this.shellRefreshTick,
  });

  /// Dentro de [MainShell]: sin AppBar propio y FAB lleva al tab Inicio (mapa).
  final bool embedded;

  final VoidCallback? onIrACrearServicio;

  /// Desde Buscar, botón pequeño para volver al tab mapa.
  final VoidCallback? onIrAlInicio;

  /// Tab Inicio: muestra la ruta del viaje en curso (creador o pasajero).
  final void Function(int idServicio)? onIrAMapaViaje;

  final ValueNotifier<int>? shellRefreshTick;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color verdePrimario = Color(0xFF1B5E20);
  static const Color verdeSecundario = Color(0xFF2E7D32);

  List servicios = [];
  bool cargando = true;
  int? idServicioActivo;
  int? idServicioEnCurso;

  @override
  void initState() {
    super.initState();
    widget.shellRefreshTick?.addListener(_onShellRefresh);
    _cargarTodo();
  }

  @override
  void dispose() {
    widget.shellRefreshTick?.removeListener(_onShellRefresh);
    super.dispose();
  }

  void _onShellRefresh() {
    _cargarTodo();
  }

  void _pingOtrasPestanas() {
    final t = widget.shellRefreshTick;
    if (t != null) t.value++;
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
      if (!mounted) return;
      if (res.statusCode == 200) {
        setState(() {
          servicios = jsonDecode(res.body) as List<dynamic>;
          cargando = false;
        });
      } else {
        setState(() => cargando = false);
      }
    } catch (e) {
      if (mounted) setState(() => cargando = false);
    }
  }

  Future<void> _verificarServicioActivo() async {
    int? nuevo;
    try {
      var res = await http.get(
        Uri.parse(
          '${Config.apiUrl}/servicio/usuario/activo/${SessionManager.idUsuario}',
        ),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final id = data['idServicio'];
        if (id is num) nuevo = id.toInt();
      } else {
        res = await http.get(
          Uri.parse(
            '${Config.apiUrl}/servicio/usuario/miembro/${SessionManager.idUsuario}',
          ),
        );
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final id = data['idServicio'];
          if (id is num) nuevo = id.toInt();
        }
      }
    } catch (e) {
      // Sin grupo activo o error de red
    }
    if (mounted) setState(() => idServicioActivo = nuevo);
  }

  Future<void> _verificarServicioEnCurso() async {
    int? nuevo;
    try {
      final res = await http.get(
        Uri.parse(
          '${Config.apiUrl}/servicio/usuario/encurso/${SessionManager.idUsuario}',
        ),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final id = data['idServicio'];
        if (id is num) nuevo = id.toInt();
      }
    } catch (e) {
      // No tiene viaje en curso
    }
    if (mounted) setState(() => idServicioEnCurso = nuevo);
  }

  Future<void> _unirse(int idServicio) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
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
        if (!context.mounted) return;
        await navigator.push<void>(
          MaterialPageRoute(builder: (_) => GrupoPage(idServicio: idServicio)),
        );
        if (context.mounted) {
          _cargarTodo();
          _pingOtrasPestanas();
        }
      } else {
        if (!context.mounted) return;
        messenger.showSnackBar(SnackBar(content: Text(res.body)));
      }
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Error de conexión')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.embedded
          ? null
          : AppBar(
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
            Material(
              color: const Color(0xFF2E7D32),
              child: InkWell(
                onTap: () =>
                    widget.onIrAMapaViaje?.call(idServicioEnCurso!),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.map, color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Viaje en curso — Ver ruta en el mapa (Inicio)',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Icon(Icons.north_east, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ),

          // Lista de servicios
          Expanded(
            child: cargando
                ? const Center(child: CircularProgressIndicator())
                : servicios.isEmpty
                ? RefreshIndicator(
                    color: verdePrimario,
                    onRefresh: _cargarTodo,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Center(
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
                                  const SizedBox(height: 12),
                                  Text(
                                    'Desliza hacia abajo para actualizar',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _cargarTodo,
                    color: verdePrimario,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
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

      floatingActionButton: _buildFab(),
    );
  }

  Widget? _buildFab() {
    void irInicio() {
      final cb = widget.onIrAlInicio ?? widget.onIrACrearServicio;
      cb?.call();
    }

    if (idServicioEnCurso != null) {
      return FloatingActionButton.extended(
        heroTag: 'fab_viaje_curso',
        onPressed: () =>
            widget.onIrAMapaViaje?.call(idServicioEnCurso!),
        backgroundColor: verdeSecundario,
        icon: const Icon(Icons.map, color: Colors.white),
        label: const Text(
          'Ver ruta del viaje',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (idServicioActivo != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'fab_grupo',
            onPressed: () async {
              if (!context.mounted) return;
              await Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) => GrupoPage(idServicio: idServicioActivo!),
                ),
              );
              if (mounted) {
                _cargarTodo();
                _pingOtrasPestanas();
              }
            },
            backgroundColor: verdeSecundario,
            icon: const Icon(Icons.group, color: Colors.white),
            label: const Text(
              'Ver mi grupo',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (widget.embedded &&
              (widget.onIrAlInicio != null ||
                  widget.onIrACrearServicio != null)) ...[
            const SizedBox(height: 12),
            FloatingActionButton.small(
              heroTag: 'fab_mapa',
              tooltip: 'Ir al mapa (inicio)',
              onPressed: irInicio,
              backgroundColor: verdePrimario,
              child: const Icon(Icons.map, color: Colors.white),
            ),
          ],
        ],
      );
    }

    return FloatingActionButton.extended(
      heroTag: 'fab_crear',
      onPressed: () async {
        if (widget.embedded && widget.onIrACrearServicio != null) {
          widget.onIrACrearServicio!();
          return;
        }
        if (!context.mounted) return;
        await Navigator.push<void>(
          context,
          MaterialPageRoute(builder: (_) => const CrearServicioPage()),
        );
        if (mounted) {
          _cargarTodo();
          _pingOtrasPestanas();
        }
      },
      backgroundColor: verdePrimario,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Crear servicio',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
