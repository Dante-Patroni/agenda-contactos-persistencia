// Este provider maneja el estado de login y persistencia usando SharedPreferences
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _isCheckingAuth = true; // Para que no se muestre nada hasta verificar
  String _errorMessage = '';
  bool _isLoggedIn = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isCheckingAuth => _isCheckingAuth;
  String get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;

  LoginProvider() {
    _checkLoginStatus(); // Verifica el estado de login al inicializar
  }

  // Verifica si el usuario sigue logueado (SharedPreferences)
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    _isCheckingAuth = false;
    notifyListeners();
  }

  // Método para login
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
      await Future.delayed(const Duration(seconds: 1));

      if (email == "admin@gmail.com" && password == "1234") {
        final prefs = await SharedPreferences.getInstance();
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
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.setBool('is_logged_in', false);

    _isLoggedIn = false;
    notifyListeners();
  }

  // Método para obtener email guardado
  Future<String?> getStoredEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  // Validar formato de email
  bool _esEmailValido(String email) {
    final pattern = r'^[^@]+@[^@]+\.[^@]+';
    return RegExp(pattern).hasMatch(email);
  }

  // Centraliza el manejo de errores
  bool _setError(String msg) {
    _errorMessage = msg;
    _isLoading = false;
    _isLoggedIn = false;
    notifyListeners();
    return false;
  }
}
