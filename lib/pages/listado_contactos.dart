import "package:flutter/material.dart";
import 'package:agenda_contactos/models/contacto.dart';
import 'package:provider/provider.dart';
import 'package:agenda_contactos/providers/contacto_provider.dart';
import 'package:agenda_contactos/providers/login_provider.dart';
import 'package:agenda_contactos/pages/nuevo_contacto.dart';

class ListadoContactos extends StatefulWidget {
  const ListadoContactos({super.key});

  /// Esta pantalla representa el módulo principal de la aplicación
  /// al que solo se accede tras un inicio de sesión válido.
  ///
  /// Funcionalidades:
  /// ✔ Visualizar contactos almacenados en SQLite
  /// ✔ Buscar contactos localmente
  /// ✔ Editar y eliminar contactos
  /// ✔ Cerrar sesión (actualiza SharedPreferences)
  @override
  State<ListadoContactos> createState() => _ListadoContactosState();
}

class _ListadoContactosState extends State<ListadoContactos> {
  // Estado interno para controlar si la barra de búsqueda está activa o no.
  bool _buscando = false;

  // Texto ingresado en el cuadro de búsqueda.
  String _filtroBusqueda = "";

  // Controlador para manejar lo que el usuario escribe en el buscador.
  final TextEditingController _controladorBusqueda = TextEditingController();

  /// Activa o desactiva el modo búsqueda.
  /// Cuando se cierra la búsqueda se limpian los filtros.
  void _showSearch() {
    setState(() {
      if (_buscando) {
        _filtroBusqueda = "";
        _controladorBusqueda.clear();
      }
      _buscando = !_buscando;
    });
  }

  /// Ejecuta el proceso de cierre de sesión:
  /// - Pide confirmación mediante un AlertDialog.
  /// - Llama al provider de login para actualizar SharedPreferences.
  /// - Limpia la pila de rutas y vuelve a la pantalla inicial.
  Future<void> _confirmarLogout() async {
    final loginProvider = context.read<LoginProvider>();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cerrar sesión"),
        content: const Text("¿Estás seguro de que quieres cerrar sesión?"),
        actions: [
          // Botón cancelar → no hace nada
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context, false),
          ),
          // Botón salir → confirma logout
          TextButton(
            child: const Text("Salir", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    // Si el usuario confirmó el cierre de sesión:
    if (confirmar == true && context.mounted) {
      await loginProvider.logout();

      // Elimina cualquier ruta abierta y vuelve al Home de bienvenida.
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/home_page', (route) => false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sesión cerrada correctamente"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  /// Construcción de toda la interfaz gráfica del listado.
  /// Scaffold contiene:
  /// - AppBar dinámico
  /// - Body con gradiente
  /// - Lista consumida desde el Provider
  /// - FAB para agregar nuevos contactos
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      // ***** APPBAR SUPERIOR *****
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),

          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,

            // --- Título dinámico: cambia por buscador dependiendo del estado ---
            title: _buscando
                ? TextField(
                    controller: _controladorBusqueda,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white, fontSize: 18),

                    // Placeholder del buscador
                    decoration: const InputDecoration(
                      hintText: "Buscar contacto...",
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),

                    // Actualiza el filtro conforme se escribe
                    onChanged: (value) {
                      setState(() => _filtroBusqueda = value.toLowerCase());
                    },
                  )

                : const Text(
                    "Contactos",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

            centerTitle: false,

            // --- Botones de acciones: buscar (toggle) y logout ---
            actions: [
              // Botón de sincronizar/refrescar
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white, size: 28.0),
                tooltip: "Sincronizar / Refrescar",
                onPressed: () {
                  context.read<ContactoProvider>().refreshContactos();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Sincronizando...")),
                  );
                },
              ),

              IconButton(
                icon: Icon(
                  _buscando ? Icons.close : Icons.search,
                  color: Colors.white,
                  size: 30.0,
                ),
                onPressed: _showSearch,
              ),

