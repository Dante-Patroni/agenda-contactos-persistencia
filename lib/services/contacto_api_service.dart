import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/contacto.dart';
import 'api_client.dart';

/// Servicio encargado de gestionar la comunicación con los endpoints de la API REST
/// para el recurso de Contactos, administrando la autenticación mediante tokens JWT.
///
/// Responsabilidades:
/// - Ejecutar peticiones HTTP (GET, POST, PUT, DELETE) hacia la API de Contactos.
/// - Inyectar el token JWT de autorización en cada solicitud de forma automática.
/// - Transformar las respuestas JSON del servidor en entidades fuertemente tipadas [Contacto].
class ContactoApiService {
  // --- Gestión de autenticación ---

  /// Recupera el token de acceso JWT almacenado de forma persistente en las preferencias locales del dispositivo.
  ///
  /// Consulta el almacenamiento interno de [SharedPreferences] buscando la clave `jwt_token`,
  /// que fue previamente guardada durante el flujo de inicio de sesión ([AuthApiService.login]).
  ///
  /// Returns: Un [String] con el token si existe; de lo contrario, `null`.
  Future<String?> _getToken() async {
    // 🔑 Lectura del token JWT desde el almacenamiento persistente de clave-valor
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  /// Construye la configuración de las opciones de la petición HTTP,
  /// inyectando el token JWT en la cabecera 'Authorization' siguiendo el esquema Bearer.
  ///
  /// Este método es utilizado internamente por todas las operaciones CRUD para asegurar
  /// que cada petición enviada al servidor incluya las credenciales de acceso necesarias.
  ///
  /// Returns: Un objeto [Options] configurado con las cabeceras de autenticación requeridas.
  Future<Options> _authOptions() async {
    // 🔑 Obtención del token almacenado localmente
    final token = await _getToken();

    // 📋 Construcción de la cabecera de autorización con el esquema Bearer
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // --- Operaciones CRUD ---

  /// Realiza una petición HTTP GET para obtener el listado completo de contactos del usuario autenticado.
  ///
  /// Construye una solicitud al endpoint `/Contactos` incluyendo el token JWT en las cabeceras.
  /// La respuesta JSON es transformada a una lista de objetos [Contacto] mapeando manualmente
  /// cada campo del cuerpo de la respuesta.
  ///
  /// Los campos `apellido`, `direccion` y `genero` se inicializan como cadena vacía si la API
  /// no los incluye en su respuesta, garantizando que el modelo nunca tenga valores `null`.
  ///
  /// Throws: [DioException] si la petición falla o el token es inválido/expirado.
  /// Returns: Una lista de objetos [Contacto] mapeados desde el JSON recibido de la API.
  Future<List<Contacto>> obtenerContactos() async {
    // 🔐 Preparación de las opciones de autenticación para la petición
    final options = await _authOptions();

    // 🌐 Petición HTTP GET al endpoint protegido de contactos
    final response = await ApiClient.dio.get('/Contactos', options: options);

    // 📦 Extracción de la colección JSON desde el cuerpo de la respuesta
    final List data = response.data;

    // 🔄 Transformación de datos JSON planos a entidades fuertemente tipadas de Dart
    return data.map((json) {
      return Contacto(
        id: json['id'],
        nombre: json['nombre'],
        apellido: '', // Valor por defecto si la API no provee este campo
        telefono: json['telefono'],
        email: json['email'],
        direccion: '', // Valor por defecto si la API no provee este campo
        genero: '',    // Valor por defecto si la API no provee este campo
      );
    }).toList();
  }

  /// Realiza una petición HTTP POST para dar de alta un nuevo registro de contacto en el servidor remoto.
  ///
  /// Serializa la entidad [contacto] a formato JSON mediante [Contacto.toJson] y la envía
  /// como cuerpo de la petición al endpoint `/Contactos`. La autorización se incluye
  /// automáticamente a través de las opciones de autenticación.
  ///
  /// [contacto]: La entidad local que contiene los datos del contacto que se desea persistir.
  /// Throws: [DioException] si el servidor rechaza la solicitud o hay problemas de conectividad.
  Future<void> crearContacto(Contacto contacto) async {
    // 🔐 Preparación de las opciones de autenticación para la petición
    final options = await _authOptions();

    // 🌐 Petición HTTP POST al endpoint de contactos con los datos serializados del nuevo recurso
    await ApiClient.dio.post(
      '/Contactos',
      options: options,
      data: contacto.toJson(),
    );
  }

  /// Realiza una petición HTTP DELETE para eliminar un contacto específico del servidor por su identificador único.
  ///
  /// Construye la URL del recurso a eliminar interpolando el [id] en el endpoint (`/Contactos/{id}`).
  /// Incluye el token JWT en las cabeceras de la petición para garantizar el acceso autorizado.
  ///
  /// [id]: El identificador único del contacto que se desea remover del sistema.
  /// Throws: [DioException] si ocurre un error en la eliminación o el recurso no existe.
  Future<void> eliminarContacto(int id) async {
    // 🔐 Preparación de las opciones de autenticación para la petición
    final options = await _authOptions();

    // 🌐 Petición HTTP DELETE al endpoint específico del contacto identificado por [id]
    await ApiClient.dio.delete('/Contactos/$id', options: options);
  }

  /// Realiza una petición HTTP PUT para modificar de forma integral un registro de contacto existente en el servidor remoto.
  ///
  /// Utiliza el identificador único del [contacto] para construir la URL del endpoint específico (`/Contactos/{id}`).
  /// Envía en el cuerpo de la solicitud un mapa estructurado clave-valor (JSON) con los atributos actualizados.
  ///
  /// Si la operación es exitosa, imprime un mensaje de confirmación en consola con la respuesta del servidor.
  /// En caso de error, imprime el detalle de la excepción y relanza la misma para que la capa superior
  /// (Provider/UI) pueda manejarla adecuadamente.
  ///
  /// [contacto]: La entidad local que contiene las modificaciones hechas por el usuario y que serán persistidas en el servidor.
  /// Throws: [DioException] si el servidor devuelve un código de estado de error (ej. 404 No encontrado, 400 Petición incorrecta) o por problemas de red.
  Future<void> actualizarContacto(Contacto contacto) async {
    try {
      // 🔐 Preparación de las opciones de autenticación para la petición
      final options = await _authOptions();

      // 🌐 Petición HTTP PUT al endpoint específico del contacto con los datos modificados
      final response = await ApiClient.dio.put(
        '/Contactos/${contacto.id}',
        options: options,
        data: contacto.toJson(),
      );

      // ✅ Confirmación en consola del resultado exitoso de la actualización
      print("✅ UPDATE OK");
      print(response.data);
    } catch (e) {
      // ❌ Captura y registro del error ocurrido durante la actualización remota
      print("❌ ERROR UPDATE API");
      print(e);

      // 🔄 Relanza la excepción para que el Provider ejecute el flujo de fallback offline
      rethrow;
    }
  }
}
