// lib/models/contacto.dart
/// Entidad de dominio Contacto.
///
/// Representa un registro en la tabla `contactos` y provee utilidades
/// para (de)serializar contra SQLite y operar de forma inmutable.
class Contacto {
  int? id; // puede ser null antes de insertarlo en la base
  String nombre;
  String apellido;
  String telefono;
  String email;
  String direccion;
  String genero;
  int isSync; // 0 = pendiente, 1 = sincronizado

  /// Crea un contacto nuevo o reconstruye uno existente.
  ///
  /// Invariante: los campos de texto deben representar datos válidos para UI/DB.
  Contacto({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.email,
    required this.direccion,
    required this.genero,
    this.isSync = 1, // Por defecto asumimos que está sincronizado
  });

  /// Serializa el contacto a `Map<String, dynamic>` para SQLite.
  Map<String, dynamic> get toMap => {
    'id': id,
    'nombre': nombre,
    'apellido': apellido,
    'telefono': telefono,
    'email': email,
    'direccion': direccion,
    'genero': genero,
    'is_sync': isSync,
  };

  /// Deserializa desde un mapa (fila de SQLite) a entidad `Contacto`.
  factory Contacto.fromMap(Map<String, dynamic> map) => Contacto(
    id: map['id'],
    nombre: map['nombre'],
    apellido: map['apellido'],
    telefono: map['telefono'],
    email: map['email'],
    direccion: map['direccion'],
    genero: map['genero'],
    isSync: map['is_sync'] ?? 1,
  );

  /// Retorna una copia inmutable del contacto modificando los campos indicados.
  Contacto copyWith({
    int? id,
    String? nombre,
    String? apellido,
    String? telefono,
    String? email,
    String? direccion,
    String? genero,
    int? isSync,
  }) => Contacto(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    apellido: apellido ?? this.apellido,
    telefono: telefono ?? this.telefono,
    email: email ?? this.email,
    direccion: direccion ?? this.direccion,
    genero: genero ?? this.genero,
    isSync: isSync ?? this.isSync,
  );

  @override
  String toString() {
    return 'Contacto(id: $id, nombre: $nombre, apellido: $apellido, telefono: $telefono)';
  }

  /// Validación mínima de campos requeridos para persistencia/UI.
  bool get esValido =>
      nombre.isNotEmpty && apellido.isNotEmpty && telefono.isNotEmpty;

  /// Retorna un mensaje de error si los campos obligatorios no son válidos.
  ///
  /// `null` indica que el contacto pasó las validaciones mínimas.
  String? validar() {
    if (nombre.isEmpty) return 'El nombre es obligatorio';
    if (apellido.isEmpty) return 'El apellido es obligatorio';
    if (telefono.isEmpty) return 'El teléfono es obligatorio';
    if (genero.isEmpty) return 'El género es obligatorio';
    return null;
  }

  /// Deserializa un contacto desde JSON recibido desde la API.
  factory Contacto.fromJson(Map<String, dynamic> json) => Contacto(
    id: json['id'],
    nombre: json['nombre'],
    apellido: json['apellido'],
    telefono: json['telefono'],
    email: json['email'],
    direccion: json['direccion'],
    genero: json['genero'],
  );

  /// Serializa el contacto a JSON para enviar a la API.
  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'apellido': apellido,
    'telefono': telefono,
    'email': email,
    'direccion': direccion,
    'genero': genero,
  };
}
