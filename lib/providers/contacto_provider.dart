import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:agenda_contactos/models/contacto.dart';
import 'package:agenda_contactos/database/contacto_db_helper.dart';

class ContactoProvider extends ChangeNotifier {
  final List<Contacto> _contactos = [];
  UnmodifiableListView<Contacto> get contactos => UnmodifiableListView(_contactos);

  final ContactoDBHelper _dbHelper = ContactoDBHelper.instance;
  bool isLoading = true;

  // 🚀 Se llama automáticamente al crear el provider
  ContactoProvider() {
    _loadContactos();
  }

  // Carga los contactos desde SQLite
  Future<void> _loadContactos() async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await _dbHelper.getContactos();
      _contactos
        ..clear()
        ..addAll(data);
    } catch (e) {
      debugPrint("❌ Error al cargar contactos: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  // --- CRUD conectados con SQLite ---

  Future<void> addContacto(Contacto contacto) async {
    try {
      await _dbHelper.insertContacto(contacto);
      await _loadContactos();
    } catch (e) {
      debugPrint("❌ Error al agregar contacto: $e");
    }
  }

  Future<void> removeContacto(Contacto contacto) async {
    if (contacto.id == null) return;
    try {
      await _dbHelper.deleteContacto(contacto.id!);
      _contactos.removeWhere((c) => c.id == contacto.id);
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error al eliminar contacto: $e");
    }
  }

  Future<void> updateContacto(Contacto contacto) async {
    try {
      await _dbHelper.updateContacto(contacto);

      // 🔹 Actualiza solo el contacto modificado sin recargar toda la lista
      final index = _contactos.indexWhere((c) => c.id == contacto.id);
      if (index != -1) {
        _contactos[index] = contacto;
        notifyListeners();
      } else {
        await _loadContactos();
      }
    } catch (e) {
      debugPrint("❌ Error al actualizar contacto: $e");
    }
  }

  // --- Generar contactos demo (para pruebas) ---
  Future<void> generarContactosDemo() async {
    final contactosDemo = [
      Contacto(
        nombre: "Juan",
        apellido: "Pérez",
        telefono: "123456",
        email: "juanperez@gmail.com",
        direccion: "Avenida Siempre Viva 123",
        genero: "M",
      ),
      Contacto(
        nombre: "María",
        apellido: "González",
        telefono: "234567",
        email: "mariagonzalez@gmail.com",
        direccion: "Calle Falsa 456",
        genero: "F",
      ),
    ];

    for (var c in contactosDemo) {
      await _dbHelper.insertContacto(c);
    }
    await _loadContactos();
  }
}
