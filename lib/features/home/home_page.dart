import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/helpers/currency_helper.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/section_header.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/transaction_tile.dart';
import '../auth/auth_controller.dart';
import 'home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onAdd, required this.onHistory});

  final VoidCallback onAdd;
  final VoidCallback onHistory;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _requestedInitialLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requestedInitialLoad) return;
    _requestedInitialLoad = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<AuthController>().session;
      if (session != null) {
        context.read<HomeController>().load(session.familyId);
      }
    });
  }

  Future<void> _refresh() async {
    final session = context.read<AuthController>().session;
    if (session != null) {
      await context.read<HomeController>().load(session.familyId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthController>().session;
    final width = MediaQuery.sizeOf(context).width;
    final padding = AppSpacing.pagePadding(width);

    if (session == null) {
      return const Scaffold(
        body: EmptyState(
          title: 'Session tidak ditemukan',
          message: 'Silakan masuk kembali untuk melihat dashboard.',
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.primaryGreen,
          child: Consumer<HomeController>(
            builder: (context, controller, _) {
              if (controller.isLoading &&
                  controller.summary.recentTransactions.isEmpty) {
                return const LoadingState();
              }

              final summary = controller.summary;
              return ListView(
                padding: EdgeInsets.fromLTRB(padding, 18, padding, 24),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, ${session.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${session.roleName} - ${session.familyName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primarySoft,
                        child: Text(
                          session.initials,
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (controller.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _ErrorBanner(message: controller.errorMessage!),
                  ],
                  const SizedBox(height: 22),
                  AppCard(
                    color: AppColors.primarySoft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.82),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Total Saldo',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            CurrencyHelper.format(summary.totalBalance),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final twoColumns = constraints.maxWidth >= 340;
                      if (!twoColumns) {
                        return Column(
                          children: [
                            SummaryCard(
                              label: 'Pemasukan Bulan Ini',
                              amount: summary.monthIncome,
                              icon: Icons.arrow_downward_rounded,
                              color: AppColors.primaryGreen,
                              compact: true,
                            ),
                            const SizedBox(height: 12),
                            SummaryCard(
                              label: 'Pengeluaran Bulan Ini',
                              amount: summary.monthExpense,
                              icon: Icons.arrow_upward_rounded,
                              color: AppColors.danger,
                              compact: true,
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: SummaryCard(
                              label: 'Pemasukan Bulan Ini',
                              amount: summary.monthIncome,
                              icon: Icons.arrow_downward_rounded,
                              color: AppColors.primaryGreen,
                              compact: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SummaryCard(
                              label: 'Pengeluaran Bulan Ini',
                              amount: summary.monthExpense,
                              icon: Icons.arrow_upward_rounded,
                              color: AppColors.danger,
                              compact: true,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  AppButton(
                    label: 'Tambah Transaksi',
                    icon: Icons.add_rounded,
                    onPressed: widget.onAdd,
                  ),
                  const SizedBox(height: 24),
                  SectionHeader(
                    title: 'Transaksi Terbaru',
                    actionLabel: 'Lihat semua',
                    onAction: widget.onHistory,
                  ),
                  const SizedBox(height: 10),
                  if (summary.recentTransactions.isEmpty)
                    const AppCard(
                      child: EmptyState(
                        title: 'Belum ada transaksi',
                        message:
                            'Catat pemasukan atau pengeluaran pertama keluarga Anda.',
                        icon: Icons.receipt_long_rounded,
                      ),
                    )
                  else
                    ...summary.recentTransactions.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TransactionTile(transaction: item),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.softRed,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
