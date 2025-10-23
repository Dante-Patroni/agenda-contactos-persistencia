import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 🧩 Providers
import 'package:agenda_contactos/providers/login_provider.dart';
import 'package:agenda_contactos/providers/contacto_provider.dart';

// 🧭 Páginas
import 'package:agenda_contactos/pages/login.dart';
import 'package:agenda_contactos/pages/nuevo_contacto.dart';
import 'package:agenda_contactos/pages/listado_contactos.dart';
import 'package:agenda_contactos/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Agenda',
      debugShowCheckedModeBanner: false,
      home: const AuthChecker(), // Verifica login al inicio
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
    return const Login();
  }
}
