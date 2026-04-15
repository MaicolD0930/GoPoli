import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/config.dart';
import '../utils/validaciones.dart';
import 'login_page.dart';

class CrearUsuarioPage extends StatefulWidget {
  const CrearUsuarioPage({super.key});

  @override
  State<CrearUsuarioPage> createState() => _CrearUsuarioPageState();
}

class _CrearUsuarioPageState extends State<CrearUsuarioPage> {
  final correoController = TextEditingController();
  final passController = TextEditingController();
  final nombreController = TextEditingController();
  final documentoController = TextEditingController();
  final telController = TextEditingController();

  List carreras = [];
  int? carreraSeleccionada;

  @override
  void initState() {
    super.initState();
    cargarCarreras();
  }

  Future<void> cargarCarreras() async {
    var url = Uri.parse("${Config.apiUrl}/carreras");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        carreras = jsonDecode(response.body);
      });
    }
  }

  void mostrarError(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  bool validarCampos() {
    String correo = correoController.text;
    String pass = passController.text;
    String nombre = nombreController.text;
    String documento = documentoController.text;

    if (!Validaciones.correoInstitucional(correo)) {
      mostrarError("El correo debe ser @elpoli.edu.co");
      return false;
    }

    if (!Validaciones.contrasenaValida(pass)) {
      mostrarError("La contraseña debe tener mínimo 8 caracteres");
      return false;
    }

    if (!Validaciones.nombreValido(nombre)) {
      mostrarError("El nombre solo puede contener letras");
      return false;
    }

    if (!Validaciones.documentoValido(documento)) {
      mostrarError("El documento solo puede contener números");
      return false;
    }

    if (!Validaciones.telefonoValido(telController.text)) {
      mostrarError("El teléfono debe tener entre 8 y 14 dígitos");
      return false;
    }

    if (telController.text.isEmpty || carreraSeleccionada == null) {
      mostrarError("Todos los campos son obligatorios");
      return false;
    }

    return true;
  }

  Future<void> registrar() async {
    if (!validarCampos()) return;

    try {
      var url = Uri.parse("${Config.apiUrl}/register");

      var body = {
        "correo": correoController.text,
        "contrasena": passController.text,
        "nombre": nombreController.text,
        "tel": telController.text,
        "idCarrera": carreraSeleccionada,
      };

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        if (!context.mounted) return;
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 10),
                  Text("Cuenta creada"),
                ],
              ),
              content: const Text("La cuenta fue creada correctamente."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        mostrarError("Usuario ya registrado");
      }
    } catch (e) {
      mostrarError("Error de conexión con el servidor");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Usuario"),
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/register_illustration.png",
                  height: 150,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Crea tu cuenta de GoPoli",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                const Text(
                  "Accede a los servicios que la app para estudiantes ofrece",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: correoController,
                  decoration: const InputDecoration(
                    labelText: "Correo",
                    prefixIcon: Icon(Icons.email),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: passController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Contraseña",
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: "Nombres y Apellidos",
                    prefixIcon: Icon(Icons.person),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: documentoController,
                  decoration: const InputDecoration(
                    labelText: "Número de documento",
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: "Carrera o profesión",
                    prefixIcon: Icon(Icons.school),
                  ),
                  hint: const Text("Seleccionar Carrera"),
                  initialValue: carreraSeleccionada,
                  items: carreras.map<DropdownMenuItem<int>>((c) {
                    return DropdownMenuItem<int>(
                      value: c["idCarrera"],
                      child: Text(c["nombreCarrera"] ?? ""),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      carreraSeleccionada = value;
                    });
                  },
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: telController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Teléfono de contacto",
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: registrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text("Crear cuenta"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
