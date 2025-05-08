import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Monitoreo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? error;

  Future<void> login() async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/signIn'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['token'];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => RegisterScreen(jwt: token)),
      );
    } else {
      setState(() {
        error = 'Credenciales incorrectas';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email')),
            TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: login, child: const Text('Iniciar sesión')),
          ],
        ),
      ),
    );
  }
}

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
      Uri.parse('http://localhost:3000/signUp'),
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
