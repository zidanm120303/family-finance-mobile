import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/brand_logo.dart';
import 'auth_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _familyName = TextEditingController();
  final _city = TextEditingController();
  final _province = TextEditingController();
  String _role = 'Ayah';
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _username.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _familyName.dispose();
    _city.dispose();
    _province.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context.read<AuthController>().register(
      RegisterRequest(
        name: _name.text,
        email: _email.text,
        username: _username.text,
        phone: _phone.text,
        password: _password.text,
        familyName: _familyName.text,
        city: _role == 'Ayah' ? _city.text : '',
        province: _role == 'Ayah' ? _province.text : '',
        roleLabel: _role,
      ),
    );
    if (!mounted) return;
    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.shell, (_) => false);
    } else {
      final message = context.read<AuthController>().errorMessage;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message ?? 'Registrasi gagal.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final padding = AppSpacing.pagePadding(width);

    return Scaffold(
      appBar: AppBar(
        title: const BrandLogo(width: 150, center: false),
        toolbarHeight: 72,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(padding, 8, padding, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  const Text(
                    'Daftar & Buat Keluarga',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Buat akun dan siapkan keluarga untuk mulai mengelola keuangan bersama.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SvgPicture.asset(
                    'assets/svg/illustration_family_simple.svg',
                    height: 104,
                  ),
                  const SizedBox(height: 18),
                  AppCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FormTitle('Informasi Akun'),
                          AppTextField(
                            controller: _name,
                            label: 'Nama Lengkap',
                            hint: 'Contoh: Budi Pratama',
                            icon: Icons.badge_outlined,
                            validator: _required('Nama lengkap wajib diisi.'),
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _email,
                            label: 'Email',
                            hint: 'contoh@email.com',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: _required('Email wajib diisi.'),
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _username,
                            label: 'Username',
                            hint: 'Contoh: budipratama',
                            icon: Icons.alternate_email_rounded,
                            validator: _required('Username wajib diisi.'),
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _phone,
                            label: 'Nomor HP',
                            hint: '08xxxxxxxxxx',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: _required('Nomor HP wajib diisi.'),
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _password,
                            label: 'Password',
                            hint: 'Minimal 8 karakter',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword
                                  ? 'Tampilkan password'
                                  : 'Sembunyikan password',
                              onPressed: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password wajib diisi.';
                              }
                              if (value.length < 8) {
                                return 'Password minimal 8 karakter.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _confirmPassword,
                            label: 'Konfirmasi Password',
                            hint: 'Ulangi password Anda',
                            icon: Icons.lock_reset_rounded,
                            obscureText: _obscureConfirm,
                            suffixIcon: IconButton(
                              tooltip: _obscureConfirm
                                  ? 'Tampilkan password'
                                  : 'Sembunyikan password',
                              onPressed: () {
                                setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                );
                              },
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                            validator: (value) {
                              if (value != _password.text) {
                                return 'Konfirmasi password harus sama.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 22),
                          const _FormTitle('Peran Anda dalam Keluarga'),
                          Row(
                            children: [
                              Expanded(
                                child: _RoleCard(
                                  label: 'Ayah',
                                  subtitle: 'Kepala Keluarga',
                                  icon: Icons.man_rounded,
                                  selected: _role == 'Ayah',
                                  onTap: () => setState(() => _role = 'Ayah'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _RoleCard(
                                  label: 'Ibu Rumah Tangga',
                                  subtitle: 'Ibu',
                                  icon: Icons.woman_rounded,
                                  selected: _role == 'Ibu Rumah Tangga',
                                  onTap: () => setState(
                                    () => _role = 'Ibu Rumah Tangga',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          _FormTitle(
                            _role == 'Ayah'
                                ? 'Informasi Keluarga Baru'
                                : 'Bergabung ke Keluarga',
                          ),
                          AppTextField(
                            controller: _familyName,
                            label: _role == 'Ayah'
                                ? 'Nama Keluarga'
                                : 'Nama Keluarga Tujuan',
                            hint: 'Contoh: Keluarga Pratama',
                            icon: _role == 'Ayah'
                                ? Icons.family_restroom_rounded
                                : Icons.group_add_rounded,
                            validator: _required('Nama keluarga wajib diisi.'),
                          ),
                          if (_role == 'Ayah') ...[
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: _city,
                              label: 'Kota',
                              hint: 'Contoh: Jakarta Selatan',
                              icon: Icons.location_city_outlined,
                              validator: _required('Kota wajib diisi.'),
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: _province,
                              label: 'Provinsi',
                              hint: 'Contoh: DKI Jakarta',
                              icon: Icons.map_outlined,
                              validator: _required('Provinsi wajib diisi.'),
                            ),
                          ],
                          const SizedBox(height: 24),
                          Consumer<AuthController>(
                            builder: (context, controller, _) {
                              return AppButton(
                                label: _role == 'Ayah'
                                    ? 'Buat Akun & Keluarga'
                                    : 'Bergabung ke Keluarga',
                                icon: _role == 'Ayah'
                                    ? Icons.arrow_forward_rounded
                                    : Icons.group_add_rounded,
                                isLoading: controller.isLoading,
                                onPressed: _submit,
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_rounded),
                              label: const Text('Kembali ke Login'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? Function(String?) _required(String message) {
    return (value) {
      if (value == null || value.trim().isEmpty) return message;
      return null;
    };
  }
}

class _FormTitle extends StatelessWidget {
  const _FormTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        constraints: const BoxConstraints(minHeight: 116),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primaryGreen : AppColors.line,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primaryDark : AppColors.muted,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
