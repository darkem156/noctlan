import 'package:flutter/material.dart';
import './metricas.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Map<String, dynamic> parseJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw Exception('invalid token');
  }

  final payload = _decodeBase64(parts[1]);
  final payloadMap = json.decode(payload);
  if (payloadMap is! Map<String, dynamic>) {
    throw Exception('invalid payload');
  }

  return payloadMap;
}

String _decodeBase64(String str) {
  String output = str.replaceAll('-', '+').replaceAll('_', '/');

  switch (output.length % 4) {
    case 0:
      break;
    case 2:
      output += '==';
      break;
    case 3:
      output += '=';
      break;
    default:
      throw Exception('Illegal base64url string!"');
  }

  return utf8.decode(base64Url.decode(output));
}

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
      final tipoUsuario = parseJwt(token)['tipo_usuario'];
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Sistema de Monitoreo')),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Bienvenido al sistema'),
                        const SizedBox(height: 20),
                        if (tipoUsuario == 'administrador')
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => RegisterScreen(jwt: token)),
                              );
                            },
                            child: const Text('Registrar usuario'),
                          ),
                        const SizedBox(height: 20),
                        if (tipoUsuario == 'administrador')
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => VerUsuarioScreen()),
                              );
                            },
                            child: const Text('Ver usuarios'),
                          ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => RegisterPacienteScreen()),
                            );
                          },
                          child: const Text('Registrar paciente'),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => VerPacienteScreen()),
                            );
                          },
                          child: const Text('Ver pacientes'),
                        ),
                      ],
                    ),
                  ),
                )), //RegisterScreen(jwt: token)),
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

class RegisterPacienteScreen extends StatefulWidget {
  const RegisterPacienteScreen({super.key});

  @override
  State<RegisterPacienteScreen> createState() => _RegisterPacienteScreenState();
}

class _RegisterPacienteScreenState extends State<RegisterPacienteScreen> {
  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _fechaNacimiento = TextEditingController();
  final _genero = TextEditingController();
  String? status;

  Future<void> registrar() async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/pacientes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': _nombre.text,
        'apellido': _apellido.text,
        'fechaNacimiento': _fechaNacimiento.text,
        'genero': _genero.text,
      }),
    );

    setState(() {
      if (response.statusCode == 201) {
        _nombre.clear();
        _apellido.clear();
        _fechaNacimiento.clear();
        _genero.clear();
        status = 'Paciente registrado correctamente';
      } else {
        status =
            'Error al registrar paciente: ${response.statusCode} ${response.body}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Paciente')),
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
                controller: _fechaNacimiento,
                decoration:
                    const InputDecoration(labelText: 'Fecha de Nacimiento')),
            TextField(
                controller: _genero,
                decoration: const InputDecoration(labelText: 'Género')),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: registrar, child: const Text('Registrar paciente')),
          ],
        ),
      ),
    );
  }
}

class VerPacienteScreen extends StatefulWidget {
  const VerPacienteScreen({super.key});

  @override
  State<VerPacienteScreen> createState() => _VerPacienteScreenState();
}

class _VerPacienteScreenState extends State<VerPacienteScreen> {
  List<dynamic> pacientes = [];
  String? status;
  TextEditingController _camaController = TextEditingController();

  Future<void> obtenerPacientes() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/pacientes'),
      headers: {'Content-Type': 'application/json'},
    );

    setState(() {
      if (response.statusCode == 200) {
        pacientes = jsonDecode(response.body);
        status = null;
      } else {
        status =
            'Error al obtener pacientes: ${response.statusCode} ${response.body}';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    obtenerPacientes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pacientes')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (status != null)
              Text(status!, style: const TextStyle(color: Colors.red)),
            ...pacientes.map((paciente) => ListTile(
                  title: Text('${paciente['nombre']} ${paciente['apellido']}'),
                  subtitle: Column(children: [
                    ElevatedButton(
                        onPressed: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SimulacionMetricasScreen(),
                                  ))
                            },
                        child: const Text('Ver metricas')),
                    ElevatedButton(
                        onPressed: () => {
                              // Aquí puedes agregar la lógica para asignar una cama
                              // a este paciente. Por ejemplo, abrir un nuevo diálogo
                              // o pantalla para seleccionar una cama.
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Asignar Cama'),
                                    content: TextField(
                                      decoration: const InputDecoration(
                                          labelText: 'Número de Cama'),
                                      controller: _camaController,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Asignar'),
                                      ),
                                    ],
                                  );
                                },
                              )
                            },
                        child: const Text('Asignar cama'))
                  ]),
                )),
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
      Uri.parse('http://localhost:3000/usuarios'),
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
