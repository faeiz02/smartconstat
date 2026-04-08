import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: "jwt", value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: "jwt");
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: "jwt");
  }

  static Future<void> saveUserId(int userId) async {
    await _storage.write(key: "userId", value: userId.toString());
  }

  static Future<int?> getUserId() async {
    final val = await _storage.read(key: "userId");
    return val != null ? int.tryParse(val) : null;
  }

  static Future<void> deleteUserId() async {
    await _storage.delete(key: "userId");
  }
}