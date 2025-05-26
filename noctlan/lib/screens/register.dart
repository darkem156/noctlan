import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:noctlan/utils/api.dart';

class RegisterScreen extends StatefulWidget {
  final String jwt;
  const RegisterScreen({super.key, required this.jwt});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _tipoUsuario = 'medico';
  String? status;

  Future<void> registrar() async {
    final response = await http.post(
      Uri.parse('http://$API_URI/signUp'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '${widget.jwt}'
      },
      body: jsonEncode({
        'nombre': _nombre.text,
        'apellido': _apellido.text,
        'email': _email.text,
        'password': _password.text,
        'tipo_usuario': _tipoUsuario
      }),
    );

    setState(() {
      if (response.statusCode == 201) {
        _nombre.clear();
        _apellido.clear();
        _email.clear();
        _password.clear();
        status = 'Usuario registrado correctamente';
      } else {
        status =
            'Error al registrar usuario: ${response.statusCode} ${response.body}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Usuario')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (status != null)
              Text(status!, style: const TextStyle(color: Colors.green)),
            TextField(
                controller: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(
                controller: _apellido,
                decoration: const InputDecoration(labelText: 'Apellido')),
            TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email')),
            TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password')),
            DropdownButton<String>(
              value: _tipoUsuario,
              items: const [
                DropdownMenuItem(value: 'medico', child: Text('Médico')),
                DropdownMenuItem(value: 'enfermero', child: Text('Enfermero')),
                DropdownMenuItem(
                    value: 'administrador', child: Text('Administrador')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _tipoUsuario = value;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: registrar, child: const Text('Registrar usuario')),
          ],
        ),
      ),
    );
  }
}
