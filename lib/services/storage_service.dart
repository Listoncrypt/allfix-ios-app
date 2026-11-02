import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyAdminToken = 'admin_session_token';
  static const String _keyRememberedPhone = 'remembered_phone';

  StorageService._internal();

  Future<void> saveAdminToken(String token) async {
    await _storage.write(key: _keyAdminToken, value: token);
  }

  Future<String?> getAdminToken() async {
    return await _storage.read(key: _keyAdminToken);
  }

  Future<void> clearAdminToken() async {
    await _storage.delete(key: _keyAdminToken);
  }

  Future<void> saveRememberedPhone(String phone) async {
    await _storage.write(key: _keyRememberedPhone, value: phone);
  }

  Future<String?> getRememberedPhone() async {
    return await _storage.read(key: _keyRememberedPhone);
  }
}
