import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/empty_state.dart';
import 'add_edit_expense_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(date);
  }

  Future<void> _confirmDelete(BuildContext context, Expense e) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: Text('"${e.title}" will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.expense),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final provider = context.read<ExpenseProvider>();
    final ok = await provider.deleteExpense(e.id!);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Transaction deleted' : (provider.error ?? 'Could not delete'),
        ),
        backgroundColor: ok ? null : AppColors.expense,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _edit(BuildContext context, Expense e) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => AddEditExpenseScreen(expense: e)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Transaction History'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, p, _) {
          if (p.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (p.error != null && p.expenses.isEmpty) {
            return Center(
              child: Text(
                p.error!,
                style: const TextStyle(color: AppColors.expense),
              ),
            );
          }
          if (p.expenses.isEmpty) {
            return const EmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: p.expenses.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final e = p.expenses[i];
              final color = e.isIncome ? AppColors.income : AppColors.expense;
              final sign = e.isIncome ? '+' : '-';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_dateLabel(e.date)} • ${e.category}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$sign $kCurrency${NumberFormat('#,##0.00').format(e.amount)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    _actionButton(
                      icon: Icons.edit_outlined,
                      bg: const Color(0xFFEDEDED),
                      fg: AppColors.textDark,
                      onTap: () => _edit(context, e),
                    ),
                    const SizedBox(width: 4),
                    _actionButton(
                      icon: Icons.delete_outline,
                      bg: AppColors.expense,
                      fg: Colors.white,
                      onTap: () => _confirmDelete(context, e),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16, color: fg),
        ),
      ),
    );
  }
}
