import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/config.dart';
import '../utils/session_manager.dart';

/// Grupo en planificación + viaje en curso (sustituye la antigua pestaña Grupos).
class ViajesTabPage extends StatefulWidget {
  const ViajesTabPage({
    super.key,
    required this.onIrAMapaViaje,
    required this.onOpenGrupo,
    this.shellRefreshTick,
  });

  final void Function(int idServicio) onIrAMapaViaje;
  final void Function(int idServicio) onOpenGrupo;
  final ValueNotifier<int>? shellRefreshTick;

  @override
  State<ViajesTabPage> createState() => _ViajesTabPageState();
}

class _ViajesTabPageState extends State<ViajesTabPage> {
  static const Color verdePrimario = Color(0xFF1B5E20);
  static const Color verdeSecundario = Color(0xFF2E7D32);
  static const Color grisTexto = Color(0xFF757575);

  int? idServicioActivo;
  int? idServicioEnCurso;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    widget.shellRefreshTick?.addListener(_onShellRefresh);
    _cargar();
  }

  @override
  void dispose() {
    widget.shellRefreshTick?.removeListener(_onShellRefresh);
    super.dispose();
  }

  void _onShellRefresh() {
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => cargando = true);
    await _verificarServicioActivo();
    await _verificarServicioEnCurso();
    if (mounted) setState(() => cargando = false);
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
    } catch (_) {}
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
    } catch (_) {}
    if (mounted) setState(() => idServicioEnCurso = nuevo);
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    final vacio =
        idServicioActivo == null && idServicioEnCurso == null;

    return RefreshIndicator(
      color: verdePrimario,
      onRefresh: _cargar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          _cabeceraDecorada(
            titulo: 'Viajes',
            subtitulo:
                'Tu grupo en planificación, el viaje en marcha y la ruta en el mapa de Inicio.',
            icono: Icons.route,
          ),
          const SizedBox(height: 20),
          if (idServicioEnCurso != null) ...[
            _tarjetaViajeEnCurso(),
            const SizedBox(height: 16),
          ],
          if (idServicioActivo != null) ...[
            _tarjetaMiGrupo(),
            const SizedBox(height: 16),
          ],
          if (vacio)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                children: [
                  Icon(Icons.map_outlined, size: 72, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Sin grupo ni viaje activo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: grisTexto,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea un servicio en Inicio o únete desde Buscar. '
                    'Cuando haya viaje en curso, verás la ruta en el mapa.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _tarjetaMiGrupo() {
    final id = idServicioActivo!;
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => widget.onOpenGrupo(id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: verdePrimario.withValues(alpha: 0.15),
                child: const Icon(Icons.group, color: verdePrimario),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mi grupo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Planificación — miembros, iniciar o cancelar',
                      style: TextStyle(fontSize: 13, color: grisTexto),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tarjetaViajeEnCurso() {
    final id = idServicioEnCurso!;
    return Card(
      elevation: 3,
      shadowColor: verdeSecundario.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    verdeSecundario,
                    verdeSecundario.withValues(alpha: 0.85),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Viaje en curso',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'La ruta está en el mapa de Inicio (salida, destino y camino).',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => widget.onIrAMapaViaje(id),
                    icon: const Icon(Icons.map),
                    label: const Text('Ver ruta en el mapa'),
                    style: FilledButton.styleFrom(
                      backgroundColor: verdeSecundario,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => widget.onOpenGrupo(id),
                    icon: const Icon(Icons.groups_outlined),
                    label: const Text('Grupo: miembros y acciones'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: verdePrimario,
                      side: const BorderSide(color: verdePrimario),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cabeceraDecorada({
    required String titulo,
    required String subtitulo,
    required IconData icono,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            verdePrimario.withValues(alpha: 0.12),
            verdeSecundario.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(color: verdePrimario.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 36, color: verdePrimario),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: verdePrimario,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitulo,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
