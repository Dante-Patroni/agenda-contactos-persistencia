import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Providers
import 'package:agenda_contactos/providers/login_provider.dart';
import 'package:agenda_contactos/providers/contacto_provider.dart';

// Pages
import 'package:agenda_contactos/pages/login.dart';
import 'package:agenda_contactos/pages/nuevo_contacto.dart';
import 'package:agenda_contactos/pages/listado_contactos.dart';
import 'package:agenda_contactos/pages/home_page.dart';

/// Punto de entrada principal
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // SQLite para Windows/Linux
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => ContactoProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

/// Raíz de la aplicación.
///
/// Define título, rutas y la pantalla inicial a través de `AuthChecker`.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Agenda',
      debugShowCheckedModeBanner: false,

      home: const AuthChecker(), // VEIFICO EL LOGIN AL INICIO  
      routes: {
        '/inicio': (context) => const ListadoContactos(),
        '/home_page': (context) => const HomePage(),
        '/login': (context) => const Login(),
        '/listado_contactos': (context) => const ListadoContactos(),
        '/nuevo_contacto': (context) => const Nuevo_Contacto(),
      },
    );
  }
}

/// Determina la pantalla inicial en función del estado de autenticación.
///
/// Contrato:
/// - Mientras `LoginProvider.isCheckingAuth` sea `true`, muestra un loading.
/// - Si hay sesión activa, muestra `ListadoContactos`.
/// - En caso contrario, navega a `Login`.
class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);

    // 🔸 Mientras verifica autenticación
    if (loginProvider.isCheckingAuth) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 🔹 Si está logueado, va al listado
    if (loginProvider.isLoggedIn) {
      return const ListadoContactos();
    }

    // 🔸 Si no está logueado, va al login
    return const HomePage ();
  }
}
