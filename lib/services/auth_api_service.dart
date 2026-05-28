import 'package:dio/dio.dart';
import 'api_client.dart';

/// Servicio encargado de gestionar la autenticación de usuarios contra la API REST ASP.NET.
///
/// Responsabilidades:
/// - Intercambiar credenciales de usuario (email y contraseña) por un token JWT de acceso.
/// - Manejar excepciones de red y errores de autenticación retornando `null` en lugar de propagar excepciones.
/// - Exponer un mecanismo simple de *login* que consuma el endpoint `/Auth/login`.
class AuthApiService {
  // --- Autenticación ---

  /// Envía las credenciales del usuario al servidor y recupera un token JWT de acceso.
  ///
  /// Construye una petición HTTP POST hacia el endpoint público de autenticación,
  /// transmitiendo el [email] y la [password] como cuerpo JSON de la solicitud.
  ///
  /// Si el servidor responde exitosamente, se extrae el campo `token` del cuerpo de la
  /// respuesta y se retorna como un [String]. En caso de credenciales inválidas o error
  /// de conectividad, la excepción es capturada internamente y se retorna `null` para
  /// que la capa superior (Provider/UI) maneje el estado de error de forma declarativa.
  ///
  /// [email]: Dirección de correo electrónico registrada del usuario.
  /// [password]: Contraseña en texto plano asociada a la cuenta del usuario.
  /// Returns: Un [String] con el token JWT si la autenticación es exitosa; `null` en caso de error.
  Future<String?> login(String email, String password) async {
    try {
      // 🌐 Petición HTTP POST al endpoint de login con las credenciales del usuario
      final response = await ApiClient.dio.post(
        '/Auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      // 📋 Impresión informativa del código de estado HTTP para depuración en desarrollo
      print('STATUS: ${response.statusCode}');
      print('RESPONSE: ${response.data}');

      // 🔑 Extracción del token JWT desde la respuesta estructurada del servidor
      return response.data['token'];

    } on DioException catch (e) {
      // ❌ Error controlado de la librería Dio: problemas de red, timeout o respuesta HTTP con error
      print('❌ Error Dio Login');
      print('STATUS ERROR: ${e.response?.statusCode}');
      print('DATA ERROR: ${e.response?.data}');
      return null;

    } catch (e) {
      // ❌ Error genérico no categorizado: se captura para evitar que la UI reciba una excepción no controlada
      print('❌ Error general Login: $e');
      return null;
    }
  }
}