import 'package:agenda_contactos/pages/home_page.dart';
import 'package:agenda_contactos/pages/listado_contactos.dart';
import "package:flutter/material.dart";
import 'package:agenda_contactos/pages/inicio.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:agenda_contactos/providers/login_provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  //Función para validar el login
  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor ingrese email y contraseña"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final loginProvider = Provider.of<LoginProvider>(context, listen: false);
      final success = await loginProvider.login(email, password);

      if (success && context.mounted) {
        Navigator.pushReplacementNamed(context, '/listado_contactos');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loginProvider.errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home_page');
          },
        ),
        title: const Text("Volver", style: TextStyle(color: Colors.white)),
        centerTitle: false,
      ),

      body: Container(
        padding: const EdgeInsets.only(top: 90.0),
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffdb8d2e), Color.fromARGB(255, 7, 59, 105)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.account_circle, size: 120, color: Colors.white),
            const SizedBox(height: 10),
            const Text(
              "Mi Agenda",
              style: TextStyle(color: Colors.white, fontSize: 36.0),
            ),
            const SizedBox(height: 20.0),

            // Formulario de login
            _buildLoginForm(),
          ],
        ),
      ),
    );
  }

  //Metodo para construir el formulario de login
  Widget _buildLoginForm() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Email",
                style: TextStyle(color: Color(0xff661c3a), fontSize: 24),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: "Ingrese su email",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                onSubmitted: (_) => _login(), // Enter para login
              ),
              const SizedBox(height: 30),
              const Text(
                "Contraseña",
                style: TextStyle(color: Color(0xff661c3a), fontSize: 24),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Ingrese su contraseña",
                  prefixIcon: Icon(Icons.password_outlined),
                ),
                onSubmitted: (_) => _login(), // Enter para login
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "¿Olvidó su contraseña?",
                  style: TextStyle(color: Colors.blue.shade700, fontSize: 16),
                ),
              ),
              const SizedBox(height: 50),

              // Botón de login con estado de carga
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GestureDetector(
                      onTap: _login,
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromARGB(255, 224, 127, 7),
                              const Color(0xff5087b6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            "Iniciar Sesión",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
