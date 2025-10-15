import "package:flutter/material.dart";
import 'package:agenda_contactos/pages/listado_contactos.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

//Controladores para capturar el email y la contraseña
class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //Función para validar el login
  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email == "admin@gmail.com" && password == "1234") {
      //reemplaza la pantalla actual(login) por la nueva pantalla(listado contactos)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ListadoContactos()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Usuario o contraseña incorrectos"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // 👈 asegura que el teclado no tape la vista
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
            colors: [
              Color(0xffdb8d2e),
              Color.fromARGB(255, 7, 59, 105), // azul opaco
            ],
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
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 50,
                ),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  // 👈 permite scroll cuando aparece el teclado
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Email",
                        style: TextStyle(
                          color: Color(0xff661c3a),
                          fontSize: 24,
                        ),
                      ),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: "Ingrese su email",
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "Contraseña",
                        style: TextStyle(
                          color: Color(0xff661c3a),
                          fontSize: 24,
                        ),
                      ),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: "Ingrese su contraseña",
                          prefixIcon: Icon(Icons.password_outlined),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "¿Olvidó su contraseña?",
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      GestureDetector(
                        onTap: _login,
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(255, 224, 127, 7),
                                Color(0xff5087b6), // azul opaco
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
            ),
          ],
        ),
      ),
    );
  }
}
