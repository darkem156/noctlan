import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:noctlan/utils/api.dart';

class VerUsuarioScreen extends StatefulWidget {
  const VerUsuarioScreen({super.key});

  @override
  State<VerUsuarioScreen> createState() => _VerUsuarioScreenState();
}

class _VerUsuarioScreenState extends State<VerUsuarioScreen> {
  List<dynamic> usuarios = [];
  String? status;

  Future<void> obtenerUsuarios() async {
    final response = await http.get(
      Uri.parse('http://$API_URI/usuarios'),
      headers: {'Content-Type': 'application/json'},
    );

    setState(() {
      if (response.statusCode == 200) {
        usuarios = jsonDecode(response.body);
        status = null;
      } else {
        status =
            'Error al obtener usuarios: ${response.statusCode} ${response.body}';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    obtenerUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (status != null)
              Text(status!, style: const TextStyle(color: Colors.red)),
            ...usuarios.map((usuario) => ListTile(
                  title: Text('${usuario['nombre']} ${usuario['apellido']}'),
                  subtitle: Text('Email: ${usuario['email']}'),
                )),
          ],
        ),
      ),
    );
  }
}
