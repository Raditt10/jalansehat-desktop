import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

/// Halaman login aplikasi Jalan Sehat - Premium Design
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
          rememberMe: _rememberMe,
        );

    if (success && mounted) {
      // Navigasi akan ditangani oleh GoRouter redirect
    }
  }

  Future<void> _handleGoogleLogin() async {
    final success = await ref.read(authProvider.notifier).signInWithGoogle();
    if (success && mounted) {
      // Navigasi akan ditangani oleh GoRouter redirect
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Row(
        children: [
          // ═══════════════════════════════════════════
          // Panel Kiri - Foto Klinik + Glassmorphism
          // ═══════════════════════════════════════════
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image
                Image.asset(
                  'assets/images/klinik.png',
                  fit: BoxFit.cover,
                ),

                // Dark Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF0D47A1).withValues(alpha: 0.75),
                        const Color(0xFF071E3D).withValues(alpha: 0.90),
                      ],
                    ),
                  ),
                ),

                // Decorative animated circles
                Positioned(
                  top: -60,
                  right: -60,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 2,
                      ),
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1.1, 1.1),
                      duration: 4000.ms,
                      curve: Curves.easeInOut,
                    )
                    .then()
                    .scale(
                      begin: const Offset(1.1, 1.1),
                      end: const Offset(0.9, 0.9),
                      duration: 4000.ms,
                      curve: Curves.easeInOut,
                    ),

                Positioned(
                  bottom: -40,
                  left: -40,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                        width: 1.5,
                      ),
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.15, 1.15),
                      duration: 5000.ms,
                      curve: Curves.easeInOut,
                    )
                    .then()
                    .scale(
                      begin: const Offset(1.15, 1.15),
                      end: const Offset(1.0, 1.0),
                      duration: 5000.ms,
                      curve: Curves.easeInOut,
                    ),

                // Floating particles
                ...List.generate(6, (i) {
                  final positions = [
                    const Offset(0.15, 0.2),
                    const Offset(0.8, 0.15),
                    const Offset(0.7, 0.7),
                    const Offset(0.25, 0.8),
                    const Offset(0.5, 0.4),
                    const Offset(0.9, 0.5),
                  ];
                  final sizes = [6.0, 4.0, 5.0, 3.0, 7.0, 4.0];
                  return Positioned(
                    left: MediaQuery.of(context).size.width *
                        0.55 *
                        positions[i].dx,
                    top: MediaQuery.of(context).size.height * positions[i].dy,
                    child: Container(
                      width: sizes[i],
                      height: sizes[i],
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15 + i * 0.03),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .moveY(
                        begin: 0,
                        end: -20 - i * 5,
                        duration: Duration(milliseconds: 3000 + i * 500),
                        curve: Curves.easeInOut,
                      )
                      .then()
                      .moveY(
                        begin: -20 - i * 5,
                        end: 0,
                        duration: Duration(milliseconds: 3000 + i * 500),
                        curve: Curves.easeInOut,
                      )
                      .fadeIn(duration: 1000.ms);
                }),

                // Content
                Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with glow effect
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.25),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .slideY(begin: -0.4, end: 0)
                          .then()
                          .shimmer(
                            delay: 1500.ms,
                            duration: 1800.ms,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),

                      const SizedBox(height: 32),

                      // Title
                      Text(
                        'Jalan Sehat',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1.5,
                          height: 1.1,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 700.ms)
                          .slideX(begin: -0.15, end: 0),

                      const SizedBox(height: 8),

                      // Subtitle with gradient text effect
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFF90CAF9),
                            Color(0xFF42A5F5),
                            Color(0xFF26C6DA),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          AppConstants.clinicName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 700.ms)
                          .slideX(begin: -0.1, end: 0),

                      const SizedBox(height: 12),

                      // Tagline
                      Text(
                        'Sistem Manajemen Klinik Modern & Terintegrasi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.65),
                          height: 1.5,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 600.ms),

                      const SizedBox(height: 48),

                      // Glassmorphism Info Cards
                      _GlassInfoCard(
                        icon: Icons.location_on_rounded,
                        text: AppConstants.clinicAddress,
                        delay: 600,
                      ),
                      const SizedBox(height: 12),
                      _GlassInfoCard(
                        icon: Icons.phone_rounded,
                        text: AppConstants.clinicPhone,
                        delay: 700,
                      ),
                      const SizedBox(height: 12),
                      _GlassInfoCard(
                        icon: Icons.access_time_rounded,
                        text: AppConstants.clinicHours,
                        delay: 800,
                      ),

                      const SizedBox(height: 48),

                      // Feature pills
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _FeaturePill(text: 'Klinik Umum', delay: 900),
                          _FeaturePill(text: 'Klinik Gigi', delay: 950),
                          _FeaturePill(text: 'Apotek', delay: 1000),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ═══════════════════════════════════════════
          // Panel Kanan - Form Login
          // ═══════════════════════════════════════════
          Expanded(
            flex: 4,
            child: Container(
              color: AppColors.background,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 56),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Welcome header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.waving_hand_rounded,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Selamat Datang!',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Masuk ke sistem manajemen klinik',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          color: AppColors.grey500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 300.ms, duration: 600.ms)
                              .slideY(begin: -0.1, end: 0),

                          const SizedBox(height: 32),

                          // Error message
                          if (authState.error != null)
                            Container(
                              padding: const EdgeInsets.all(14),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: AppColors.errorLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.error.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: AppColors.error, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      authState.error!,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn().shake(hz: 2, offset: const Offset(4, 0)),

                          // Email field
                          Text(
                            'Email',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Masukkan email anda',
                              prefixIcon:
                                  const Icon(Icons.email_outlined, size: 20),
                              filled: true,
                              fillColor: AppColors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.grey200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.grey200),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email tidak boleh kosong';
                              }
                              if (!value.contains('@')) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          )
                              .animate()
                              .fadeIn(delay: 500.ms, duration: 500.ms)
                              .slideY(begin: 0.1, end: 0),
                          const SizedBox(height: 20),

                          // Password field
                          Text(
                            'Password',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Masukkan password',
                              prefixIcon:
                                  const Icon(Icons.lock_outline, size: 20),
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                ),
                              ),
                              filled: true,
                              fillColor: AppColors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.grey200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.grey200),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }
                              if (value.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _handleLogin(),
                          )
                              .animate()
                              .fadeIn(delay: 600.ms, duration: 500.ms)
                              .slideY(begin: 0.1, end: 0),
                          const SizedBox(height: 16),

                          // Remember me
                          Row(
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) =>
                                      setState(() => _rememberMe = v ?? false),
                                  activeColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ingat saya',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: AppColors.grey600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Login button with gradient
                          Container(
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryMedium,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed:
                                  authState.isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: authState.isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Masuk',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 700.ms, duration: 500.ms)
                              .slideY(begin: 0.15, end: 0),

                          const SizedBox(height: 24),

                          // Google Sign In Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton(
                              onPressed: authState.isLoading ? null : _handleGoogleLogin,
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                side: BorderSide(color: AppColors.grey200),
                                backgroundColor: AppColors.white,
                                foregroundColor: AppColors.black,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/google-logo.png',
                                    height: 24,
                                    width: 24,
                                  ),
                                const SizedBox(width: 12),
                                Text(
                                  'Lanjutkan dengan Google',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ) // end OutlinedButton
                          ) // end SizedBox
                              .animate()
                              .fadeIn(delay: 800.ms, duration: 500.ms)
                              .slideY(begin: 0.15, end: 0),

                          const SizedBox(height: 32),

                          // Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: AppColors.grey300)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'Sistem Klinik v1.0',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AppColors.grey400,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: AppColors.grey300)),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Footer
                          Text(
                            '© 2026 ${AppConstants.clinicName}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.grey400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Glassmorphism info card untuk panel kiri
class _GlassInfoCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final int delay;

  const _GlassInfoCard({
    required this.icon,
    required this.text,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF90CAF9), size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 500.ms)
        .slideX(begin: -0.1, end: 0);
  }
}

/// Feature pill untuk panel kiri
class _FeaturePill extends StatelessWidget {
  final String text;
  final int delay;

  const _FeaturePill({required this.text, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.85),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 500.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }
}
