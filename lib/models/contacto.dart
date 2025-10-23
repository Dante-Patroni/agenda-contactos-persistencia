// lib/models/contacto.dart
class Contacto {
  int? id; // puede ser null antes de insertarlo en la base
  String nombre;
  String apellido;
  String telefono;
  String email;
  String direccion;
  String genero;

  Contacto({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.email,
    required this.direccion,
    required this.genero,
  });

  // ✅ Getter estilo del profesor
  Map<String, dynamic> get toMap => {
    'id': id,
    'nombre': nombre,
    'apellido': apellido,
    'telefono': telefono,
    'email': email,
    'direccion': direccion,
    'genero': genero,
  };

  // 🔁 Método de fábrica: crea un Contacto desde un Map (SQLite → objeto)
  factory Contacto.fromMap(Map<String, dynamic> map) => Contacto(
    id: map['id'],
    nombre: map['nombre'],
    apellido: map['apellido'],
    telefono: map['telefono'],
    email: map['email'],
    direccion: map['direccion'],
    genero: map['genero'],
  );

  // 🔄 copyWith: permite copiar el contacto y cambiar solo un campo
  Contacto copyWith({
    int? id,
    String? nombre,
    String? apellido,
    String? telefono,
    String? email,
    String? direccion,
    String? genero,
  }) => Contacto(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    apellido: apellido ?? this.apellido,
    telefono: telefono ?? this.telefono,
    email: email ?? this.email,
    direccion: direccion ?? this.direccion,
    genero: genero ?? this.genero,
  );
  
  @override
  String toString() {
    return 'Contacto(id: $id, nombre: $nombre, apellido: $apellido, telefono: $telefono)';
  }
   // Validar que el contacto tenga datos mínimos
  bool get esValido => nombre.isNotEmpty && apellido.isNotEmpty && telefono.isNotEmpty;
  
  // Mensaje de error de validación
  String? validar() {
    if (nombre.isEmpty) return 'El nombre es obligatorio';
    if (apellido.isEmpty) return 'El apellido es obligatorio';
    if (telefono.isEmpty) return 'El teléfono es obligatorio';
    if (genero.isEmpty) return 'El género es obligatorio';
    return null;
  }
}

