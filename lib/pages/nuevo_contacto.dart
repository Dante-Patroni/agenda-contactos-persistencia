import "package:flutter/material.dart";
import 'package:agenda_contactos/models/contacto.dart';
import 'package:provider/provider.dart';
import 'package:agenda_contactos/providers/contacto_provider.dart';

class Nuevo_Contacto extends StatefulWidget {
  final Contacto? contactoEditar;  // null si es nuevo, datos si es edición
  final int? indexEditar;//indice del contacto a editar o null si es nuevo

  const Nuevo_Contacto({super.key, this.contactoEditar, this.indexEditar});

  @override
  State<Nuevo_Contacto> createState() => _Nuevo_ContactoState();
}

class _Nuevo_ContactoState extends State<Nuevo_Contacto> {

  // ============================================================
  // CONTROLADORES DE TEXTO (almacenan lo que el usuario escribe)
  // ============================================================
  final TextEditingController _idCrl = TextEditingController();
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidoCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();
  final TextEditingController _domicilioCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();

  // ============================================================
  // GÉNERO SELECCIONADO ('M' o 'F')
  // ============================================================
  String? _sexoSeleccionado;

  // ============================================================
  // INDICA SI ESTAMOS EDITANDO O CREANDO NUEVO
  // ============================================================
  bool get _esEdicion => widget.contactoEditar != null;

  // ============================================================
  // CICLO DE VIDA: INITSTATE
  // Se ejecuta 1 sola vez al abrir la pantalla.
  // Si es edición → precarga los datos en los TextFields.
  // Si es un contacto nuevo → inicializa valores por defecto.
  // ============================================================
  @override
  void initState() {//Se ejecuta 1 sola vez al abrir la pantalla.
    super.initState();

    if (_esEdicion) {
      // Precargo los datos en los campos
      _idCrl.text = widget.contactoEditar!.id.toString();
      _nombreCtrl.text = widget.contactoEditar!.nombre;
      _apellidoCtrl.text = widget.contactoEditar!.apellido;
      _telefonoCtrl.text = widget.contactoEditar!.telefono;
      _domicilioCtrl.text = widget.contactoEditar!.direccion;
      _emailCtrl.text = widget.contactoEditar!.email;
      _sexoSeleccionado = widget.contactoEditar!.genero;
    } else {
      // Valor por defecto para nuevos contactos
      _sexoSeleccionado = 'M';
    }
  }

  // ============================================================
  // CICLO DE VIDA: DISPOSE
  // Limpia la memoria cuando la pantalla se cierra.
  // ============================================================
  @override
  void dispose() {
    _idCrl.dispose();
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _telefonoCtrl.dispose();
    _domicilioCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD → DIBUJA TODA LA PANTALLA
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      // ============================================================
      // APPBAR (Botón cerrar, título dinámico, botón guardar)
      // ============================================================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,

            // BOTÓN DE CERRAR (volver al listado)
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),

            // TÍTULO según estamos editando o agregando
            title: Text(
              _esEdicion ? "Editar Contacto" : "Nuevo Contacto",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),

            // BOTÓN GUARDAR (check)
            actions: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.white),
                onPressed: () async {
                  // ================================================
                  // VALIDACIÓN
                  // ================================================
                  if (_nombreCtrl.text.isEmpty ||
                      _apellidoCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Nombre y Apellido son obligatorios")),
                    );
                    return;
                  }

                  // ================================================
                  // CREO EL OBJETO CONTACTO (nuevo o editado)
                  // ================================================
                  final contactoActualizado = Contacto(
                    id: _esEdicion ? widget.contactoEditar!.id : null,
                    nombre: _nombreCtrl.text,
                    apellido: _apellidoCtrl.text,
                    telefono: _telefonoCtrl.text,
                    direccion: _domicilioCtrl.text,
                    email: _emailCtrl.text,
                    genero: _sexoSeleccionado ?? "M",
                  );

                  final provider = context.read<ContactoProvider>();

                  // ================================================
                  // GUARDADO (update o insert)
                  // ================================================
                  if (_esEdicion) {
                    await provider.updateContacto(
                      contactoActualizado.copyWith(
                        id: widget.contactoEditar!.id,
                      ),
                    );
                  } else {
                    await provider.addContacto(contactoActualizado);
                  }

                  // ================================================
                  // VUELVE AL LISTADO
                  // ================================================
                  if (!mounted) return;
                  Navigator.pop(context);

                  // Mensaje
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _esEdicion
                            ? "Contacto actualizado correctamente"
                            : "Contacto agregado correctamente",
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // ============================================================
      // BODY → FORMULARIO COMPLETO
      // ============================================================
      body: Container(
        padding: const EdgeInsets.only(top: 90.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffdb8d2e), Color.fromARGB(255, 7, 59, 105)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Column(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.only(top: 50.0, left: 30.0, right: 30.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),

                // FORMULARIO SCROLLEABLE
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      // ====================================================
                      // CAMPO NOMBRE
                      // ====================================================
                      _buildLabel("Nombre"),
                      TextField(
                        controller: _nombreCtrl,
                        decoration: const InputDecoration(
                          hintText: "Ingrese nombre",
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ====================================================
                      // CAMPO APELLIDO
                      // ====================================================
                      _buildLabel("Apellido"),
                      TextField(
                        controller: _apellidoCtrl,
                        decoration: const InputDecoration(
                          hintText: "Ingrese apellido",
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ====================================================
                      // CAMPO TELEFONO
                      // ====================================================
                      _buildLabel("Teléfono"),
                      TextField(
                        controller: _telefonoCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: "Ingrese teléfono",
                          prefixIcon: Icon(Icons.phone_android_outlined),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ====================================================
                      // CAMPO DOMICILIO
                      // ====================================================
                      _buildLabel("Domicilio"),
                      TextField(
                        controller: _domicilioCtrl,
                        decoration: const InputDecoration(
                          hintText: "Ingrese domicilio",
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ====================================================
                      // CAMPO EMAIL
                      // ====================================================
                      _buildLabel("Email"),
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: "Ingrese su email",
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ====================================================
                      // SEXO (RADIOS)
                      // ====================================================
                      _buildLabel("Género"),
                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Radio(
                                  value: 'M',
                                  groupValue: _sexoSeleccionado,
                                  onChanged: (value) {
                                    setState(() => _sexoSeleccionado = value);
                                  },
                                ),
                                title: const Text("Masculino"),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Radio(
                                  value: 'F',
                                  groupValue: _sexoSeleccionado,
                                  onChanged: (value) {
                                    setState(() => _sexoSeleccionado = value);
                                  },
                                ),
                                title: const Text("Femenino"),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
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

  // ============================================================
  // PEQUEÑO WIDGET AUXILIAR PARA TÍTULOS DE FORMULARIO
  // ============================================================
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xff661c3a),
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
