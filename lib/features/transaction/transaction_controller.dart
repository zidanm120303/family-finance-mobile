import 'package:flutter/foundation.dart';

import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/wallet_model.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/wallet_repository.dart';

class TransactionController extends ChangeNotifier {
  TransactionController({
    TransactionRepository? transactionRepository,
    CategoryRepository? categoryRepository,
    WalletRepository? walletRepository,
  }) : _transactionRepository =
           transactionRepository ?? TransactionRepository(),
       _categoryRepository = categoryRepository ?? CategoryRepository(),
       _walletRepository = walletRepository ?? WalletRepository();

  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;
  final WalletRepository _walletRepository;

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  List<CategoryModel> categories = [];
  List<WalletModel> wallets = [];
  List<TransactionModel> historyItems = [];
  double historyIncome = 0;
  double historyExpense = 0;
  TransactionModel? selectedTransaction;

  Future<void> loadFormData({
    required int familyId,
    required String type,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await Future.wait([
        _categoryRepository.byType(familyId: familyId, type: type),
        _walletRepository.byFamily(familyId),
      ]);
      categories = result[0] as List<CategoryModel>;
      wallets = result[1] as List<WalletModel>;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create(CreateTransactionRequest request) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _transactionRepository.create(request);
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory({
    required int familyId,
    required DateTime month,
    String type = 'all',
    String search = '',
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await _transactionRepository.history(
        familyId: familyId,
        month: month,
        type: type,
        search: search,
      );
      historyItems = result.items;
      historyIncome = result.totalIncome;
      historyExpense = result.totalExpense;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDetail({required int id, required int familyId}) async {
    isLoading = true;
    errorMessage = null;
    selectedTransaction = null;
    notifyListeners();
    try {
      selectedTransaction = await _transactionRepository.detail(
        id: id,
        familyId: familyId,
      );
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
