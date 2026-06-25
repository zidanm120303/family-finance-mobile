import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/transaction_tile.dart';
import '../auth/auth_controller.dart';
import 'transaction_controller.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final _search = TextEditingController();
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  String _type = 'all';
  Timer? _debounce;
  bool _initialRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialRequested) return;
    _initialRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _search.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final session = context.read<AuthController>().session;
    if (session == null) return;
    await context.read<TransactionController>().loadHistory(
      familyId: session.familyId,
      month: _month,
      type: _type,
      search: _search.text,
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _load);
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _month,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Pilih bulan',
    );
    if (picked == null) return;
    setState(() => _month = DateTime(picked.year, picked.month));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final padding = AppSpacing.pagePadding(width);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: SafeArea(
        child: Consumer<TransactionController>(
          builder: (context, controller, _) {
            final grouped = <String, List>{};
            for (final item in controller.historyItems) {
              final key = DateHelper.formatDate(item.transactionDate);
              grouped.putIfAbsent(key, () => []).add(item);
            }

            return RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primaryGreen,
              child: ListView(
                padding: EdgeInsets.fromLTRB(padding, 4, padding, 24),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        children: [
                          AppTextField(
                            controller: _search,
                            label: 'Cari transaksi',
                            hint: 'Cari judul, kategori, atau kode',
                            icon: Icons.search_rounded,
                            onChanged: _onSearchChanged,
                          ),
                          const SizedBox(height: 12),
                          AppCard(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month_rounded,
                                  color: AppColors.primaryDark,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    DateHelper.formatMonth(_month),
                                    style: const TextStyle(
                                      color: AppColors.ink,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _pickMonth,
                                  child: const Text('Ubah'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _FilterButton(
                                  label: 'Semua',
                                  selected: _type == 'all',
                                  onTap: () {
                                    setState(() => _type = 'all');
                                    _load();
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _FilterButton(
                                  label: 'Masuk',
                                  selected: _type == 'income',
                                  onTap: () {
                                    setState(() => _type = 'income');
                                    _load();
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _FilterButton(
                                  label: 'Keluar',
                                  selected: _type == 'expense',
                                  onTap: () {
                                    setState(() => _type = 'expense');
                                    _load();
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final twoColumns = constraints.maxWidth >= 340;
                              final income = SummaryCard(
                                label: 'Total Masuk',
                                amount: controller.historyIncome,
                                icon: Icons.arrow_downward_rounded,
                                color: AppColors.primaryGreen,
                                compact: true,
                              );
                              final expense = SummaryCard(
                                label: 'Total Keluar',
                                amount: controller.historyExpense,
                                icon: Icons.arrow_upward_rounded,
                                color: AppColors.danger,
                                compact: true,
                              );
                              if (!twoColumns) {
                                return Column(
                                  children: [
                                    income,
                                    const SizedBox(height: 10),
                                    expense,
                                  ],
                                );
                              }
                              return Row(
                                children: [
                                  Expanded(child: income),
                                  const SizedBox(width: 10),
                                  Expanded(child: expense),
                                ],
                              );
                            },
                          ),
                          if (controller.errorMessage != null) ...[
                            const SizedBox(height: 12),
                            AppCard(
                              color: AppColors.softRed,
                              child: Text(
                                controller.errorMessage!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          if (controller.isLoading &&
                              controller.historyItems.isEmpty)
                            const LoadingState()
                          else if (controller.historyItems.isEmpty)
                            const AppCard(
                              child: EmptyState(
                                title: 'Riwayat masih kosong',
                                message:
                                    'Transaksi yang cocok dengan filter belum ada.',
                                icon: Icons.history_rounded,
                              ),
                            )
                          else
                            ...grouped.entries.expand(
                              (entry) => [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 10,
                                    bottom: 8,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      entry.key,
                                      style: const TextStyle(
                                        color: AppColors.ink,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                                ...entry.value.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: TransactionTile(
                                      transaction: item,
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.transactionDetail,
                                        arguments: item.id,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 8),
                          Text(
                            'Ringkasan periode: ${CurrencyHelper.format(controller.historyIncome)} masuk, ${CurrencyHelper.format(controller.historyExpense)} keluar',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        foregroundColor: selected ? AppColors.primaryDark : AppColors.muted,
        backgroundColor: selected ? AppColors.primarySoft : Colors.white,
        side: BorderSide(
          color: selected ? AppColors.primaryGreen : AppColors.line,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
      ),
      child: FittedBox(child: Text(label)),
    );
  }
}
