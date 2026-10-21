import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthResult {
  final bool success;
  final String? message;
  final String? email;

  const AuthResult({
    required this.success,
    this.message,
    this.email,
  });
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;

  AuthService._internal();

  static const String _prefKeyLoggedIn = 'auth_is_logged_in';
  static const String _prefKeyEmail = 'auth_user_email';
  static const String _prefKeyName = 'auth_user_name';

  bool _isAuthenticated = false;
  String? _currentUserEmail;
  String? _currentUserName;
  bool _isInitialized = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserName => _currentUserName ?? 'Operator Smart City';
  bool get isInitialized => _isInitialized;

  // Preset dummy credentials for testing before real database is connected
  static const Map<String, String> dummyAccounts = {
    'user@gmail.com': 'pass1234',
    'admin@tegal.go.id': 'admin123',
    'operator@tegal.go.id': 'tegal2026',
  };

  /// Initialize auth state from SharedPreferences (Auto-Login)
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = prefs.getBool(_prefKeyLoggedIn) ?? false;
      _currentUserEmail = prefs.getString(_prefKeyEmail);
      _currentUserName = prefs.getString(_prefKeyName);
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('[AuthService] Init error: $e');
      _isAuthenticated = false;
      _isInitialized = true;
    }
  }

  /// Login authentication method (Simulates network/DB delay and checks credentials)
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    // 1. Basic validation
    if (cleanEmail.isEmpty) {
      return const AuthResult(
        success: false,
        message: 'Silakan masukkan email kamu',
      );
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(cleanEmail)) {
      return const AuthResult(
        success: false,
        message: 'Format email tidak valid (contoh: user@gmail.com)',
      );
    }

    if (cleanPassword.isEmpty) {
      return const AuthResult(
        success: false,
        message: 'Silakan masukkan password',
      );
    }

    if (cleanPassword.length < 4) {
      return const AuthResult(
        success: false,
        message: 'Password minimal 4 karakter',
      );
    }

    // 2. Simulate realistic network / database latency (700ms)
    await Future.delayed(const Duration(milliseconds: 700));

    // 3. Match against dummy accounts or accept valid format credentials
    final expectedPassword = dummyAccounts[cleanEmail];
    final bool isMatched = (expectedPassword != null && expectedPassword == cleanPassword) ||
        (cleanPassword == 'pass1234' || cleanPassword == 'admin123');

    if (!isMatched) {
      return const AuthResult(
        success: false,
        message: 'Email atau password salah. Coba: user@gmail.com / pass1234',
      );
    }

    // 4. Save session to SharedPreferences for persistent login
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyLoggedIn, true);
      await prefs.setString(_prefKeyEmail, cleanEmail);
      final derivedName = cleanEmail.split('@').first;
      final capitalizedName = derivedName.isNotEmpty
          ? '${derivedName[0].toUpperCase()}${derivedName.substring(1)}'
          : 'User';
      await prefs.setString(_prefKeyName, capitalizedName);

      _isAuthenticated = true;
      _currentUserEmail = cleanEmail;
      _currentUserName = capitalizedName;
      notifyListeners();

      return AuthResult(
        success: true,
        email: cleanEmail,
      );
    } catch (e) {
      debugPrint('[AuthService] Save session error: $e');
      return const AuthResult(
        success: false,
        message: 'Gagal menyimpan sesi login ke perangkat',
      );
    }
  }

  /// Logout and clear stored session
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKeyLoggedIn);
      await prefs.remove(_prefKeyEmail);
      await prefs.remove(_prefKeyName);
    } catch (e) {
      debugPrint('[AuthService] Logout clear error: $e');
    }

    _isAuthenticated = false;
    _currentUserEmail = null;
    _currentUserName = null;
    notifyListeners();
  }
}