              // Botón de cierre de sesión
              IconButton(
                icon:
                    const Icon(Icons.logout, color: Colors.white, size: 26.0),
                tooltip: "Cerrar sesión",
                onPressed: _confirmarLogout,
              ),
            ],
          ),
        ),
      ),

      // ***** BODY PRINCIPAL *****
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffdb8d2e), Color.fromARGB(255, 7, 59, 105)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          top: true,

          /// Consumer escucha los cambios del ContactoProvider
          child: Consumer<ContactoProvider>(
            builder: (context, provider, child) {
              // Loading inicial mientras se leen los contactos desde SQLite.
              if (provider.isLoading) return _buildLoadingScreen();

              // Si no hay contactos, muestra pantalla vacía.
              if (provider.contactos.isEmpty) return _buildEmptyState();

              // Filtro local sobre la lista obtenida del provider.
              final contactosFiltrados = provider.contactos.where((c) {
                final nombreCompleto =
                    "${c.nombre} ${c.apellido}".toLowerCase();
                return nombreCompleto.contains(_filtroBusqueda);
              }).toList();

              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),

                /// ListViewBuilder → Construcción eficiente y dinámica de tarjetas
                child: ListView.builder(
                  itemCount: contactosFiltrados.length,
                  itemBuilder: (context, index) {
                    final contacto = contactosFiltrados[index];

                    return Card(
                      color: Colors.grey[200],
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 6.0,
                      ),

                      // Contenido de cada tarjeta
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- Encabezado: avatar + datos principales ---
                            Row(
                              children: [
                                // Avatar basado en género
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: contacto.genero == "M"
                                      ? Colors.blue
                                      : Colors.pink,
                                  child: Icon(
                                    contacto.genero == "M"
                                        ? Icons.person
                                        : Icons.person_outline,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                // Datos del contacto
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${contacto.nombre} ${contacto.apellido}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(contacto.telefono),
                                      if (contacto.email.isNotEmpty)
                                        Text(contacto.email),
                                      if (contacto.direccion.isNotEmpty)
                                        Text(contacto.direccion),
                                      if (contacto.genero.isNotEmpty)
                                        Text(
                                          contacto.genero == "M"
                                              ? "Masculino"
                                              : "Femenino",
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // --- Botones de acciones por contacto ---
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                /// BOTÓN EDITAR
                                /// Abre pantalla Nuevo_Contacto en modo edición.
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.orange,
                                    size: 30,
                                  ),
                                  onPressed: () async {
                                    final indexOriginal = provider.contactos
                                        .indexOf(contacto);

                                    if (indexOriginal != -1) {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              Nuevo_Contacto(
                                            contactoEditar: contacto,
                                            indexEditar: indexOriginal,
                                          ),
                                        ),
                                      );

                                      // Refresca la vista al volver
                                      setState(() {});
                                    }
                                  },
                                ),

                                /// BOTÓN ELIMINAR
                                /// Llama a un diálogo de confirmación.
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    _confirmarEliminacion(context, contacto);
                                  },
                                ),

                                /// BOTÓN LLAMAR (futuro)
                                IconButton(
                                  icon: const Icon(
                                    Icons.phone,
                                    color: Colors.green,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    // Futuro: plugin url_launcher
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),

      // ***** BOTÓN FLOTANTE: agregar contacto *****
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 18.0, right: 18.0),
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.pushNamed(context, '/nuevo_contacto');

            // Actualiza vista al regresar de la creación
            setState(() {});
          },
          backgroundColor: const Color(0xffb51837),
          foregroundColor: Colors.white,
          child: const Icon(Icons.add, size: 35),
        ),
      ),
    );
  }

  // =====================================================
  // ============   W I D G E T S   U T I L E S ==========
  // =====================================================

  /// Pantalla mostrada mientras se cargan los contactos desde SQLite.
  Widget _buildLoadingScreen() => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xffdb8d2e)),
          ),
        ),
      );

  /// Vista mostrada cuando no existen contactos en la base.
  Widget _buildEmptyState() => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/caja_vacia.png", height: 200),
              const SizedBox(height: 20),
              const Text(
                "Aún no tienes contactos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );

  /// Cuadro de diálogo para confirmar la eliminación de un contacto.
  /// Si se confirma:
  ///  - Elimina desde el Provider (lo que actualiza SQLite)
  ///  - Muestra un SnackBar informativo
  void _confirmarEliminacion(BuildContext context, Contacto contacto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar eliminación"),
          content: Text("¿Seguro que quieres eliminar a ${contacto.nombre}?"),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
              onPressed: () {
                context.read<ContactoProvider>().removeContacto(contacto);
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text("${contacto.nombre} eliminado")),
                  );
              },
            ),
          ],
        );
      },
    );
  }
}
