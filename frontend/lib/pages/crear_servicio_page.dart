import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/crear_servicio_form.dart';
import 'grupo_page.dart';

class CrearServicioPage extends StatefulWidget {
  const CrearServicioPage({super.key});

  @override
  State<CrearServicioPage> createState() => _CrearServicioPageState();
}

class _CrearServicioPageState extends State<CrearServicioPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Crear Servicio'),
        backgroundColor: AppColors.verdePrimario,
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
