import "package:flutter/material.dart";
import 'package:agenda_contactos/models/contacto.dart';
import 'package:provider/provider.dart';
import 'package:agenda_contactos/providers/contacto_provider.dart';
import 'package:agenda_contactos/pages/nuevo_contacto.dart';

class ListadoContactos extends StatefulWidget {//el contenido cambia constantemente
  const ListadoContactos({super.key});

  @override
  State<ListadoContactos> createState() => _ListadoContactosState();
}

class _ListadoContactosState extends State<ListadoContactos> {
  // Función temporal para la búsqueda
  bool _buscando = false;// indica si se está buscando o no
  String _filtroBusqueda = "";// almacena el texto de búsqueda
  // Controlador para el campo de texto de búsqueda
  final TextEditingController _controladorBusqueda = TextEditingController();

  void _showSearch() {//Este buscador se activa al pulsar el icono de la lupa
    setState(() {
      _buscando = !_buscando;
      if (_buscando) {
        _filtroBusqueda = "";
        _controladorBusqueda.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cantidadContactos = context.select<ContactoProvider, int>(
      (value) => value.contactos.length,
    );

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
                ? TextField(//Si buscando es true, muestra el TextField
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
                : const Text(//Si buscando es false, muestra el título normal
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
            ],
          ),
        ),
      ),
      body: Container(
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
        child: SafeArea(
          top: true,
          //Conexión con el Provider, escucha los cambios del ContactoProvider
          child: Consumer<ContactoProvider>(
            builder: (context, provider, child) {
              if (provider.contactos.isEmpty) {
                // Vista cuando NO hay contactos
                return Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                          vertical: 50.0,
                        ),
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/caja_vacia.png",
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Aún no tienes contactos",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Vista cuando SÍ hay contactos
                final contactosFiltrados = provider.contactos.where((c) {
                  final nombreCompleto = "${c.nombre} ${c.apellido}"
                      .toLowerCase();
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

                      //tarjeta de cada contacto
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
                              // Parte superior: avatar + nombre + datos básicos
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

                              // Iconos de acciones: editar, eliminar, llamar
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  //Botón de editar
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.orange,
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      // Encuentra el índice real del contacto en la lista original
                                      final indexOriginal = provider.contactos
                                          .indexOf(contacto);

                                      //Nuevo contacto 
                                      if (indexOriginal != -1) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                Nuevo_Contacto(
                                                  contactoEditar: contacto,
                                                  indexEditar: indexOriginal,
                                                ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  //Botón de eliminar con diálogo de confirmación
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                              "Confirmar eliminación",
                                            ),
                                            content: Text(
                                              "¿Seguro que quieres eliminar a ${contacto.nombre}?",
                                            ),
                                            actions: [
                                              TextButton(
                                                child: const Text("Cancelar"),
                                                onPressed: () {
                                                  Navigator.of(
                                                    context,
                                                  ).pop(); // Cierra el diálogo
                                                },
                                              ),
                                              TextButton(
                                                child: const Text(
                                                  "Eliminar",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  context
                                                      .read<ContactoProvider>()
                                                      .removeContacto(contacto);
                                                  Navigator.of(
                                                    context,
                                                  ).pop(); // Cierra el diálogo

                                                  ScaffoldMessenger.of(context)
                                                    ..hideCurrentSnackBar()
                                                    ..showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          "${contacto.nombre} eliminado",
                                                        ),
                                                      ),
                                                    );
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.phone,
                                      color: Colors.green,
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      // TODO: llamar (con url_launcher)
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
              }
            },
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 18.0, right: 18.0),
        child: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/nuevo_contacto'),
          backgroundColor: Color(0xffb51837),
          foregroundColor: Colors.white,
          child: const Icon(Icons.add, size: 35),
        ),
      ),
    );
  }
}
