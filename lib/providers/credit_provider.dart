import 'package:flutter/foundation.dart';

import '../data/database_helper.dart';
import '../models/credit.dart';

class CreditProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;

  void clearLocal() {
    _credits = [];
    notifyListeners();
  }

  List<Credit> _credits = [];
  String? error;

  List<Credit> get credits => _credits;

  Future<void> loadCredits() async {
    try {
      _credits = await _db.getAllCredits();
      error = null;
    } catch (e) {
      error = 'Could not load saved list';
    }
    notifyListeners();
  }

  Future<bool> addCredit(Credit c) => _run(() => _db.insertCredit(c));
  Future<bool> deleteCredit(int id) => _run(() => _db.deleteCredit(id));

  Future<bool> _run(Future<int> Function() action) async {
    try {
      await action();
      _credits = await _db.getAllCredits();
      error = null;
      notifyListeners();
      return true;
    } catch (e) {
      error = 'Database error. Please try again.';
      notifyListeners();
      return false;
    }
  }
}
