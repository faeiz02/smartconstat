/// Configuration de l'URL du backend Spring Boot.
class ApiConstants {
  // Appareil physique (votre IP locale + Port 8082)
  static const String baseUrl = 'http://192.168.1.189:8082/api';

  // Endpoints Auth
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String verifyInsurance = '$baseUrl/auth/verify-insurance';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String resetPassword = '$baseUrl/auth/reset-password';
  static const String verifyCode = '$baseUrl/auth/verify-code';
  static const String verifyEmail = '$baseUrl/auth/verify-email';
  static const String resendCode = '$baseUrl/auth/resend-code';
  static const String userProfile = '$baseUrl/users/me';

  // Endpoints Constats
  static const String constats = '$baseUrl/constats';
  static const String constatsAll = '$baseUrl/constats/all';

  // Endpoints Services
  static const String servicesFactures = '$baseUrl/services/factures';
  static const String servicesAssistanceNumbers = '$baseUrl/services/assistance-numbers';
  static const String servicesAssistanceTypes = '$baseUrl/services/assistance-types';
  static const String servicesReseauSoins = '$baseUrl/services/healthcare';

  // Endpoints Avis
  static const String avisBase = '$baseUrl/avis';
}
