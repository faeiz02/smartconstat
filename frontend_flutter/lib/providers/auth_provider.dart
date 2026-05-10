import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';
import '../core/storage/secure_storage_service.dart';

class AuthProvider extends ChangeNotifier {

  UserModel? _user;
  bool _isAuthenticated = false;

  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;

  void setAuthenticatedUser(UserModel user) {
    _user = user;
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> login(String id, String password) async {
    final response = await AuthService.login(id, password);

    if (response["token"] != null) {
      await SecureStorageService.saveToken(response["token"]);
      _user = UserModel.fromJson(response["user"]);
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await SecureStorageService.deleteToken();
    await SecureStorageService.deleteUserId();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
