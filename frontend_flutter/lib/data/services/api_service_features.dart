import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/storage/secure_storage_service.dart';

class ApiServiceFeatures {

  static Future<Map<String, String>> _headers() async {
    final token = await SecureStorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── Factures ───
  static Future<List<dynamic>> getFactures({String? type}) async {
    try {
      String url = ApiConstants.servicesFactures;
      if (type != null && type.isNotEmpty) {
        url += '?type=$type';
      }
      final response = await http.get(
        Uri.parse(url),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("Erreur getFactures: $e");
      return [];
    }
  }

  // ─── Delete Facture ───
  static Future<bool> deleteFacture(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.servicesFactures}/$id'),
        headers: await _headers(),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Erreur deleteFacture: $e");
      return false;
    }
  }

  // ─── Create Facture ───
  static Future<int> createFacture({
    required String mois,
    required double montant,
    required String echeance,
    required String typeFacture,
    int? constatId,
  }) async {
    try {
      final body = {
        "mois": mois,
        "montant": montant,
        "echeance": echeance,
        "typeFacture": typeFacture,
        if (constatId != null) "constatId": constatId,
      };
      final response = await http.post(
        Uri.parse(ApiConstants.servicesFactures),
        headers: await _headers(),
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id'] as int;
      }
      return -1;
    } catch (e) {
      print("Erreur createFacture: $e");
      return -1;
    }
  }

  static Future<List<dynamic>> getMyConstats() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.constats),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("Erreur getMyConstats: $e");
      return [];
    }
  }

  static Future<List<dynamic>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.notifications),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("Erreur getNotifications: $e");
      return [];
    }
  }

  static Future<bool> markNotificationRead(int id) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.notifications}/$id/read'),
        headers: await _headers(),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Erreur markNotificationRead: $e");
      return false;
    }
  }

  // ─── Upload Facture Photo ───
  static Future<bool> uploadFacturePhoto(int factureId, String filePath) async {
    try {
      final token = await SecureStorageService.getToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.servicesFactures}/$factureId/upload'),
      );
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.files.add(await http.MultipartFile.fromPath('photo', filePath));
      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print("Erreur uploadFacturePhoto: $e");
      return false;
    }
  }

  // ─── Dashboard: All Constats ───
  static Future<List<dynamic>> getAllConstats({String? statut}) async {
    try {
      String url = ApiConstants.constatsAll;
      if (statut != null && statut.isNotEmpty) {
        url += '?statut=$statut';
      }
      final response = await http.get(
        Uri.parse(url),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("Erreur getAllConstats: $e");
      return [];
    }
  }

  // ─── Dashboard: Update Constat Statut ───
  static Future<bool> updateConstatStatut(int constatId, String statut) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.constats}/$constatId/statut'),
        headers: await _headers(),
        body: jsonEncode({"statut": statut}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Erreur updateConstatStatut: $e");
      return false;
    }
  }

  // ─── Assistance Numbers ───
  static Future<List<dynamic>> getAssistanceNumbers() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.servicesAssistanceNumbers),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("Erreur getAssistanceNumbers: $e");
      return [];
    }
  }

  // ─── Assistance Types ───
  static Future<List<dynamic>> getAssistanceTypes() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.servicesAssistanceTypes),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("Erreur getAssistanceTypes: $e");
      return [];
    }
  }

  // ─── Réseau de Soins ───
  static Future<List<dynamic>> getReseauSoins() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.servicesReseauSoins),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("Erreur getReseauSoins: $e");
      return [];
    }
  }

  // ─── Avis ───
  static Future<List<dynamic>> getAvis(int professionalId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.avisBase}/professional/$professionalId'),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("Erreur getAvis: $e");
      return [];
    }
  }

  /// Returns status code: 200 = success, 409 = already reviewed, other = error
  static Future<int> addAvis(int professionalId, double rating, String comment) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.avisBase}/add'),
        headers: await _headers(),
        body: jsonEncode({
          "professionalId": professionalId,
          "rating": rating,
          "comment": comment
        }),
      );
      return response.statusCode;
    } catch (e) {
      print("Erreur addAvis: $e");
      return 0;
    }
  }

  static Future<bool> updateAvis(int avisId, double rating, String comment) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.avisBase}/$avisId'),
        headers: await _headers(),
        body: jsonEncode({
          "rating": rating,
          "comment": comment,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Erreur updateAvis: $e");
      return false;
    }
  }

  static Future<bool> deleteAvis(int avisId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.avisBase}/$avisId'),
        headers: await _headers(),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Erreur deleteAvis: $e");
      return false;
    }
  }

  // ─── Demandes de nouvelle assurance ───
  static Future<Map<String, dynamic>> submitInsuranceRequest({
    required String type,
    required String title,
    required String price,
    required Map<String, String> details,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.insuranceRequests),
        headers: await _headers(),
        body: jsonEncode({
          "type": type,
          "title": title,
          "price": price,
          "details": details,
        }),
      );

      final data = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode == 200) {
        return {
          "success": data["success"] ?? true,
          "message": data["message"] ?? "Demande envoyée",
          "request": data["request"],
        };
      }

      return {
        "success": false,
        "message": data["error"] ?? data["message"] ?? "Erreur serveur: ${response.statusCode}",
      };
    } catch (e) {
      print("Erreur submitInsuranceRequest: $e");
      return {
        "success": false,
        "message": "Erreur de connexion au serveur: $e",
      };
    }
  }

  static Future<List<dynamic>> getMyInsuranceRequests() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.insuranceRequests),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("Erreur getMyInsuranceRequests: $e");
      return [];
    }
  }
}
