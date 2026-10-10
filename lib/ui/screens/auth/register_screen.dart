import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../state/auth_provider.dart';
import '../../widgets/app_toast.dart';
import 'auth_buttons.dart';
import 'auth_chrome.dart';
import 'auth_field.dart';

/// Register screen from `design/daftar_akun_register_keepgrinding/code.html`.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password =
      TextEditingController(text: 'SuperFocus#2025');
  bool _obscure = true;
  bool _agree = true;
  String _focus = 'Proyek Tim';

  static const List<Map<String, dynamic>> _focuses = <Map<String, dynamic>>[
    {'label': 'Kerja', 'icon': Icons.business_center_outlined},
    {'label': 'Studi', 'icon': Icons.school_outlined},
    {'label': 'Proyek Tim', 'icon': Icons.groups_outlined},
    {'label': 'Pribadi', 'icon': Icons.self_improvement_outlined},
  ];

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  int get _strength {
    final String v = _password.text;
    int score = 0;
    if (v.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(v)) score++;
    if (RegExp(r'[0-9]').hasMatch(v)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(v)) score++;
    return score.clamp(0, 4);
  }

  String get _strengthLabel {
    switch (_strength) {
      case 0:
      case 1:
        return 'Lemah';
      case 2:
        return 'Cukup';
      case 3:
        return 'Kuat 🔥';
      default:
        return 'Sangat Kuat 🔥';
    }
  }

  Future<void> _submit() async {
    if (!_agree) {
      AppSnack.show(context, 'Centang persetujuan dulu ya.',
          error: true);
      return;
    }
    final AuthProvider auth = context.read<AuthProvider>();
    final bool ok = await auth.register(
      name: _name.text,
      email: _email.text,
      password: _password.text,
      focus: _focus,
    );
    if (!mounted) return;
    if (ok) {
      AppToast.show(context, 'Akun dibuat! Selamat datang di KeepGrinding.');
      Navigator.of(context).pop();
    } else {
      AppSnack.show(context, auth.error ?? 'Pendaftaran gagal.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();
    return AuthScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Create Account'),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person_rounded,
                  size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _hero(),
          const SizedBox(height: 16),
          AuthField(
            label: 'Nama Lengkap',
            controller: _name,
            hint: 'Contoh: Rifat Pratama',
            icon: Icons.person_outline_rounded,
            requiredMark: true,
          ),
          const SizedBox(height: 14),
          AuthField(
            label: 'Alamat Email',
            controller: _email,
            hint: 'rifat@domain.com',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            requiredMark: true,
          ),
          const SizedBox(height: 14),
          AuthField(
            label: 'Kata Sandi Baru',
            controller: _password,
            hint: 'Minimal 8 karakter',
            icon: Icons.lock_reset_rounded,
            obscure: _obscure,
            requiredMark: true,
            trailingNote: 'Min. 8 Karakter',
            onToggleObscure: () {
              setState(() => _obscure = !_obscure);
            },
          ),
          const SizedBox(height: 8),
          _strengthCard(),
          const SizedBox(height: 16),
          Text('Fokus Produktivitas Utama', style: AppTypography.labelMd),
          const SizedBox(height: 8),
          _focusChips(),
          const SizedBox(height: 14),
          _terms(),
          const SizedBox(height: 14),
          AuthPrimaryButton(
            label: 'Buat Akun & Mulai',
            loading: auth.busy,
            loadingLabel: 'Membuat akun...',
            onPressed: _submit,
          ),
          const AuthDivider(text: 'atau daftar lebih cepat dengan'),
          AuthSocialRow(
            onSocial: (String p) => AppToast.show(
                context, 'Daftar $p segera hadir. Pakai form dulu ya.'),
          ),
          const SizedBox(height: 16),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Sudah memiliki akun?',
                    style: AppTypography.bodyMd),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Masuk di sini'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.colored(AppColors.primaryContainer),
            ),
            child: const Icon(Icons.bolt_rounded,
                color: AppColors.accentAmber, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryFixed,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'LEVEL UP HARI INI',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.onSecondaryFixed,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text('Buat Akun Baru 🚀', style: AppTypography.headlineLg),
                const SizedBox(height: 4),
                Text(
                  'Mulai perjalanan produktifmu bersama KeepGrinding hari ini.',
                  style: AppTypography.bodyMd
                      .copyWith(color: AppColors.outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _strengthCard() {
    final int score = _strength;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.verified_rounded,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('Kekuatan Kata Sandi:', style: AppTypography.labelMd),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryFixed,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(_strengthLabel, style: AppTypography.labelMd),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List<Widget>.generate(4, (int i) {
              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(right: i == 3 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: i < score
                        ? AppColors.primaryContainer
                        : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _focusChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (final Map<String, dynamic> f in _focuses)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(f['icon'] as IconData, size: 16),
                    const SizedBox(width: 6),
                    Text(f['label'] as String),
                  ],
                ),
                selected: _focus == f['label'],
                onSelected: (_) =>
                    setState(() => _focus = f['label'] as String),
              ),
            ),
        ],
      ),
    );
  }

  Widget _terms() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => setState(() => _agree = !_agree),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _agree
                    ? AppColors.primaryContainer
                    : AppColors.surfaceContainerLowest,
              ),
              child: _agree
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Saya menyetujui Ketentuan Layanan serta Kebijakan Privasi KeepGrinding.',
              style: AppTypography.bodySm,
            ),
          ),
        ],
      ),
    );
  }
}
