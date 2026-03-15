import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/config.dart';
import 'package:gopoli/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final correoController = TextEditingController();
  final passController = TextEditingController();

  String mensaje = "";
  bool cargando = false;

  Future<void> login() async {
    setState(() {
      cargando = true;
      mensaje = "";
    });

    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': correoController.text,
          'contrasena': passController.text,
        }),
      );

      if (response.statusCode == 200) {
        final usuario = jsonDecode(response.body);
        setState(() {
          mensaje = "Bienvenido, ${usuario['nombre']}";
        });
        // Aquí después navegas a la pantalla principal
      } else {
        setState(() {
          mensaje = "Correo o contraseña incorrectos";
        });
      }
    } catch (e) {
      setState(() {
        mensaje = "Error de conexión";
      });
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Iniciar Sesión")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: correoController,
              decoration: const InputDecoration(labelText: "Correo"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passController,
              decoration: const InputDecoration(labelText: "Contraseña"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            cargando
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: login,
                    child: const Text("Iniciar Sesión"),
                  ),
            const SizedBox(height: 20),
            Text(mensaje),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              child: const Text("¿No tienes cuenta? Regístrate"),
            ),
          ],
        ),
      ),
    );
  }
}