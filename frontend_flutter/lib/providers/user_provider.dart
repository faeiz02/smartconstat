import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';
import '../core/storage/secure_storage_service.dart';

/// Provider qui gère l'état de l'utilisateur connecté.
/// Complète AuthProvider en ajoutant :
/// - Restauration automatique de session (tryAutoLogin)
/// - Chargement/rafraîchissement du profil via l'API
/// - Mise à jour du profil avec synchronisation locale
class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  // ─── Getters ───
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get hasUser => _user != null;
  String? get error => _error;

  String get displayName {
    if (_user == null) return '';
    return '${_user!.prenom} ${_user!.nom}'.trim();
  }

  String get initials {
    final n = _user?.nom.isNotEmpty == true ? _user!.nom[0].toUpperCase() : '';
    final p =
        _user?.prenom.isNotEmpty == true ? _user!.prenom[0].toUpperCase() : '';
    return '$n$p';
  }

  void _notifyListenersSafely() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return;
    }

    notifyListeners();
  }

  // ─── Définir l'utilisateur après login/register ───
  void setUser(UserModel user) {
    _user = user;
    _error = null;
    _notifyListenersSafely();
  }

  // ─── Restauration automatique de session ───
  /// Vérifie si un token JWT est stocké et charge le profil.
  /// Retourne true si la session a été restaurée avec succès.
  Future<bool> tryAutoLogin() async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) {
        return false;
      }

      final response = await AuthService.getUserProfile();

      if (response['success'] == true && response['user'] != null) {
        _user = UserModel.fromJson(response['user']);
        // Only notify if we found a user to prevent unnecessary rebuilds
        _notifyListenersSafely();
        return true;
      } else {
        // Token expiré ou invalide
        await SecureStorageService.deleteToken();
        await SecureStorageService.deleteUserId();
        return false;
      }
    } catch (e) {
      _error = 'Erreur de restauration de session: $e';
      return false;
    }
  }

  // ─── Charger/Rafraîchir le profil ───
  Future<void> refreshProfile() async {
    _isLoading = true;
    _error = null;
    _notifyListenersSafely();

    try {
      final response = await AuthService.getUserProfile();

      if (response['success'] == true && response['user'] != null) {
        _user = UserModel.fromJson(response['user']);
      } else {
        _error = response['error'] ?? 'Impossible de charger le profil';
      }
    } catch (e) {
      _error = 'Erreur: $e';
    }

    _isLoading = false;
    _notifyListenersSafely();
  }

  // ─── Mettre à jour le profil ───
  Future<bool> updateProfile({String? phone, String? email}) async {
    _isLoading = true;
    _error = null;
    _notifyListenersSafely();

    try {
      final updates = <String, String>{};
      if (phone != null) updates['phone'] = phone;
      if (email != null) updates['email'] = email;

      final response = await AuthService.updateProfile(updates);

      if (response.containsKey('error')) {
        _error = response['error'];
        _isLoading = false;
        _notifyListenersSafely();
        return false;
      }

      // Rafraîchir le profil après mise à jour
      await refreshProfile();
      return true;
    } catch (e) {
      _error = 'Erreur: $e';
      _isLoading = false;
      _notifyListenersSafely();
      return false;
    }
  }

  // ─── Déconnexion ───
  Future<void> clearUser() async {
    _user = null;
    _error = null;
    await SecureStorageService.deleteToken();
    await SecureStorageService.deleteUserId();
    _notifyListenersSafely();
  }
}
