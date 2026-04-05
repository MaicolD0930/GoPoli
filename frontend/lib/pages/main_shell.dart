import 'package:flutter/material.dart';
import 'inicio_mapa_page.dart';
import 'home_page.dart';
import 'viajes_tab_page.dart';
import 'grupo_page.dart';
import 'perfil_pages.dart';

/// Contenedor principal tras el login: mapa + crear servicio, buscar, viajes, grupos y perfil.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  /// Al volver de [GrupoPage], los tabs que escuchan recargan servicio activo / en curso.
  final ValueNotifier<int> _shellRefreshTick = ValueNotifier(0);

  /// Pide a [InicioMapaPage] dibujar la ruta del servicio y cambia al tab Inicio.
  final ValueNotifier<int?> _viajeEnMapa = ValueNotifier<int?>(null);

  static const Color verdePrimario = Color(0xFF1B5E20);
  static const Color grisTexto = Color(0xFF757575);

  static const _titulos = [
    'Inicio',
    'Buscar',
    'Viajes',
    'Perfil',
  ];

  @override
  void dispose() {
    _shellRefreshTick.dispose();
    _viajeEnMapa.dispose();
    super.dispose();
  }

  void _irAMapaViaje(int idServicio) {
    _viajeEnMapa.value = idServicio;
    setState(() => _index = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titulos[_index],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: verdePrimario,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _index,
        children: [
          InicioMapaPage(
            shellRefreshTick: _shellRefreshTick,
            viajeEnMapaNotifier: _viajeEnMapa,
          ),
          HomePage(
            embedded: true,
            shellRefreshTick: _shellRefreshTick,
            onIrACrearServicio: () => setState(() => _index = 0),
            onIrAlInicio: () => setState(() => _index = 0),
            onIrAMapaViaje: _irAMapaViaje,
          ),
          ViajesTabPage(
            shellRefreshTick: _shellRefreshTick,
            onIrAMapaViaje: _irAMapaViaje,
            onOpenGrupo: _openGrupo,
          ),
          const PerfilPage(embedded: true),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: verdePrimario,
        unselectedItemColor: grisTexto,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.route_outlined),
            activeIcon: Icon(Icons.route),
            label: 'Viajes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Future<void> _openGrupo(int idServicio) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => GrupoPage(idServicio: idServicio),
      ),
    );
    if (mounted) {
      _shellRefreshTick.value++;
      setState(() {});
    }
  }
}
