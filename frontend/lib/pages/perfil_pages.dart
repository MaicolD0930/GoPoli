import 'package:flutter/material.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  // Colores del diseño
  static const Color verdePrimario = Color(0xFF1B5E20);
  static const Color verdeSecundario = Color(0xFF2E7D32);
  static const Color amarillo = Color(0xFFFFC107);
  static const Color grisTexto = Color(0xFF757575);
  static const Color grisClaro = Color(0xFFF5F5F5);

  // Rol seleccionado: 0 = Pasajero, 1 = Chofer
  int rolSeleccionado = 0;

  // Índice del tab seleccionado en la barra inferior
  int tabSeleccionado = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        centerTitle: true,
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.settings_outlined, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Sección avatar + nombre ──
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Avatar circular
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFE0B2),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const ClipOval(
                      child: Icon(
                        Icons.person,
                        size: 70,
                        color: Color(0xFFBCAAA4),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Nombre
                  const Text(
                    'Lucas Ramirez',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Correo
                  const Text(
                    'lucas.ramirez@elpoli.edu.co',
                    style: TextStyle(
                      fontSize: 14,
                      color: verdeSecundario,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // ── Carrera y Documento ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _infoRow(
                    icon: Icons.school_outlined,
                    label: 'Carrera',
                    value: 'Ingeniería de Sistemas',
                  ),
                  const SizedBox(height: 16),
                  _infoRow(
                    icon: Icons.badge_outlined,
                    label: 'Documento',
                    value: 'CC 12345678',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Cambiar Rol ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cambiar Rol',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Toggle Pasajero / Chofer
                  Container(
                    decoration: BoxDecoration(
                      color: grisClaro,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        _rolTab('Pasajero', 0),
                        _rolTab('Chofer', 1),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Opciones ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Opciones',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _opcionRow(Icons.history_outlined, 'Historial de viajes'),
                  _divider(),
                  _opcionRow(Icons.credit_card_outlined, 'Métodos de pago'),
                  _divider(),
                  _opcionRow(Icons.help_outline, 'Ayuda'),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Botón Cerrar Sesión ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Cerrar sesión - implementar después
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: amarillo,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),

      // ── Barra de navegación inferior ──
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabSeleccionado,
        onTap: (i) => setState(() => tabSeleccionado = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: verdePrimario,
        unselectedItemColor: grisTexto,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_outlined),
            activeIcon: Icon(Icons.directions_car),
            label: 'Viajes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: 'Grupos',
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

  // ── Widget: fila de info (carrera, documento) ──
  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: verdeSecundario, size: 26),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: grisTexto),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Widget: tab de rol (Pasajero / Chofer) ──
  Widget _rolTab(String label, int index) {
    final seleccionado = rolSeleccionado == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => rolSeleccionado = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: seleccionado ? verdePrimario : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: seleccionado ? Colors.white : grisTexto,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Widget: fila de opción con flecha ──
  Widget _opcionRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: grisTexto, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
          const Icon(Icons.chevron_right, color: grisTexto),
        ],
      ),
    );
  }

  // ── Widget: línea divisora ──
  Widget _divider() {
    return const Divider(height: 1, color: Color(0xFFEEEEEE));
  }
}