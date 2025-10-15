import 'package:flutter/material.dart';
import 'package:agenda_contactos/pages/inicio.dart';
import 'package:agenda_contactos/pages/listado_contactos.dart';
import 'package:agenda_contactos/pages/login.dart';
import 'package:agenda_contactos/pages/nuevo_contacto.dart';
import 'package:agenda_contactos/providers/contacto_provider.dart';
import 'package:provider/provider.dart';

void main() => runApp(
  ChangeNotifierProvider(//cargo el provider
    create: (context) => ContactoProvider(),
    child: MyApp(),
  ),
);

class MyApp extends StatelessWidget {//su estrucura principal no cambia
  const MyApp({super.key});

  //Este widget es la raíz de la aplicación.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Contactos',
      debugShowCheckedModeBanner: false,//quita la etiqueta de debug
      home: const Inicio(),
      routes: {
        '/login': (context) => const Login(),
        '/listado_contactos': (context) => const ListadoContactos(),
        '/nuevo_contacto': (context) => const Nuevo_Contacto(),
      },
    );
  }
}
