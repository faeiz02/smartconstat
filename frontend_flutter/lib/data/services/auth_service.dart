import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/storage/secure_storage_service.dart';

class AuthService {

  // ─── Vérification dans la base d'assurance ───
  static Future<Map<String, dynamic>> verifyInsurance(
      String assuranceId, String cin) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.verifyInsurance),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'assuranceId': assuranceId,
          'cin': cin,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          "verified": data['verified'] ?? true,
          "message": data['message'] ?? "Coordonnées validées",
          "data": data['data'],
        };
      } else {
        return {
          "verified": false,
          "message": data['message'] ?? "Erreur de vérification",
        };
      }
    } catch (e) {
      return {
        "verified": false,
        "message": "Erreur de connexion au serveur: $e",
      };
    }
  }

  // ─── Inscription ───
  static Future<Map<String, dynamic>> registerWithEmail({
    required String email,
    required String password,
    required String assuranceId,
    required String cin,
    required String nom,
    required String prenom,
    String phone = '',
    String vehicleBrand = '',
    String vehicleModel = '',
    String vehiclePlate = '',
  }) async {
    if (password.length < 6) {
      return {
        "success": false,
        "message": "Le mot de passe doit contenir au moins 6 caractères.",
      };
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'assuranceId': assuranceId,
          'cin': cin,
          'nom': nom,
          'prenom': prenom,
          'phone': phone,
          'vehicleBrand': vehicleBrand,
          'vehicleModel': vehicleModel,
          'vehiclePlate': vehiclePlate,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        // Stocker le JWT
        if (data['token'] != null) {
          await SecureStorageService.saveToken(data['token']);
        }
        // Stocker le userId
        if (data['user'] != null && data['user']['id'] != null) {
          await SecureStorageService.saveUserId(data['user']['id'] as int);
        }
        return {
          "success": true,
          "message": data['message'] ?? "Compte créé avec succès",
          "token": data['token'],
          "user": data['user'],
        };
      } else {
        return {
          "success": false,
          "message": data['message'] ?? "Erreur d'inscription",
        };
      }
    } catch (e) {
      print("❌ Erreur registerWithEmail: $e");
      return {
        "success": false,
        "message": "Erreur de connexion au serveur: ${e.toString()}",
      };
    }
  }

  // ─── Vérification d'email par PIN ───
  static Future<Map<String, dynamic>> verifyEmailCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.verifyEmail),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        if (data['token'] != null) {
          await SecureStorageService.saveToken(data['token']);
        }
        return {"success": true, "message": data['message'], "user": data['user']};
      } else {
        return {"success": false, "message": data['message'] ?? "Code incorrect"};
      }
    } catch (e) {
      return {"success": false, "message": "Erreur réseau: $e"};
    }
  }

  // ─── Renvoyer le code PIN ───
  static Future<Map<String, dynamic>> resendVerificationCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.resendCode),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {"success": data['success'] ?? false, "message": data['message'] ?? "Erreur"};
    } catch (e) {
      return {"success": false, "message": "Erreur réseau: $e"};
    }
  }

  // ─── Réinitialisation du mot de passe ───
  static Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.forgotPassword),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return {
        "success": data['success'] ?? false,
        "message": data['message'] ?? "Erreur",
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Erreur de connexion au serveur: ${e.toString()}",
      };
    }
  }

  // ─── Connexion avec email ───
  static Future<Map<String, dynamic>> loginWithEmail(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        // Sauvegarder le token pour les requêtes futures
        if (data['token'] != null) {
          await SecureStorageService.saveToken(data['token']);
        }
        // Stocker le userId
        if (data['user'] != null && data['user']['id'] != null) {
          await SecureStorageService.saveUserId(data['user']['id'] as int);
        }
        return {
          "success": true,
          "token": data['token'],
          "user": data['user'],
        };
      } else {
        return {
          "error": data['message'] ?? "Email ou mot de passe incorrect",
        };
      }
    } catch (e) {
      return {"error": "Erreur de connexion au serveur: ${e.toString()}"};
    }
  }

  // ─── Connexion legacy (par ID d'assurance) ───
  static Future<Map<String, dynamic>> login(String id, String password) async {
    // Legacy: convert assurance ID to email format or use loginWithEmail
    // For backward compatibility, try with email format
    return loginWithEmail(id, password);
  }

  // ─── Profil utilisateur ───
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return {"error": "Non authentifié"};

      final response = await http.get(
        Uri.parse(ApiConstants.userProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {"success": true, "user": data};
      } else {
        return {"error": "Impossible de charger le profil"};
      }
    } catch (e) {
      return {"error": "Erreur: ${e.toString()}"};
    }
  }

  // ─── Mise à jour du profil ───
  static Future<Map<String, dynamic>> updateProfile(
      Map<String, String> updates) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return {"error": "Non authentifié"};

      final response = await http.put(
        Uri.parse(ApiConstants.userProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updates),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      return {"error": "Erreur: ${e.toString()}"};
    }
  }

  // ─── Annulation d'inscription (no-op, pas de Firebase à supprimer) ───
  static Future<void> cancelPendingRegistration() async {
    // Nettoyage local uniquement
    await SecureStorageService.deleteToken();
  }
}