import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../state/auth_provider.dart';
import '../../widgets/app_toast.dart';
import 'auth_buttons.dart';
import 'auth_chrome.dart';
import 'auth_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscure = true;
  bool _remember = true;
  bool _prefilled = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final AuthProvider auth = context.read<AuthProvider>();
    final bool ok = await auth.login(
      emailOrUsername: _email.text,
      password: _password.text,
      rememberMe: _remember,
    );
    if (!mounted) return;
    if (ok) {
      AppToast.show(context, 'Selamat datang kembali!');
    } else {
      AppSnack.show(context, auth.error ?? 'Login gagal.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();
    if (!_prefilled) {
      _prefilled = true;
      final String? r = auth.rememberedEmail();
      if (r != null && r.isNotEmpty) _email.text = r;
    }
    return AuthScaffold(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 8),
          const AuthLogo(),
          const SizedBox(height: 14),
          Text('KeepGrinding', style: AppTypography.headlineLg),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryFixed,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('Focus & Achieve', style: AppTypography.labelSm),
          ),
          const SizedBox(height: 10),
          Text('Selamat Datang Kembali!', style: AppTypography.headlineSm),
          const SizedBox(height: 6),
          Text(
            'Masuk untuk melanjutkan progres harianmu.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd.copyWith(color: AppColors.outline),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryFixed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_fire_department_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Streak Siap Berlanjut',
                          style: AppTypography.labelMd),
                      Text('Selesaikan 3 tugas pagi ini!',
                          style: AppTypography.bodySm),
                    ],
                  ),
                ),
                Text('+50 XP', style: AppTypography.labelSm),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: <Widget>[
                AuthField(
                  label: 'Email atau Username',
                  controller: _email,
                  hint: 'nama@email.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                AuthField(
                  label: 'Kata Sandi',
                  controller: _password,
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscure,
                  onToggleObscure: () {
                    setState(() => _obscure = !_obscure);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        setState(() => _remember = !_remember);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            _remember
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank_rounded,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text('Ingat saya',
                              style: AppTypography.bodySm),
                        ],
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => AppToast.show(
                          context, 'Link reset dikirim (demo).'),
                      child: const Text('Lupa Kata Sandi?'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AuthPrimaryButton(
                  label: 'Masuk ke KeepGrinding',
                  loading: auth.busy,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
          const AuthDivider(text: 'atau masuk dengan'),
          AuthSocialRow(
            onSocial: (String p) =>
                AppToast.show(context, 'Login $p segera hadir.'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Belum punya akun?', style: AppTypography.bodyMd),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const RegisterScreen(),
                  ),
                ),
                child: const Text('Daftar Sekarang'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
