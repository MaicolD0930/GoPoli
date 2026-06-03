import 'package:flutter/material.dart';
import '../widgets/crear_servicio_form.dart';
import 'grupo_page.dart';

class CrearServicioPage extends StatefulWidget {
  const CrearServicioPage({super.key});

  @override
  State<CrearServicioPage> createState() => _CrearServicioPageState();
}

class _CrearServicioPageState extends State<CrearServicioPage> {
  static const Color verdePrimario = Color(0xFF1B5E20);

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
        child: CrearServicioForm(
          onServicioCreado: (idServicio) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => GrupoPage(idServicio: idServicio),
              ),
            );
          },
        ),
      ),
    );
  }
}
