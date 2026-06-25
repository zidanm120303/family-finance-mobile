import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_state.dart';
import '../auth/auth_controller.dart';
import 'transaction_controller.dart';

class TransactionDetailPage extends StatefulWidget {
  const TransactionDetailPage({super.key, required this.transactionId});

  final int transactionId;

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<AuthController>().session;
      if (session != null) {
        context.read<TransactionController>().loadDetail(
          id: widget.transactionId,
          familyId: session.familyId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppSpacing.pagePadding(MediaQuery.sizeOf(context).width);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Transaksi')),
      body: SafeArea(
        child: Consumer<TransactionController>(
          builder: (context, controller, _) {
            if (controller.isLoading) return const LoadingState();
            final item = controller.selectedTransaction;
            if (item == null) {
              return EmptyState(
                title: 'Transaksi tidak ditemukan',
                message:
                    controller.errorMessage ?? 'Data transaksi belum tersedia.',
                icon: Icons.receipt_long_rounded,
              );
            }

            final color = item.isIncome
                ? AppColors.primaryGreen
                : AppColors.danger;
            return ListView(
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
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Icon(
                                  item.isIncome
                                      ? Icons.arrow_downward_rounded
                                      : Icons.arrow_upward_rounded,
                                  color: color,
                                  size: 34,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                item.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              FittedBox(
                                child: Text(
                                  CurrencyHelper.format(
                                    item.amount,
                                    withSign: true,
                                    type: item.type,
                                  ),
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppCard(
                          child: Column(
                            children: [
                              _DetailRow(
                                label: 'Kode transaksi',
                                value: item.transactionCode,
                              ),
                              _DetailRow(label: 'Tipe', value: item.typeLabel),
                              _DetailRow(
                                label: 'Kategori',
                                value: item.categoryName ?? '-',
                              ),
                              _DetailRow(
                                label: 'Tanggal',
                                value: DateHelper.formatDate(
                                  item.transactionDate,
                                ),
                              ),
                              _DetailRow(
                                label: 'Metode pembayaran',
                                value: item.paymentMethodLabel,
                              ),
                              _DetailRow(
                                label: 'Dompet',
                                value: item.walletName ?? '-',
                              ),
                              _DetailRow(label: 'Status', value: item.status),
                              _DetailRow(
                                label: 'Dibuat oleh',
                                value: item.userName ?? '-',
                              ),
                              _DetailRow(
                                label: 'Catatan',
                                value: item.description?.isEmpty ?? true
                                    ? '-'
                                    : item.description!,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
