import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_provider.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _obscure = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();

    // Tenter la restauration automatique de session
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    final userProvider = context.read<UserProvider>();
    final success = await userProvider.tryAutoLogin();
    if (success && mounted && userProvider.user != null) {
      context.read<AuthProvider>().setAuthenticatedUser(userProvider.user!);
      context.go('/home', extra: userProvider.user!);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les champs"),
          backgroundColor: AppColors.redDanger,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await AuthService.loginWithEmail(
        emailController.text.trim(),
        passwordController.text,
      );

      if (mounted) {
        setState(() => isLoading = false);

        if (response.containsKey('user')) {
          final user = UserModel.fromJson(response['user']);
          context.read<AuthProvider>().setAuthenticatedUser(user);
          context.read<UserProvider>().setUser(user);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/home', extra: user);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['error'] ?? "Erreur de connexion"),
              backgroundColor: AppColors.redDanger,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur: $e"),
            backgroundColor: AppColors.redDanger,
          ),
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
              top: -80,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentCyan.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondaryBlue.withOpacity(0.06),
                ),
              ),
            ),
            // Floating particles
            Positioned(
              top: 120,
              left: 40,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentCyan.withOpacity(0.3),
                ),
              ),
            ),
            Positioned(
              top: 200,
              right: 50,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondaryBlue.withOpacity(0.4),
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
                          // Logo
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.accentGradient,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.accentCyan.withOpacity(0.35),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.shield_outlined,
                              size: 52,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Title
                          const Text(
                            "SmartConstat",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Votre constat intelligent",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.65),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Glass card - Login form
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.12),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Section title
                                    Row(
                                      children: [
                                        Icon(Icons.login_rounded,
                                            color: AppColors.accentCyan
                                                .withOpacity(0.9),
                                            size: 20),
                                        const SizedBox(width: 8),
                                        const Text(
                                          "Connexion",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                    // Email input
                                    _buildInputField(
                                      controller: emailController,
                                      hint: "Adresse email",
                                      icon: Icons.email_outlined,
                                      keyboardType:
                                          TextInputType.emailAddress,
                                    ),
                                    const SizedBox(height: 14),

                                    // Password input
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withOpacity(0.05),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: TextField(
                                        controller: passwordController,
                                        obscureText: _obscure,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.darkGrey,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "Mot de passe",
                                          hintStyle: TextStyle(
                                            color: AppColors.mediumGrey
                                                .withOpacity(0.6),
                                            fontWeight: FontWeight.w400,
                                          ),
                                          prefixIcon: const Icon(
                                              Icons.lock_outline_rounded,
                                              color:
                                                  AppColors.secondaryBlue),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscure
                                                  ? Icons
                                                      .visibility_off_rounded
                                                  : Icons
                                                      .visibility_rounded,
                                              color: AppColors.mediumGrey,
                                            ),
                                            onPressed: () => setState(
                                                () => _obscure = !_obscure),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // Forgot Password
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () => context.push('/forgot-password'),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(50, 30),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text(
                                          "Mot de passe oublié ?",
                                          style: TextStyle(
                                            color: AppColors.accentCyan,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 22),

                                    // Login button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed:
                                            isLoading ? null : _login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.accentCyan,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          elevation: 4,
                                          shadowColor: AppColors.accentCyan
                                              .withOpacity(0.4),
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                height: 22,
                                                width: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2.5,
                                                ),
                                              )
                                            : const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                children: [
                                                  Text(
                                                    "SE CONNECTER",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: 0.8,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Icon(
                                                      Icons
                                                          .arrow_forward_rounded,
                                                      size: 20),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.15),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                child: Text(
                                  "OU",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.15),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Create account button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () =>
                                  context.go('/insurance-verification'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                  color: AppColors.greenSuccess
                                      .withOpacity(0.7),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                backgroundColor:
                                    AppColors.greenSuccess.withOpacity(0.1),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_add_alt_1_rounded,
                                      size: 20,
                                      color: AppColors.greenSuccess),
                                  SizedBox(width: 10),
                                  Text(
                                    "PAS DE COMPTE ? CRÉER UN",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                      color: AppColors.greenSuccess,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
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
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.darkGrey,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.mediumGrey.withOpacity(0.6),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(icon, color: AppColors.secondaryBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
