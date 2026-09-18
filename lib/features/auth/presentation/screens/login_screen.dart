import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/auth/role_session.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/route_feedback.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim().toLowerCase();
      final role = ref
          .read(roleSessionProvider.notifier)
          .signInFromUsername(username);
      context.go(role.homeRoute);
    }
  }

  void _loginAsDeveloper() {
    _usernameController.text = 'pt_tasik_indah';
    _passwordController.text = 'demo123';
    ref
        .read(roleSessionProvider.notifier)
        .signIn(AppRole.developer, username: 'pt_tasik_indah');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Masuk sebagai Pengembang Demo (PT. Tasik Indah Sentosa)',
        ),
        duration: Duration(seconds: 2),
      ),
    );
    context.go('/dashboard');
  }

  void _loginAsAdmin() {
    _usernameController.text = 'admin_dpkp';
    _passwordController.text = 'admin123';
    ref
        .read(roleSessionProvider.notifier)
        .signIn(AppRole.admin, username: 'admin_dpkp');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Masuk sebagai Admin Internal Disperwaskim (Rizki Pratama, S.T.)',
        ),
        duration: Duration(seconds: 2),
      ),
    );
    context.go('/admin');
  }

  void _loginAsTimMonitoring() {
    _usernameController.text = 'tim_monitoring_perwaskim';
    _passwordController.text = 'monitoring123';
    ref
        .read(roleSessionProvider.notifier)
        .signIn(AppRole.perwaskim, username: 'tim_monitoring_perwaskim');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Masuk sebagai Tim Perwaskim Monitoring (Drs. Rian Hidayat, M.Si)',
        ),
        duration: Duration(seconds: 2),
      ),
    );
    context.go('/monitoring/lapangan');
  }

  void _showAdminContact() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hubungi Administrator'),
        content: const Text(
          'Untuk pembuatan akun baru atau kendala masuk, silakan hubungi Admin Disperumkim melalui WhatsApp di +62-812-3456-7890.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.home_work,
                  size: 64,
                  color: AppColors.chilliDust,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Masuk SATU RUMAH',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sistem Layanan Terpadu Perumahan Tasikmalaya',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  label: 'Nama Pengguna / Username',
                  hintText: 'Masukkan username',
                  controller: _usernameController,
                  validator: (val) => val == null || val.isEmpty
                      ? 'Username tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Kata Sandi / Password',
                  hintText: 'Masukkan password',
                  controller: _passwordController,
                  isPassword: true,
                  validator: (val) => val == null || val.isEmpty
                      ? 'Password tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: AppColors.chilliDust,
                          onChanged: (val) =>
                              setState(() => _rememberMe = val ?? false),
                        ),
                        const Text(
                          'Ingat Saya',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () =>
                          showUnavailableAction(context, 'Pemulihan password'),
                      child: Text(
                        'Lupa Password?',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.chilliDust,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AppButton.primary(text: 'Masuk', onPressed: _login),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        'atau',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                AppButton.secondary(
                  text: 'Masuk Quick Demo (Pengembang)',
                  icon: const Icon(Icons.business),
                  onPressed: _loginAsDeveloper,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.chilliDust,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _loginAsAdmin,
                    icon: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Masuk Quick Demo (Admin Disperwaskim)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.cocoaBeanRoast,
                        width: 1.5,
                      ),
                      backgroundColor: AppColors.champagneToast.withValues(
                        alpha: 0.3,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _loginAsTimMonitoring,
                    icon: const Icon(
                      Icons.assignment_ind_rounded,
                      color: AppColors.cocoaBeanRoast,
                    ),
                    label: const Text(
                      'Masuk Quick Demo (Tim Monitoring)',
                      style: TextStyle(
                        color: AppColors.cocoaBeanRoast,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Belum punya akun? ',
                      style: AppTextStyles.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: _showAdminContact,
                      child: Text(
                        'Hubungi Admin',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.chilliDust,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
