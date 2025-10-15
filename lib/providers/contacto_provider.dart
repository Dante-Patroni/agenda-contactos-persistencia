import "dart:collection";//para que solo se pueda leer la lista
import "package:flutter/material.dart";
import "package:agenda_contactos/models/contacto.dart";

class ContactoProvider extends ChangeNotifier {//notifica a los widgets cuando cambian los datos
  final List<Contacto> _contactos = []; //privado

  UnmodifiableListView<Contacto> get contactos => UnmodifiableListView(
    _contactos,
  ); //de solo lectura, sólo se modifica desde el provider

  Set<Contacto> contactosSeleccionados = {};
  List<Contacto> contactosSeleccionadosList = [];

  ContactoProvider() {
    generarContactos();
  }

//*******************METODOS CRUD************************* */

  void addContacto(Contacto contacto) {
    _contactos.add(contacto);
    notifyListeners();//notifica a los widgets que están escuchando
                      //Actualiza todos los widgets que están escuchando este provider
  }

  void removeContacto(Contacto contacto) {
    _contactos.remove(contacto);
    notifyListeners();
  }

  void updateContacto(int index, Contacto nuevoContacto) {
    if (index >= 0 && index < _contactos.length) {
      _contactos[index] = nuevoContacto;
      notifyListeners();
    }
  }

  void generarContactos() {
    _contactos.add(
      Contacto(
        nombre: "Juan",
        apellido: "Perez",
        telefono: "123456",
        email: "juanperez@gmail.com",
        direccion: "Aaaa 123",
        genero: "M",
      ),
    );

    _contactos.add(
      Contacto(
        nombre: "María",
        apellido: "González",
        telefono: "234567",
        email: "mariagonzalez@gmail.com",
        direccion: "Bbbb 456",
        genero: "F",
      ),
    );

    _contactos.add(
      Contacto(
        nombre: "Carlos",
        apellido: "Rodríguez",
        telefono: "345678",
        email: "carlosrodriguez@gmail.com",
        direccion: "Cccc 789",
        genero: "M",
      ),
    );

    _contactos.add(
      Contacto(
        nombre: "Ana",
        apellido: "López",
        telefono: "456789",
        email: "analopez@gmail.com",
        direccion: "Dddd 101",
        genero: "F",
      ),
    );
  }
}
