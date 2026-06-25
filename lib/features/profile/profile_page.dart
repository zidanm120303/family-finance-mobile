import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/database/db_config.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../auth/auth_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthController>().logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthController>().session;
    final padding = AppSpacing.pagePadding(MediaQuery.sizeOf(context).width);

    if (session == null) {
      return const Scaffold(
        body: EmptyState(
          title: 'Profil belum tersedia',
          message: 'Silakan masuk kembali untuk melihat profil.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(padding, 8, padding, 24),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  children: [
                    AppCard(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: AppColors.primarySoft,
                            child: Text(
                              session.initials,
                              style: const TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            session.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            session.roleName,
                            style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppCard(
                      child: Column(
                        children: [
                          _ProfileRow(
                            icon: Icons.family_restroom_rounded,
                            label: 'Nama keluarga',
                            value: session.familyName,
                          ),
                          _ProfileRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: session.email,
                          ),
                          _ProfileRow(
                            icon: Icons.phone_outlined,
                            label: 'Nomor HP',
                            value: session.phone?.isEmpty ?? true
                                ? '-'
                                : session.phone!,
                          ),
                          _ProfileRow(
                            icon: Icons.alternate_email_rounded,
                            label: 'Username',
                            value: session.username?.isEmpty ?? true
                                ? '-'
                                : session.username!,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informasi Database',
                            style: TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _ProfileRow(
                            icon: Icons.lan_outlined,
                            label: 'Koneksi',
                            value: DbConfig.connectionLabel,
                          ),
                          _ProfileRow(
                            icon: Icons.dns_outlined,
                            label: 'Host DB',
                            value: DbConfig.host,
                          ),
                          _ProfileRow(
                            icon: Icons.storage_outlined,
                            label: 'Database',
                            value: DbConfig.database,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    AppButton(
                      label: 'Logout',
                      icon: Icons.logout_rounded,
                      isDanger: true,
                      onPressed: () => _logout(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
