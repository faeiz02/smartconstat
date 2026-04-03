/// Configuration de l'URL du backend Spring Boot.
///
/// Pour l'émulateur Android : 10.0.2.2 (redirige vers localhost de la machine hôte)
/// Pour un appareil physique : utilisez l'IP locale de votre PC (ex: 192.168.1.x)
/// Pour iOS Simulator : localhost

class ApiConstants {
  // ─── Choisir l'URL selon votre configuration ───

  // Émulateur Android
  // static const String baseUrl = 'http://10.0.2.2:8080/api';

  // Appareil physique (votre IP locale + Port 8081)
  static const String baseUrl = 'http://192.168.1.189:8081/api';

  // iOS Simulator
  // static const String baseUrl = 'http://localhost:8080/api';

  // ─── Endpoints ───
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String verifyInsurance = '$baseUrl/auth/verify-insurance';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String resetPassword = '$baseUrl/auth/reset-password';
  static const String verifyEmail = '$baseUrl/auth/verify-email';
  static const String resendCode = '$baseUrl/auth/resend-code';
  static const String userProfile = '$baseUrl/users/me';
  static const String constats = '$baseUrl/constats';
}
