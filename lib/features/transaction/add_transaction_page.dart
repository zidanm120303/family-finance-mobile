import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/date_helper.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dropdown.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/loading_state.dart';
import '../auth/auth_controller.dart';
import '../home/home_controller.dart';
import 'transaction_controller.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key, required this.onSaved});

  final VoidCallback onSaved;

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  final _dateController = TextEditingController();
  String _type = 'income';
  String _paymentMethod = 'cash';
  DateTime _date = DateTime.now();
  int? _categoryId;
  int? _walletId;
  bool _allowMinusBalance = false;
  bool _initialRequested = false;

  @override
  void initState() {
    super.initState();
    _syncDateController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialRequested) return;
    _initialRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFormData());
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _syncDateController() {
    _dateController.text = DateHelper.formatDate(_date);
  }

  Future<void> _loadFormData() async {
    final session = context.read<AuthController>().session;
    if (session == null) return;
    final controller = context.read<TransactionController>();
    await controller.loadFormData(familyId: session.familyId, type: _type);
    if (!mounted) return;
    setState(() {
      _categoryId = controller.categories.isEmpty
          ? null
          : controller.categories.first.id;
      _walletId = controller.wallets.isEmpty
          ? null
          : controller.wallets.first.id;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _syncDateController();
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final session = context.read<AuthController>().session;
    if (session == null) return;
    final transactionController = context.read<TransactionController>();
    final homeController = context.read<HomeController>();
    final messenger = ScaffoldMessenger.of(context);
    final amount = CurrencyHelper.parseInput(_amount.text);
    final success = await transactionController.create(
      CreateTransactionRequest(
        familyId: session.familyId,
        userId: session.userId,
        categoryId: _categoryId!,
        walletId: _walletId!,
        type: _type,
        amount: amount,
        title: _title.text,
        transactionDate: _date,
        paymentMethod: _paymentMethod,
        description: _note.text.isEmpty ? null : _note.text,
        allowMinusBalance: _allowMinusBalance,
      ),
    );

    if (!mounted) return;
    if (success) {
      await homeController.load(session.familyId);
      if (!mounted) return;
      _title.clear();
      _amount.clear();
      _note.clear();
      setState(() {
        _date = DateTime.now();
        _syncDateController();
        _allowMinusBalance = false;
      });
      messenger.showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil disimpan.')),
      );
      widget.onSaved();
    } else {
      final message = transactionController.errorMessage;
      messenger.showSnackBar(
        SnackBar(content: Text(message ?? 'Transaksi gagal disimpan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthController>().session;
    final width = MediaQuery.sizeOf(context).width;
    final padding = AppSpacing.pagePadding(width);

    if (session == null) {
      return const Scaffold(
        body: LoadingState(message: 'Memeriksa session...'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Transaksi')),
      body: SafeArea(
        child: Consumer<TransactionController>(
          builder: (context, controller, _) {
            if (controller.isLoading && controller.categories.isEmpty) {
              return const LoadingState();
            }
            final amount = CurrencyHelper.parseInput(_amount.text);
            final impact = _type == 'income' ? amount : -amount;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(padding, 4, padding, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Informasi Transaksi',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 18),
                              _TypeSegment(
                                type: _type,
                                onChanged: (value) async {
                                  setState(() {
                                    _type = value;
                                    _categoryId = null;
                                  });
                                  await _loadFormData();
                                },
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                controller: _title,
                                label: 'Judul Transaksi',
                                hint: 'Contoh: Gaji Bulanan',
                                icon: Icons.edit_note_rounded,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Judul transaksi wajib diisi.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                controller: _amount,
                                label: 'Nominal',
                                hint: 'Masukkan nominal',
                                icon: Icons.payments_outlined,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                                validator: (value) {
                                  if (CurrencyHelper.parseInput(value ?? '') <=
                                      0) {
                                    return 'Nominal transaksi harus lebih dari 0.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              AppDropdown<int>(
                                label: 'Kategori',
                                hint: 'Pilih kategori',
                                value: _categoryId,
                                icon: Icons.category_outlined,
                                items: controller.categories
                                    .map(
                                      (item) => DropdownMenuItem(
                                        value: item.id,
                                        child: Text(item.categoryName),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => _categoryId = value),
                                validator: (value) => value == null
                                    ? 'Kategori wajib dipilih.'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                controller: _dateController,
                                label: 'Tanggal Transaksi',
                                hint: 'Pilih tanggal',
                                icon: Icons.calendar_today_outlined,
                                readOnly: true,
                                onTap: _pickDate,
                                validator: (_) => null,
                              ),
                              const SizedBox(height: 16),
                              _PaymentSelector(
                                value: _paymentMethod,
                                onChanged: (value) =>
                                    setState(() => _paymentMethod = value),
                              ),
                              const SizedBox(height: 16),
                              AppDropdown<int>(
                                label: 'Dompet/Rekening',
                                hint: 'Pilih dompet',
                                value: _walletId,
                                icon: Icons.account_balance_wallet_outlined,
                                items: controller.wallets
                                    .map(
                                      (item) => DropdownMenuItem(
                                        value: item.id,
                                        child: Text(
                                          '${item.walletName} - ${item.typeLabel}',
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => _walletId = value),
                                validator: (value) => value == null
                                    ? 'Dompet wajib dipilih.'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                controller: _note,
                                label: 'Catatan',
                                hint: 'Catatan tambahan opsional',
                                icon: Icons.notes_rounded,
                                maxLines: 3,
                              ),
                              const SizedBox(height: 10),
                              CheckboxListTile(
                                value: _allowMinusBalance,
                                onChanged: (value) {
                                  setState(
                                    () => _allowMinusBalance = value ?? false,
                                  );
                                },
                                contentPadding: EdgeInsets.zero,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: const Text(
                                  'Izinkan saldo minus jika dompet tidak cukup',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppCard(
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: impact >= 0
                                      ? AppColors.primarySoft
                                      : AppColors.softRed,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  impact >= 0
                                      ? Icons.trending_up_rounded
                                      : Icons.trending_down_rounded,
                                  color: impact >= 0
                                      ? AppColors.primaryDark
                                      : AppColors.danger,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Ringkasan Dampak Saldo',
                                      style: TextStyle(
                                        color: AppColors.muted,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      CurrencyHelper.format(
                                        impact,
                                        withSign: true,
                                        type: impact >= 0
                                            ? 'income'
                                            : 'expense',
                                      ),
                                      style: TextStyle(
                                        color: impact >= 0
                                            ? AppColors.primaryDark
                                            : AppColors.danger,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        AppButton(
                          label: 'Simpan Transaksi',
                          icon: Icons.check_rounded,
                          isLoading: controller.isSaving,
                          onPressed: _save,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TypeSegment extends StatelessWidget {
  const _TypeSegment({required this.type, required this.onChanged});

  final String type;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SegmentButton(
            label: 'Pemasukan',
            icon: Icons.arrow_downward_rounded,
            selected: type == 'income',
            color: AppColors.primaryGreen,
            onTap: () => onChanged('income'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SegmentButton(
            label: 'Pengeluaran',
            icon: Icons.arrow_upward_rounded,
            selected: type == 'expense',
            color: AppColors.danger,
            onTap: () => onChanged('expense'),
          ),
        ),
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: FittedBox(child: Text(label)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        foregroundColor: selected ? color : AppColors.ink,
        backgroundColor: selected
            ? color.withValues(alpha: 0.11)
            : Colors.white,
        side: BorderSide(color: selected ? color : AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _PaymentSelector extends StatelessWidget {
  const _PaymentSelector({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('cash', 'Cash', Icons.payments_outlined),
      ('e-wallet', 'E-Wallet', Icons.account_balance_wallet_outlined),
      ('bank', 'Bank', Icons.account_balance_outlined),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Metode Pembayaran',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Row(
          children: items
              .map(
                (item) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: item.$1 == 'bank' ? 0 : 8),
                    child: _SegmentButton(
                      label: item.$2,
                      icon: item.$3,
                      selected: value == item.$1,
                      color: AppColors.primaryGreen,
                      onTap: () => onChanged(item.$1),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
