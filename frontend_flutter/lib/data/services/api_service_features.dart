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
  static Future<List<dynamic>> getFactures() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.servicesFactures),
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

  // ─── Demande de Devis ───
  static Future<bool> requestDevis(String assuranceType) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.servicesDevis),
        headers: await _headers(),
        body: jsonEncode({"assuranceType": assuranceType}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Erreur requestDevis: $e");
      return false;
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
}
