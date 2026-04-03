import 'package:flutter/foundation.dart';

/// Préremplissage automatique des formulaires d’auth en **debug uniquement**.
class DevAutofill {
  static const String testAssuranceId = 'A123';
  /// ≥ 6 caractères (contrainte Firebase Auth).
  static const String testPassword = 'Test1234';

  static bool get enabled => kDebugMode;
}
