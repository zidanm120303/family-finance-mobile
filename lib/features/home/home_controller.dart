import 'package:flutter/foundation.dart';

import '../../data/models/home_summary_model.dart';
import '../../data/repositories/home_repository.dart';

class HomeController extends ChangeNotifier {
  HomeController({HomeRepository? repository})
    : _repository = repository ?? HomeRepository();

  final HomeRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  HomeSummaryModel summary = HomeSummaryModel.empty;

  Future<void> load(int familyId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      summary = await _repository.getSummary(familyId);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
