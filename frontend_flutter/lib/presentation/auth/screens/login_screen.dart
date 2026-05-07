import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../../core/constants/dev_autofill.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../core/storage/secure_storage_service.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  final String id;
  const LoginScreen({super.key, required this.id});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _obscure = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    if (DevAutofill.enabled) {
      passwordController.text = DevAutofill.testPassword;
    }
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void login() async {
    if (passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer votre mot de passe")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await AuthService.login(widget.id, passwordController.text);

      if (mounted) {
        setState(() => isLoading = false);

        if (response.containsKey('user')) {
          final user = UserModel.fromJson(response['user']);
          await SecureStorageService.saveToken(response['token']);
          context.read<AuthProvider>().setAuthenticatedUser(user);
          context.read<UserProvider>().setUser(user);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/home', extra: user);
          });
        } else if (response['error'] == 'not_verified') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Votre compte n'est pas vérifié. Un code vous a été envoyé."),
              backgroundColor: AppColors.orangeWarning,
            ),
          );
          // Renvoyer automatiquement un nouveau code
          AuthService.resendVerificationCode(widget.id);
          context.go('/verify-email', extra: widget.id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['error'] ?? "Erreur de connexion")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050D1F), Color(0xFF0F2B5B), Color(0xFF1E4FA0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -50,
              left: -70,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentCyan.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondaryBlue.withOpacity(0.07),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Lock icon
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.accentGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentCyan.withOpacity(0.3),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.lock_outline_rounded,
                              size: 44,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            "Connexion",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Entrez votre mot de passe",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 36),
                          // ID Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withOpacity(0.12)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.badge_outlined, color: AppColors.accentCyan.withOpacity(0.9), size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  "ID: ${widget.id}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Glass card
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                                ),
                                child: Column(
                                  children: [
                                    // Password input
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: TextField(
                                        controller: passwordController,
                                        obscureText: _obscure,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.darkGrey,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "Mot de passe",
                                          prefixIcon: const Icon(Icons.key_rounded, color: AppColors.secondaryBlue),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                              color: AppColors.mediumGrey,
                                            ),
                                            onPressed: () => setState(() => _obscure = !_obscure),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    // Login button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: isLoading ? null : login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.accentCyan,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          elevation: 4,
                                          shadowColor: AppColors.accentCyan.withOpacity(0.4),
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                height: 22,
                                                width: 22,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2.5,
                                                ),
                                              )
                                            : const Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "SE CONNECTER",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w700,
                                                      letterSpacing: 0.8,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Icon(Icons.login_rounded, size: 20),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (DevAutofill.enabled) ...[
                            const SizedBox(height: 20),
                            Text(
                              'Debug : mot de passe prérempli (${DevAutofill.testPassword})',
                              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}