import "package:flutter/material.dart";
import 'package:agenda_contactos/models/contacto.dart';
import 'package:provider/provider.dart';
import 'package:agenda_contactos/providers/contacto_provider.dart';
import 'package:agenda_contactos/providers/login_provider.dart';
import 'package:agenda_contactos/pages/nuevo_contacto.dart';

class ListadoContactos extends StatefulWidget {
  const ListadoContactos({super.key});

  @override
  State<ListadoContactos> createState() => _ListadoContactosState();
}

class _ListadoContactosState extends State<ListadoContactos> {
  bool _buscando = false;
  String _filtroBusqueda = "";
  final TextEditingController _controladorBusqueda = TextEditingController();

  void _showSearch() {
    setState(() {
      if (_buscando) {
        _filtroBusqueda = "";
        _controladorBusqueda.clear();
      }
      _buscando = !_buscando;
    });
  }

  Future<void> _confirmarLogout() async {
    final loginProvider = context.read<LoginProvider>();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cerrar sesión"),
        content: const Text("¿Estás seguro de que quieres cerrar sesión?"),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text("Salir", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      await loginProvider.logout();
      Navigator.of(context).pushNamedAndRemoveUntil('/home_page', (route) => false);

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
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: _buscando
                ? TextField(
                    controller: _controladorBusqueda,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: const InputDecoration(
                      hintText: "Buscar contacto...",
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
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
            actions: [
              IconButton(
                icon: Icon(
                  _buscando ? Icons.close : Icons.search,
                  color: Colors.white,
                  size: 30.0,
                ),
                onPressed: _showSearch,
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white, size: 26.0),
                tooltip: "Cerrar sesión",
                onPressed: _confirmarLogout,
              ),
            ],
          ),
        ),
      ),
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
          child: Consumer<ContactoProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) return _buildLoadingScreen();
              if (provider.contactos.isEmpty) return _buildEmptyState();

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
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
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
                                          builder: (context) => Nuevo_Contacto(
                                            contactoEditar: contacto,
                                            indexEditar: indexOriginal,
                                          ),
                                        ),
                                      );
                                      // 🔹 Refresca lista después de volver
                                      setState(() {});
                                    }
                                  },
                                ),
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
                                IconButton(
                                  icon: const Icon(
                                    Icons.phone,
                                    color: Colors.green,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    // Implementar llamada con url_launcher
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 18.0, right: 18.0),
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.pushNamed(context, '/nuevo_contacto');
            setState(() {}); // 🔹 refresca al volver
          },
          backgroundColor: const Color(0xffb51837),
          foregroundColor: Colors.white,
          child: const Icon(Icons.add, size: 35),
        ),
      ),
    );
  }

  // --- Widgets auxiliares ---
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
