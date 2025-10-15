// lib/contact.dart
class Contacto {
  String nombre;
  String apellido;
  String telefono;
  String email;
  String direccion;
  String genero;

  // Constructor
  Contacto({
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.email,
    required this.direccion,
    required this.genero,
  });
  //Si un parametro no se pasa (null), conserva el valor anterior
  Contacto copyWith({
    String? nombre,
    String? apellido,
    String? telefono,
    String? email,
    String? direccion,
    String? genero,
  })=> Contacto(
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      direccion: direccion ?? this.direccion,
      genero: genero ?? this.genero,
    );
  
}
