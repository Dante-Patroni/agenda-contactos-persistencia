import 'package:dio/dio.dart';

/// Cliente HTTP centralizado para consumir la API REST ASP.NET.
///
/// Responsabilidades:
/// - Exponer una única instancia reutilizable de [Dio] en toda la aplicación.
/// - Configurar la URL base del servidor y los encabezados globales de las peticiones.
/// - Establecer tiempos de espera (*timeouts*) de conexión y recepción para prevenir bloqueos indefinidos.
/// - Actuar como punto único de mantenimiento para la configuración de red (permite cambiar *endpoints* e
///   interceptores JWT de forma centralizada sin modificar el resto de servicios).
class ApiClient {
  // 🔧 Instancia compartida de Dio configurada con las opciones base de la API
  static final Dio dio = Dio(
    BaseOptions(
      // ⚠ IMPORTANTE:
      // Android Emulator => 10.0.2.2
      // Web/Desktop       => localhost
      baseUrl: 'http://localhost:5148/api',

      // 📋 Cabecera por defecto: indica que el cuerpo de todas las peticiones será JSON
      headers: {
        'Content-Type': 'application/json',
      },

      // ⏱ Tiempo máximo de espera para establecer la conexión TCP con el servidor
      connectTimeout: const Duration(seconds: 10),

      // ⏱ Tiempo máximo de espera para recibir una respuesta completa del servidor
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
}