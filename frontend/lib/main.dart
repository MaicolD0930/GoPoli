import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config/config.dart';
import 'pages/login_page.dart';
void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: LoginPage());
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final correoController = TextEditingController();
  final nombreController = TextEditingController();
  final passController = TextEditingController();
  final telController = TextEditingController();

  String mensaje = "";

  Future<void> registrar() async {
    try {
      var url = Uri.parse("${Config.apiUrl}/register");

      var body = {
        "correo": correoController.text,
        "contrasena": passController.text,
        "nombre": nombreController.text,
        "tel": telController.text,
      };

      print("JSON ENVIADO:");
      print(body);

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      setState(() {
        mensaje = response.body;
      });
    } catch (e) {
      print("ERROR: $e");

      setState(() {
        mensaje = "Error de conexión";
      });
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro Usuario")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: correoController,
              decoration: const InputDecoration(labelText: "Correo"),
            ),
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: passController,
              decoration: const InputDecoration(labelText: "Contraseña"),
            ),
            TextField(
              controller: telController,
              decoration: const InputDecoration(labelText: "Teléfono"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: registrar,
              child: const Text("Registrar"),
            ),
            const SizedBox(height: 20),
            Text(mensaje),
          ],
        ),
      ),
    );
  }
}
