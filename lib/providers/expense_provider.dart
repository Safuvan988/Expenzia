import 'package:flutter/foundation.dart';

import '../data/database_helper.dart';
import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;

  List<Expense> _expenses = [];
  bool isLoading = false;
  String? error;

  List<Expense> get expenses => _expenses;

  double get totalIncome =>
      _expenses.where((e) => e.isIncome).fold(0, (s, e) => s + e.amount);

  double get totalExpense =>
      _expenses.where((e) => !e.isIncome).fold(0, (s, e) => s + e.amount);

  double get balance => totalIncome - totalExpense;

  // Expenses in the last 7 days
  double get weeklyExpense {
    final from = DateTime.now().subtract(const Duration(days: 7));
    return _expenses
        .where((e) => !e.isIncome && e.date.isAfter(from))
        .fold(0, (s, e) => s + e.amount);
  }

  double get dailyAverage => weeklyExpense / 7;

  Future<void> clearAll() async {
    try {
      await _db.clearAll();
      _expenses = [];
      error = null;
    } catch (e) {
      error = 'Could not clear data';
    }
    notifyListeners();
  }

  Future<void> loadExpenses() async {
    isLoading = true;
    notifyListeners();
    try {
      _expenses = await _db.getAll();
      error = null;
    } catch (e) {
      error = 'Could not load expenses';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> addExpense(Expense e) => _run(() => _db.insert(e));
  Future<bool> updateExpense(Expense e) => _run(() => _db.update(e));
  Future<bool> deleteExpense(int id) => _run(() => _db.delete(id));

  Future<bool> _run(Future<int> Function() action) async {
    try {
      await action();
      _expenses = await _db.getAll();
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
