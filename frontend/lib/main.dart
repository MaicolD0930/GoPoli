import 'package:flutter/material.dart';
import 'pages/crear_usuario.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {"/crear_usuario": (context) => const CrearUsuarioPage()},
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inicio")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, "/crear_usuario");
          },
          child: const Text("Crear Usuario"),
        ),
      ),
    );
  }
}
