import "package:flutter/material.dart";
import "package:agenda_contactos/pages/listado_contactos.dart";
import 'package:provider/provider.dart';
import 'package:agenda_contactos/providers/contacto_provider.dart';
import 'package:agenda_contactos/models/contacto.dart';

class Nuevo_Contacto extends StatefulWidget {
  final Contacto? contactoEditar; //Null si es nuevo, con datos si es edición
  final int? indexEditar;

  const Nuevo_Contacto({super.key, this.contactoEditar, this.indexEditar});

  @override
  State<Nuevo_Contacto> createState() => _Nuevo_ContactoState();
}

class _Nuevo_ContactoState extends State<Nuevo_Contacto> {
  String? _sexoSeleccionado; // 'M' para masculino, 'F' para femenino

  // Controladores para los campos de texto
  final TextEditingController _nombreCtrl = TextEditingController();//obtengo el texto ingresado
  final TextEditingController _apellidoCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();
  final TextEditingController _domicilioCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();

  // Variable para saber si estamos editando
  bool get _esEdicion => widget.contactoEditar != null;

  @override
  // Inicializamos los controladores si estamos en modo edición
  void initState() {
    super.initState();

    // Si estamos editando, llenamos los campos con los datos existentes
    if (_esEdicion) {
      _nombreCtrl.text = widget.contactoEditar!.nombre;
      _apellidoCtrl.text = widget.contactoEditar!.apellido;
      _telefonoCtrl.text = widget.contactoEditar!.telefono;
      _domicilioCtrl.text = widget.contactoEditar!.direccion;
      _emailCtrl.text = widget.contactoEditar!.email;
      _sexoSeleccionado = widget.contactoEditar!.genero;
    } else {
      // Si es nuevo, valor por defecto para género
      _sexoSeleccionado = 'M';
    }
  }

  @override
  //Limpieza de memoria cuando se cierra la pantalla
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _telefonoCtrl.dispose();
    _domicilioCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      //AppBar dinámico, cambia título y acciones según modo
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            // Título dinámico
            title: Text(
              _esEdicion ? "Editar Contacto" : "Nuevo Contacto",
              style: TextStyle(
                color: Colors.white,
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: Icon(Icons.check, color: Colors.white),
                onPressed: () {
                  // Validación básica, antes de guardar valido que no estén vacíos
                  if (_nombreCtrl.text.isEmpty || _apellidoCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Nombre y Apellido son obligatorios"),
                      ),
                    );
                    return;
                  }
                  // Crear o actualizar el contacto
                  final contactoActualizado = Contacto(
                    nombre: _nombreCtrl.text,
                    apellido: _apellidoCtrl.text,
                    telefono: _telefonoCtrl.text,
                    direccion: _domicilioCtrl.text,
                    email: _emailCtrl.text,
                    genero: _sexoSeleccionado ?? "M",
                  );

                  if (_esEdicion && widget.indexEditar != null) {//si es edición y tengo el índice
                    // Modo edición - usar updateContacto
                    context.read<ContactoProvider>().updateContacto(
                      widget.indexEditar!,
                      contactoActualizado,
                    );
                  } else {
                    // Modo nuevo - usar addContacto
                    context.read<ContactoProvider>().addContacto(
                      contactoActualizado,
                    );
                  }

                  Navigator.pop(context); // vuelve al listado
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 90.0),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
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
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 50.0, left: 30.0, right: 30.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  // ← Agregado para scroll
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nombre",
                        style: TextStyle(
                          color: Color(0xff661c3a),
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextField(
                        controller: _nombreCtrl,
                        decoration: InputDecoration(
                          hintText: "Ingrese nombre",
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        "Apellido",
                        style: TextStyle(
                          color: Color(0xff661c3a),
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextField(
                        controller: _apellidoCtrl,
                        decoration: InputDecoration(
                          hintText: "Ingrese apellido",
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        "Teléfono",
                        style: TextStyle(
                          color: Color(0xff661c3a),
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextField(
                        controller: _telefonoCtrl,
                        decoration: InputDecoration(
                          hintText: "Ingrese teléfono",
                          prefixIcon: Icon(Icons.phone_android_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        "Domicilio",
                        style: TextStyle(
                          color: Color(0xff661c3a),
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextField(
                        controller: _domicilioCtrl,
                        decoration: InputDecoration(
                          hintText: "Ingrese domicilio",
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        "Email",
                        style: TextStyle(
                          color: Color(0xff661c3a),
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextField(
                        controller: _emailCtrl,
                        decoration: InputDecoration(
                          hintText: "Ingrese su email",
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        "Género",
                        style: TextStyle(
                          color: Color(0xff661c3a),
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      //Radio Buttons
                      Container(
                        // ← Contenedor para mejorar la apariencia
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Radio(
                                  value: 'M',
                                  groupValue: _sexoSeleccionado,
                                  onChanged: (value) {
                                    setState(() {
                                      _sexoSeleccionado = value;
                                    });
                                  },
                                ),
                                title: Text("Masculino"),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Radio(
                                  value: 'F',
                                  groupValue: _sexoSeleccionado,
                                  onChanged: (value) {
                                    setState(() {
                                      _sexoSeleccionado = value;
                                    });
                                  },
                                ),
                                title: Text("Femenino"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30.0), // ← Espacio final
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
