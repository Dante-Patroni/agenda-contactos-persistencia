// pages/home_page.dart - PANTALLA DE BIENVENIDA
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffdb8d2e), Color.fromARGB(255, 7, 59, 105)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔹 Logo
            Image.asset(
              "assets/images/logo_dev.png",
              height: 200,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 20.0),

            // 🔹 Título
            const Text(
              "Bienvenido!!!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40.0),

            // 🔹 Botón para ir al Login
            GestureDetector(
              onTap: () {
                // Usa pushReplacementNamed para que no se pueda volver atrás con el botón del sistema
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                margin: const EdgeInsets.symmetric(horizontal: 30.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white60, width: 2.0),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: const Center(
                  child: Text(
                    "INGRESAR",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
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
