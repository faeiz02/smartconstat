import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../core/storage/secure_storage_service.dart';

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
          final user = _userFromStateOrProvider(context, state);
          if (user == null) return const WelcomeScreen();
          return ProfileScreen(user: user);
        },
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) {
          final user = _userFromStateOrProvider(context, state);
          if (user == null) return const WelcomeScreen();
          return HomeScreen(user: user);
        },
      ),
      GoRoute(
        path: '/constat',
        name: 'constat',
        builder: (context, state) => const _RequireAuth(
          child: ConstatFormScreen(),
        ),
      ),
    ],
  );

  static UserModel? _userFromStateOrProvider(BuildContext context, GoRouterState state) {
    final extra = state.extra;
    if (extra is UserModel) return extra;

    final authUser = context.read<AuthProvider>().user;
    if (authUser != null) return authUser;

    return context.read<UserProvider>().user;
  }
}

class _RequireAuth extends StatelessWidget {
  final Widget child;

  const _RequireAuth({required this.child});

  @override
  Widget build(BuildContext context) {
    final hasUser = context.watch<AuthProvider>().user != null ||
        context.watch<UserProvider>().user != null;

    if (hasUser) return child;

    return FutureBuilder<String?>(
      future: SecureStorageService.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == null) {
          return const WelcomeScreen();
        }

        return child;
      },
    );
  }
}
