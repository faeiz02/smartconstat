import 'package:go_router/go_router.dart';
import '../presentation/auth/screens/welcome_screen.dart';
import '../presentation/auth/screens/insurance_verification_screen.dart';
import '../presentation/auth/screens/registration_screen.dart';
import '../presentation/auth/screens/waiting_verification_screen.dart';
import '../presentation/auth/screens/email_verification_screen.dart';
import '../presentation/auth/screens/forgot_password_screen.dart';
import '../presentation/auth/screens/id_verification_screen.dart';
import '../presentation/auth/screens/create_password_screen.dart';
import '../presentation/auth/screens/login_screen.dart';
import '../presentation/profile/profile_screen.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/constat/screens/constat_form_screen.dart';
import '../data/models/user_model.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // ─── Nouveau flux d'authentification ───
      GoRoute(
        path: '/',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/insurance-verification',
        name: 'insuranceVerification',
        builder: (context, state) => const InsuranceVerificationScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return RegistrationScreen(insuranceData: data);
        },
      ),
      GoRoute(
        path: '/waiting-verification',
        name: 'waitingVerification',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return WaitingVerificationScreen(registrationData: data);
        },
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verifyEmail',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return EmailVerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ─── Ancien flux (conservé pour compatibilité) ───
      GoRoute(
        path: '/id-verification',
        name: 'idVerification',
        builder: (context, state) => const IdVerificationScreen(),
      ),
      GoRoute(
        path: '/create-password',
        name: 'createPassword',
        builder: (context, state) {
          final id = state.extra as String? ?? '';
          return CreatePasswordScreen(id: id);
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          final id = state.extra as String? ?? '';
          return LoginScreen(id: id);
        },
      ),

      // ─── Écrans principaux ───
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) {
          final user = state.extra as UserModel;
          return ProfileScreen(user: user);
        },
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) {
          final user = state.extra as UserModel;
          return HomeScreen(user: user);
        },
      ),
      GoRoute(
        path: '/constat',
        name: 'constat',
        builder: (context, state) => const ConstatFormScreen(),
      ),
    ],
  );
}