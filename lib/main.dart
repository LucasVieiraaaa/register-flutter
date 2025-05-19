import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista e Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/list': (context) => const ListScreen(),
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    if (_emailController.text == 'admin@admin.com' &&
        _passwordController.text == '12345') {
      Navigator.pushNamed(
        context,
        '/list',
        arguments: _nameController.text.isEmpty
            ? 'Usuário'
            : _nameController.text,
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Dados inválidos'),
          content: const Text('Usuário e/ou senha incorreto(a)'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Não'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Sim'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tela de Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String name = ModalRoute.of(context)?.settings.arguments as String? ?? 'Usuário';
    final List<String> items = List.generate(20, (index) => 'Item ${index + 1}');

    return Scaffold(
      appBar: AppBar(
        title: Text('Bem vindo(a), $name'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index]),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Alerta'),
                  content: Text('Você clicou no item ${index + 1}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Não'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Sim'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}