// Este provider maneja el estado de login y persistencia usando SharedPreferences
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agenda_contactos/services/auth_api_service.dart';

/// Administrador de estado de autenticación y sesión.
///
/// Responsabilidades:
/// - Validar credenciales (demo local).
/// - Persistir estado mínimo de sesión con `SharedPreferences`.
/// - Exponer flags de carga/errores para la UI.
class LoginProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _isCheckingAuth = true; // Para que no se muestre nada hasta verificar
  String _errorMessage = '';
  bool _isLoggedIn = false;
  
   // 🔥 Servicio API
  final AuthApiService _authApiService = AuthApiService();
  // Getters
  bool get isLoading => _isLoading;
  bool get isCheckingAuth => _isCheckingAuth;
  String get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;

  LoginProvider() {
    _checkLoginStatus(); // Verifica el estado de login al inicializar
  }

  // Verifica si el usuario sigue logueado (SharedPreferences)
  /// Lee el estado de sesión persistido y actualiza flags de inicio.
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;//Si no hay sesion activa, _isLoggedIn es false
    _isCheckingAuth = false;//Ya termino de verificar
    notifyListeners();//Notifica cambios de estado
  }

  /// Intenta autenticar contra la API ASP.NET.
/// Si el login es correcto, almacena el JWT y persiste sesión.
Future<bool> login(String email, String password) async {
  _isLoading = true;
  _errorMessage = '';
  notifyListeners();

  // Validación de formato de email
  if (!_esEmailValido(email)) {
    return _setError('Por favor ingrese un email válido');
  }

  // Validación de contraseña
  if (password.length < 4) {
    return _setError('La contraseña debe tener al menos 4 caracteres');
  }

  try {
    // 🔥 Login REAL contra ASP.NET
    final token = await _authApiService.login(email, password);

    if (token != null) {
      final prefs = await SharedPreferences.getInstance();

      // Persistencia de sesión
      await prefs.setString('jwt_token', token);
      await prefs.setString('user_email', email);
      await prefs.setBool('is_logged_in', true);

      _isLoggedIn = true;
      _isLoading = false;

      notifyListeners();

      return true;
    } else {
      return _setError('Usuario o contraseña incorrectos');
    }
  } catch (e) {
    return _setError('Error de conexión: $e');
  }
}

  // Método para logout
  /// Limpia la sesión persistida y lleva la app a estado no autenticado.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.setBool('is_logged_in', false);

    _isLoggedIn = false;
    notifyListeners();
  }

  // Método para obtener email guardado
  /// Retorna el email guardado de la última sesión (si existe).
  Future<String?> getStoredEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  // Validar formato de email
  /// Valida de forma sencilla el formato de email.
  bool _esEmailValido(String email) {
    final pattern = r'^[^@]+@[^@]+\.[^@]+';
    return RegExp(pattern).hasMatch(email);
  }

  // Centraliza el manejo de errores
  /// Setea flags y mensaje de error, y retorna `false` para corta-flujo.
  bool _setError(String msg) {
    _errorMessage = msg;
    _isLoading = false;
    _isLoggedIn = false;
    notifyListeners();
    return false;
  }
}
