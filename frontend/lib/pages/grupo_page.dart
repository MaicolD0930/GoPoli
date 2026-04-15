import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../config/config.dart';
import '../utils/session_manager.dart';

class GrupoPage extends StatefulWidget {
  final int idServicio;

  const GrupoPage({super.key, required this.idServicio});

  @override
  State<GrupoPage> createState() => _GrupoPageState();
}

class _GrupoPageState extends State<GrupoPage> with WidgetsBindingObserver {
  static const Color verdePrimario = Color(0xFF1B5E20);
  static const Color grisTexto = Color(0xFF757575);
  static const Duration _intervaloAutoRefresh = Duration(seconds: 5);

  List<dynamic> miembros = [];
  bool cargando = true;
  int estadoServicio = 1;
  String? _errorMiembros;
  Timer? _timerAutoRefresh;

  /// Evita fallos al comparar idUsuario del JSON (int/num) con la sesión.
  static bool _mismoUsuario(dynamic idJson, int? idSesion) {
    if (idSesion == null || idJson == null) return false;
    final a = idJson is num ? idJson.toInt() : int.tryParse(idJson.toString());
    return a != null && a == idSesion;
  }

  static int _parseEstado(dynamic v) {
    if (v == null) return 1;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 1;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cargarTodo();
    _iniciarAutoRefresh();
  }

  @override
  void dispose() {
    _timerAutoRefresh?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _iniciarAutoRefresh();
      _cargarTodo(mostrarCarga: false);
      return;
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _timerAutoRefresh?.cancel();
    }
  }

  void _iniciarAutoRefresh() {
    _timerAutoRefresh?.cancel();
    _timerAutoRefresh = Timer.periodic(_intervaloAutoRefresh, (_) {
      if (!mounted) return;
      _cargarTodo(mostrarCarga: false);
    });
  }

  Future<void> _cargarTodo({bool mostrarCarga = true}) async {
    await Future.wait([
      _cargarMiembros(mostrarCarga: mostrarCarga),
      _cargarEstadoServicio(),
    ]);
  }

  Future<void> _cargarMiembros({
    bool esReintento = false,
    bool mostrarCarga = true,
  }) async {
    if (!esReintento && mostrarCarga && mounted) {
      setState(() {
        cargando = true;
        _errorMiembros = null;
      });
    }
    try {
      final res = await http.get(
        Uri.parse('${Config.apiUrl}/servicio/${widget.idServicio}/miembros'),
      );
      if (!mounted) return;

      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        // A veces el GET llega antes de que el miembro creador esté visible; un reintento breve ayuda.
        if (list.isEmpty && !esReintento) {
          await Future<void>.delayed(const Duration(milliseconds: 450));
          await _cargarMiembros(esReintento: true, mostrarCarga: mostrarCarga);
          return;
        }
        setState(() {
          miembros = list;
          cargando = false;
          _errorMiembros = null;
        });
      } else {
        setState(() {
          miembros = [];
          cargando = false;
          _errorMiembros = res.body.length > 200
              ? 'No se pudo cargar el grupo (${res.statusCode})'
              : res.body;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          miembros = [];
          cargando = false;
          _errorMiembros = 'Error de conexión';
        });
      }
    }
  }

  Future<void> _cargarEstadoServicio() async {
    try {
      final res = await http.get(
        Uri.parse('${Config.apiUrl}/servicio/${widget.idServicio}'),
      );
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        setState(() => estadoServicio = _parseEstado(data['idEstadoServicio']));
      }
    } catch (_) {}
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
      if (!mounted) return;
      if (res.statusCode == 200) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.body)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cancelar el grupo')),
        );
      }
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
      if (!mounted) return;
      if (res.statusCode == 200) {
        setState(() => estadoServicio = 4);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Viaje iniciado!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.body)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al iniciar el viaje')),
        );
      }
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
      if (!mounted) return;
      if (res.statusCode == 200) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.body)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al finalizar el viaje')),
        );
      }
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
      if (!mounted) return;
      if (res.statusCode == 200) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.body)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al salir del grupo')),
        );
      }
    }
  }

  bool get esCreador => miembros.any(
        (m) =>
            _mismoUsuario(m['idUsuario'], SessionManager.idUsuario) &&
            m['rol'] == 'Creador',
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Mi grupo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: verdePrimario,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          if (!cargando)
            IconButton(
              tooltip: 'Actualizar',
              onPressed: () => _cargarTodo(),
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : _errorMiembros != null
              ? _buildErrorEstado()
              : Column(
                  children: [
                    Expanded(child: _buildListaMiembros()),
                    if (esCreador) _buildAccionesCreador(),
                    if (!esCreador && estadoServicio == 1) _buildSalirMiembro(),
                  ],
                ),
    );
  }

  Widget _buildErrorEstado() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMiembros!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: grisTexto, fontSize: 15),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _cargarTodo(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(
                backgroundColor: verdePrimario,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaMiembros() {
    if (miembros.isEmpty) {
      return RefreshIndicator(
        color: verdePrimario,
        onRefresh: () => _cargarTodo(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_outlined, size: 56, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'Aún no hay personas en este grupo',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Desliza hacia abajo para actualizar o pulsa el ícono de actualizar.',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      color: verdePrimario,
      onRefresh: () => _cargarTodo(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: miembros.length,
        itemBuilder: (context, index) {
          final miembro = miembros[index] as Map<String, dynamic>;
          final esCreadorMiembro = miembro['rol'] == 'Creador';
          final soyYo = _mismoUsuario(miembro['idUsuario'], SessionManager.idUsuario);
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 0,
            color: soyYo ? const Color(0xFFE8F5E9) : Colors.grey[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: soyYo ? verdePrimario.withValues(alpha: 0.35) : const Color(0xFFEEEEEE),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: CircleAvatar(
                backgroundColor:
                    esCreadorMiembro ? verdePrimario : Colors.grey[300],
                child: Icon(
                  Icons.person,
                  color: esCreadorMiembro ? Colors.white : grisTexto,
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      miembro['nombreUsuario']?.toString() ?? 'Usuario',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (soyYo)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: verdePrimario,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Tú',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: Text(
                esCreadorMiembro ? 'Creador' : 'Miembro',
                style: TextStyle(
                  color: esCreadorMiembro ? verdePrimario : grisTexto,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccionesCreador() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: estadoServicio == 1 ? _iniciarViaje : _finalizarViaje,
              icon: Icon(
                estadoServicio == 1 ? Icons.directions_car : Icons.flag,
              ),
              label: Text(
                estadoServicio == 1 ? 'Iniciar viaje' : 'Finalizar viaje',
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
          // Solo en planificación (activo): cancelar. En curso se usa Finalizar.
          if (estadoServicio == 1) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _cancelarGrupo,
                icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                label: const Text(
                  'Cancelar grupo',
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
        ],
      ),
    );
  }

  Widget _buildSalirMiembro() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton.icon(
          onPressed: _salirGrupo,
          icon: const Icon(Icons.exit_to_app, color: Colors.red),
          label: const Text(
            'Salir del grupo',
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
    );
  }
}
