import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/storage/secure_storage_service.dart';
import '../models/constat_model.dart';

class AccidentService {

  static Future<Map<String, String>> _authHeaders() async {
    final token = await SecureStorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> saveConstat(
      String assuranceId, ConstatModel constat) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse(ApiConstants.constats),
        headers: headers,
        body: jsonEncode(constat.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          "success": true,
          "data": data['data'] ?? {"id": "unknown"},
        };
      } else {
        return {
          "success": false,
          "message": "Erreur serveur: ${response.statusCode}",
        };
      }
    } catch (e) {
      print("❌ Erreur saveConstat: $e");
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  static Future<List<ConstatModel>> getUserConstats(String assuranceId) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse(ApiConstants.constats),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list
            .map((json) => ConstatModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        print("❌ Erreur getUserConstats: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Erreur getUserConstats: $e");
      return [];
    }
  }
}