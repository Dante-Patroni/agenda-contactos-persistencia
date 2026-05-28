// pages/inicio.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agenda_contactos/providers/login_provider.dart';
import 'package:agenda_contactos/pages/listado_contactos.dart';

class Inicio extends StatelessWidget {
  const Inicio({super.key});

  /// Variante de pantalla contenedora que muestra `ListadoContactos`
  /// con acción de logout en el `AppBar`.
  ///
  /// Nota: funcionalmente solapa con `HomePage`; mantener solo una
  /// pantalla de bienvenida mejoraría la coherencia de navegación.
  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Cerrar sesión",
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Cerrar sesión"),
                  content: const Text("¿Deseas salir de la aplicación?"),
                  actions: [
                    TextButton(
                      child: const Text("Cancelar"),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    TextButton(
                      child: const Text("Salir"),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
              );

              if (confirmar == true && context.mounted)  {
                Navigator.of(context, rootNavigator: true).pop();
                await loginProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Sesión cerrada correctamente"),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  });
                }
              }
            },
          ),
        ],
      ),
      body: const ListadoContactos(),
    );
  }
}
